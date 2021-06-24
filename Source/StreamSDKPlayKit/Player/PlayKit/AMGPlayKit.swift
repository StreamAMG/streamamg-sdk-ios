//
//  AMGPlayKit.swift
//  StreamAMGPlayer
//
//  Created by Mike Hall on 09/03/2021.
//

import UIKit
import PlayKit
import PlayKit_IMA
import GoogleCast
import MediaPlayer



/**
 This protocol handles calls from UI controls , including play state and playhead position
 */

public protocol AMGPlayerDelegate {
    func play()
    func pause()
    func scrub(position: TimeInterval)
    func skipForward()
    func skipBackward()
    func setControlDelegate(_ delegate: AMGControlDelegate)
    func cancelTimer()
    func startControlVisibilityTimer()
    
    func minimise()
    func fullScreen()
}

/**
AMGPlayKit is an SDK that wraps Kaltura PlayKit, AMGAnalytics, IMA, basic casting and other useful functions into a simple to use view.
 
The SDK, at it's most basic, is a UIView, instantiated either programatically, or via Storyboard, that acts as a single point of reference for all Kaltura PlayKit functionality
 */
@objc public class AMGPlayKit: UIView, GCKSessionManagerListener, GCKRemoteMediaClientListener, GCKRequestDelegate, AMGPlayerDelegate {

    var playerView: PlayerView? = nil
    public var player: Player!
    var partnerID: Int = 0
    
    internal var currentMedia: MediaItem? = nil
    
    internal var control: AMGControlDelegate? = nil
    internal var controlUI: AMGPlayKitStandardControl? = nil
    
    internal var controlVisibleDuration: TimeInterval = 5
    
    internal var skipForwardTime: TimeInterval = 5
    internal var skipBackwardTime: TimeInterval = 5
    
    
    internal var controlVisibleTimer: Timer? = nil
    
    var orientationTime: TimeInterval = 0
    
    var currentOrientation: UIInterfaceOrientation = .portrait
    
    var playHeadObserver: UUID?
    
    var isLiveImageView = UIImageView()
    var logoImageView = UIImageView()
    
    // Casting properties
    
    internal var mediaInformation: GCKMediaInformation?
    internal var sessionManager: GCKSessionManager?
    internal var castButton: GCKUICastButton!
    
    
/**
     Standard initialisation
     
     - Parameter frame: A CGRect describing the desired frame for the UIView. The Kaltura PlayKit will fill this view
     - Returns: A UIView containing an instantiated instance of the Kaltura PlayKit
*/
    public override init(frame: CGRect){
        super.init(frame: frame)
        createPlayer()

    }
    
    /**
         Standard initialisation with Partner ID - The preferred programmatic initialisation
         
         - Parameter frame: A CGRect describing the desired frame for the UIView. The Kaltura PlayKit will fill this view
         - Parameter partnerID: An integer value representing the Partner ID to be used in any played media
         - Returns: A UIView containing an instantiated instance of the Kaltura PlayKit
     
         Partner ID can also be sent separately or as part of media data when loading media
    */
    public init(frame: CGRect, partnerID: Int){
        super.init(frame: frame)
        self.partnerID = partnerID
        createPlayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
     //   createPlayer()
    }
    
    /**
        Adds the Partner ID to the instance of AMGPlayKit.
     
        Should be used if instantiating the view via Storyboard, or if the view was instantiated manually without the Partner ID
     
        - Parameter partnerID: An integer value representing the Partner ID to be used in any played media
     */
    public func addPartnerID(partnerId: Int){
        partnerID = partnerId
    }
    
    /**
        Changes the URL of the analytics endpoint
     
        Should only be used if targetting a secondary or non-standard analytics server
     
        - Parameter url: The URL of the server to target
     */
    public func setAnalyticsURL(_ url: String) {
        AMGAnalyticsPlugin.setAnalyticsURL(url)
    }
    
   
    public func createPlayer(){
        setNeedsLayout()
        layoutIfNeeded()
        let frame = CGRect(x: 0,y: 0,width: self.frame.size.width, height: self.frame.size.height)
        playerView = PlayerView(frame: frame)
        playerView?.contentMode = .scaleAspectFill
        addSubview(playerView!)
        constructPlayKit()
        setUpOverlays()
 //       setUpCasting()
    }
    
    
  
    func constructPlayKit() {
        PlayKitManager.shared.registerPlugin(IMAPlugin.self)
        PlayKitManager.shared.registerPlugin(AMGAnalyticsPlugin.self)
        player = PlayKitManager.shared.loadPlayer(pluginConfig: createPluginConfig())
        player?.addObserver(self, events: [AdEvent.adStarted]) { event in
            if let info = event.adInfo {
                // use ad info
                switch info.positionType {
                case .preRoll: print("Pre-roll")
                case .midRoll: print("Mid-roll")
                case .postRoll: print("Post-roll")
                }
            } else {
                print("Ad event: \(event.description)")
            }
        }
        self.player?.view = playerView
        self.player?.addObserver(self, events: [PlayerEvent.error]) { event in
            print("Error in AMGPlayKit \(event.data)")
        }
        self.player?.addObserver(self, events: [PlayerEvent.errorLog]) { event in
            print("ErrorLog in AMGPlayKit \(event.data)")
        }
        self.player?.addObserver(self, events: [PlayerEvent.play]) { event in
            self.playEventOccurred()
        }
        self.player?.addObserver(self, events: [PlayerEvent.playing]) { event in
            self.playEventOccurred()
        }
        self.player?.addObserver(self, events: [PlayerEvent.pause]) { event in
            self.stopEventOccurred()
        }
        self.player?.addObserver(self, events: [PlayerEvent.ended]) { event in
            self.stopEventOccurred()
        }
        self.player?.addObserver(self, events: [PlayerEvent.durationChanged]) { event in
            self.changeDuration(length: TimeInterval(event.duration?.doubleValue ?? 0))
        }
        playHeadObserver = self.player?.addPeriodicObserver(interval: 0.1, observeOn: DispatchQueue.main, using: { [weak self] (pos) in
            self?.control?.changePlayHead(position: pos)
        })

    }
    
    func changeDuration(length: TimeInterval) {
        control?.changeMediaLength(length: length)
    }
    
    func changePlayHead() {
        if let playHead = self.player?.currentTime{
            control?.changePlayHead(position: playHead)
    }
    }
    
    func changeBitrate(){
       // player?.settings.network.preferredPeakBitRate = 
    }
    
    func playEventOccurred() {
        control?.play()
    }
    
    func stopEventOccurred() {
        control?.pause()
    }
    
    /**
        Adds a Fairplay license provider, if required
     
        - Parameter licenseProvider: An instance of 'FairPlayLicenceProvider'
     */
    public func setFairPlayLicenseProvider(licenseProvider: FairPlayLicenseProvider) {
        self.player?.settings.fairPlayLicenseProvider = licenseProvider
    }

    func createAnalyticsPlugin() -> AMGAnalyticsPluginConfig {
        return AMGAnalyticsPluginConfig(partnerId: partnerID)
    }

    func createPluginConfig() -> PluginConfig? {
        //   return nil // Analytics disabled until the backend is complete
        //return PluginConfig(config: [AMGAnalyticsPlugin.pluginName: createAnalyticsPlugin()])
        return PluginConfig(config: [IMAPlugin.pluginName: getIMAPluginConfig(adTagUrl: ""), AMGAnalyticsPlugin.pluginName: createAnalyticsPlugin()])
    }

    private func loadMedia(media: MediaItem){
        currentMedia = media
        if partnerID > 0{
            player?.updatePluginConfig(pluginName: AMGAnalyticsPlugin.pluginName, config: createPluginConfig() as Any)
            player?.prepare(media.media())
            player?.play()
        }
    }
    
    /**
        Queues and runs the specified media item if available
     
        - Parameters:
            - serverUrl: The URL the media is hosted on
            - entryID: The unique ID for the media item, as specified by StreamAMG
            - ks: If the media requires a KS to play, it should be passed here, otherwise this should be `nil` or completely ommitted
     */
    public func loadMedia(serverUrl: String, entryID: String, ks: String? = nil, mediaType: MediaType = .vod, drmLicenseURI: String? = nil, drmFPSCertificate: String? = nil){
        if partnerID > 0{
            loadMedia(media: MediaItem(serverUrl: serverUrl, partnerId: partnerID, entryId: entryID, ks: ks, mediaType: mediaType, drmLicenseURI: drmLicenseURI, drmFPSCertificate: drmFPSCertificate))
        } else {
            print("Please provide a PartnerID with the request, add a default with 'addPartnerID(partnerID:Int)' or set a default in the initialiser")
        }
    }
    
    /**
        Queues and runs the specified media item if available, specifying a new partner ID
     
        - Parameters:
            - serverUrl: The URL the media is hosted on
            - partnerID: The Partner ID to be used when loading the media item, as specified by StreamAMG
            - entryID: The unique ID for the media item, as specified by StreamAMG
            - ks: If the media requires a KS to play, it should be passed here, otherwise this should be `nil` or completely ommitted
     */
    public func loadMedia(serverUrl: String, partnerID: Int, entryID: String, ks: String? = nil, mediaType: MediaType = .vod, drmLicenseURI: String? = nil, drmFPSCertificate: String? = nil){
        self.partnerID = partnerID
        loadMedia(media: MediaItem(serverUrl: serverUrl, partnerId: partnerID, entryId: entryID, ks: ks, mediaType: mediaType, drmLicenseURI: drmLicenseURI, drmFPSCertificate: drmFPSCertificate))
    }

    // IMA
    
    /**
        Attaches an advert to all media played
     
        Once fired, the advert can be cancelled by sending an empty string to this function
     
        - Parameter adTagUrl: The VAST URL of the advert to be consumed
     */
    public func serveAdvert(adTagUrl: String){
        self.player?.updatePluginConfig(pluginName: IMAPlugin.pluginName, config: getIMAPluginConfig(adTagUrl: adTagUrl))
    }

    private func getIMAPluginConfig(adTagUrl: String) -> IMAConfig {
        let adsConfig = IMAConfig()
        adsConfig.set(adTagUrl: adTagUrl)
        return adsConfig
    }
    
    // Player Delegate
    
    /**
        Manually play the queued media track
     */
    public func play() {
        if let player = player {
            if (player.currentState == .ended) {
                player.currentTime = 0
            }
        player.play()
        startControlVisibilityTimer()
        }
    }
    
    /**
        Manually pause the queued media track
     */
    public func pause() {
        player?.pause()
        startControlVisibilityTimer()
    }
    
    /**
        Manually set the playhead for the queued media track
     */
    public func scrub(position: TimeInterval) {
        player?.currentTime = position  //seek(to: position)
    }
    
    public func skipForward() {
        if let player = player {
            let time = player.currentTime + skipForwardTime
            if time > player.duration {
                player.currentTime = player.duration
            } else {
                player.currentTime = time
            }
        startControlVisibilityTimer()
        }
    }

    public func skipBackward() {
        if let player = player {
            let time = player.currentTime - skipBackwardTime
            if time < 0 {
                player.currentTime = 0
            } else {
                player.currentTime = time
            }
        startControlVisibilityTimer()
        }
    }
    
    /**
        Set the control delegate for the current UI Control class
     */
    public func setControlDelegate(_ delegate: AMGControlDelegate) {
        control = delegate
    }
    
    /**
    Set the time skipped for forward skip as a time duration
     */
    public func skipForwardDuration(_ duration: TimeInterval) {
        skipForwardTime = duration
    }
    
    /**
    Set the time skipped for backward skip
     */
    public func skipBackwardDuration(_ duration: TimeInterval) {
        skipBackwardTime = duration
    }
    
    /**
    Set the time skipped for backward and forward skip
     */
    public func skipDuration(_ duration: TimeInterval) {
        skipBackwardTime = duration
        skipForwardTime = duration
    }
    
    /**
    Set the time skipped for forward skip
     */
    public func skipForwardTime(_ duration: Int) {
        skipForwardTime = TimeInterval(duration / 1000)
    }
    
    /**
    Set the time skipped for backward skip
     */
    public func skipBackwardTime(_ duration: Int) {
        skipBackwardTime = TimeInterval(duration / 1000)
    }
    
    /**
    Set the time skipped for backward and forward skip
     */
    public func skipTime(_ duration: Int) {
        skipBackwardTime = TimeInterval(duration / 1000)
        skipForwardTime = TimeInterval(duration / 1000)
    }
    
    public func minimise() {
        if orientationTime > Date().timeIntervalSince1970 - 1.0 {
            return
        }
        orientationTime = Date().timeIntervalSince1970
        let value  = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        resizeScreen()
        playerView?.layoutIfNeeded()
        controlUI?.setFullScreen(false)
    }
    
    public func fullScreen() {
        if orientationTime > Date().timeIntervalSince1970 - 1.0 {
            return
        }
        orientationTime = Date().timeIntervalSince1970
        var value  = UIInterfaceOrientation.landscapeRight.rawValue
        if UIApplication.shared.statusBarOrientation == .landscapeLeft {
           value = UIInterfaceOrientation.landscapeLeft.rawValue
        }
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        resizeScreen()
        playerView?.layoutIfNeeded()
        controlUI?.setFullScreen(true)
    }

    
}
