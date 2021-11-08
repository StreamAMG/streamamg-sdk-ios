//
//  AMGPlayKit.swift
//  StreamAMGPlayer
//
//  Created by Mike Hall on 09/03/2021.
//

import UIKit
import PlayKit
import PlayKit_IMA
import PlayKitYoubora
import MediaPlayer
import AVKit



/**
 This protocol handles calls from UI controls , including play state and playhead position
 */


/**
 AMGPlayKit is an SDK that wraps Kaltura PlayKit, AMGAnalytics, IMA, basic casting and other useful functions into a simple to use view.
 
 The SDK, at it's most basic, is a UIView, instantiated either programatically, or via Storyboard, that acts as a single point of reference for all Kaltura PlayKit functionality
 */
@objc public class AMGPlayKit: UIView, AMGPlayerDelegate { // GCKSessionManagerListener, GCKRemoteMediaClientListener, GCKRequestDelegate, 
    
    var playerView: PlayerView? = nil
    public var player: Player!
    var partnerID: Int = 0
    
    internal var currentMedia: MediaItem? = nil
    internal var currentMediaType: AMGMediaType = .VOD
    
    internal var control: AMGControlDelegate? = nil
    internal var controlUI: AMGPlayKitStandardControl? = nil
    
    internal var controlVisibleDuration: TimeInterval = 5
    
    internal var skipForwardTime: TimeInterval = 5
    internal var skipBackwardTime: TimeInterval = 5
    
    internal var controlVisibleTimer: Timer? = nil
    
    internal var castingCompletion: ((URL?) -> Void)? = nil
    internal var castingURL: URL? = nil
    internal var initialCastingURL: String? = nil
    
    var orientationTime: TimeInterval = 0
    
    var currentOrientation: UIInterfaceOrientation = .portrait
    
    var playHeadObserver: UUID?
    
    var isLiveImageView = UIImageView()
    var logoImageView = UIImageView()
    
    var listener: AMGPlayKitListener? = nil
    
    private var playerState: PlayerState? = nil
    
    internal var pipDelegate: AMGPictureInPictureDelegate?
    
    internal var pictureInPictureController: AVPictureInPictureController?
    internal var pipPossibleObservation: NSKeyValueObservation?
    
    var analyticsConfiguration = AMGAnalyticsConfig()
    
    private var currentAdvert = ""
    
   // var adIsPlaying = false
    
    var tap: UITapGestureRecognizer? = nil
    
    // Casting properties
    
    //    internal var mediaInformation: GCKMediaInformation?
    //    internal var sessionManager: GCKSessionManager?
    //    internal var castButton: GCKUICastButton!
    
    
    /**
     Standard initialisation
     
     - Parameter frame: A CGRect describing the desired frame for the UIView. The Kaltura PlayKit will fill this view
     - Returns: A UIView containing an instantiated instance of the Kaltura PlayKit
     */
    public override init(frame: CGRect){
        super.init(frame: frame)
        createPlayer(analytics: nil)
    }
    
    /**
     Standard initialisation
     
     - Parameter frame: A CGRect describing the desired frame for the UIView. The Kaltura PlayKit will fill this view
     - Returns: A UIView containing an instantiated instance of the Kaltura PlayKit
     */
    public init(frame: CGRect, analytics: AMGAnalyticsConfig? = nil){
        super.init(frame: frame)
        createPlayer(analytics: analytics)
    }
    
    /**
     Standard initialisation with Partner ID - The preferred programmatic initialisation
     
     - Parameter frame: A CGRect describing the desired frame for the UIView. The Kaltura PlayKit will fill this view
     - Parameter partnerID: An integer value representing the Partner ID to be used in any played media
     - Returns: A UIView containing an instantiated instance of the Kaltura PlayKit
     
     Partner ID can also be sent separately or as part of media data when loading media
     */
    public init(frame: CGRect, partnerID: Int, analytics: AMGAnalyticsConfig? = nil){
        super.init(frame: frame)
        self.partnerID = partnerID
        createPlayer(analytics: analytics)
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
    
    /**
     For Storyboard instantiation, this should be called manually
     
     - Parameter analytics: A valid AMGAnalyticsConfig object or 'nil' if no analytics is to be used
     */
    public func createPlayer(analytics: AMGAnalyticsConfig? = nil){
        tap = UITapGestureRecognizer(target: self, action: #selector(self.bringControlToForeground(_:)))
        if let analyticsConfig = analytics {
            analyticsConfiguration = analyticsConfig
        }
        setNeedsLayout()
        layoutIfNeeded()
        constructPlayKit()
        setUpOverlays()
        enablePictureInPicture()
    }
    
    public func removePlayer() {
        player.stop()
        player.removeObserver(self, events: [AdEvent.adStarted, PlayerEvent.error, PlayerEvent.errorLog, PlayerEvent.stateChanged, PlayerEvent.play, PlayerEvent.playing, PlayerEvent.pause, PlayerEvent.ended, PlayerEvent.durationChanged])
        if let observer = playHeadObserver {
            player.removePeriodicObserver(observer)
        }
        cancelTimer()
        controlVisibleTimer = nil
        disablePictureInPicture()
        player = nil
        playerView = nil
        self.listener = nil
    }
    
    public func setPlayKitListener(listener: AMGPlayKitListener) {
        self.listener = listener
    }
    
    func constructPlayKit() {
        PlayKitManager.shared.registerPlugin(IMAPlugin.self)
        switch analyticsConfiguration.analyticsService {
        case .AMGANALYTICS:
            PlayKitManager.shared.registerPlugin(AMGAnalyticsPlugin.self)
        case .YOUBORA:
            PlayKitManager.shared.registerPlugin(YouboraPlugin.self)
        default:
            break
        }
       
        
        player = PlayKitManager.shared.loadPlayer(pluginConfig: createPluginConfig())
        player?.addObserver(self, events: [AdEvent.adStarted]) { event in
        //    self.adIsPlaying = true
            self.disableTap()
        }
        player?.addObserver(self, events: [AdEvent.adComplete]) { event in
        //    self.adIsPlaying = false
            self.enableTap()
        }
        player?.addObserver(self, events: [AdEvent.adSkipped]) { event in
        //    self.adIsPlaying = false
            self.enableTap()
        }
        self.player?.addObserver(self, events: [PlayerEvent.error]) { event in
            var knownError = false
            if let data = event.data, let error = data["error"] as? String {
                for possibleError in 7000...7010 {
                    if error.contains("\(possibleError)") {
                        knownError = true
                        if let myError = AMGPlayerError(rawValue: possibleError) {
                            self.listener?.errorOccurred(error: AMGPlayKitError(errorCode: possibleError, errorMessage: myError.errorDescription()))
                        }
                    }
                }
            }
            if !knownError {
                self.listener?.errorOccurred(error: AMGPlayKitError(errorCode: -1, errorMessage: "UNKNOWN_ERROR"))
            }
        }
        
        self.player?.addObserver(self, events: [PlayerEvent.errorLog]) { event in
            var knownError = false
            if let data = event.data, let error = data["error"] as? String {
                for possibleError in 7000...7010 {
                    if error.contains("\(possibleError)") {
                        knownError = true
                        if let myError = AMGPlayerError(rawValue: possibleError) {
                            self.listener?.errorOccurred(error: AMGPlayKitError(errorCode: possibleError, errorMessage: myError.errorDescription()))
                        }
                    }
                }
            }
            if !knownError {
                self.listener?.errorOccurred(error: AMGPlayKitError(errorCode: -1, errorMessage: "UNKNOWN_ERROR"))
            }
        }
        self.player?.addObserver(self, events: [PlayerEvent.stateChanged]) { event in
            
            self.playerState = event.newState
            var newState: AMGPlayerState? = nil
            switch self.playerState{
            case .idle:
                newState = .Idle
            case .ready:
                newState = .Ready
            case .buffering:
                newState = .Buffering
            default:
                break
            }
            
            if let newState = newState {
                self.listener?.loadChangeStateOccurred(state: AMGPlayKitState(state: newState))
            }
            
        }
        self.player?.addObserver(self, events: [PlayerEvent.play]) { event in
            self.playEventOccurred()
            self.listener?.playEventOccurred(state: AMGPlayKitState(state: AMGPlayerState.Play))
        }
        self.player?.addObserver(self, events: [PlayerEvent.playing]) { event in
            self.playEventOccurred()
            self.listener?.playEventOccurred(state: AMGPlayKitState(state: AMGPlayerState.Playing))
        }
        self.player?.addObserver(self, events: [PlayerEvent.pause]) { event in
            self.stopEventOccurred()
            self.listener?.stopEventOccurred(state: AMGPlayKitState(state: AMGPlayerState.Pause))
        }
        self.player?.addObserver(self, events: [PlayerEvent.ended]) { event in
            self.stopEventOccurred()
            self.listener?.stopEventOccurred(state: AMGPlayKitState(state: AMGPlayerState.Ended))
        }
        self.player?.addObserver(self, events: [PlayerEvent.durationChanged]) { event in
            self.changeDuration(length: TimeInterval(event.duration?.doubleValue ?? 0))
            self.listener?.durationChangeOccurred(state: AMGPlayKitState(state: AMGPlayerState.Loaded, duration: TimeInterval(event.duration?.doubleValue ?? 0)))
        }
        playHeadObserver = self.player?.addPeriodicObserver(interval: 0.1, observeOn: DispatchQueue.main, using: { [weak self] (pos) in
            self?.control?.changePlayHead(position: pos)
        })
        playerView = PlayerView.createPlayerView(forPlayer: player)  //PlayerView(frame: frame)
        playerView?.frame = self.bounds
        playerView?.contentMode = .scaleAspectFill
        addSubview(playerView!)
        
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
    
    func createYouboraPlugin() -> AnalyticsConfig {
        var youboraOptions: [String: Any] = [
            "accountCode": analyticsConfiguration.accountCode
        ]
        
        if let name = analyticsConfiguration.userName {
            youboraOptions["username"] = name
        }
        if !analyticsConfiguration.youboraParameters.isEmpty {
            var extraParams: [String: Any] = [:]
            analyticsConfiguration.youboraParameters.forEach {param in
                extraParams["param\(param.id)"] = param.value
            }
            youboraOptions["extraParams"] = extraParams
        }
        
        return AnalyticsConfig(params: youboraOptions) //config  //
    }
    
    func createPluginConfig() -> PluginConfig? {
        
        var config: [String: Any] = [:]
        switch analyticsConfiguration.analyticsService {
        case .AMGANALYTICS:
            config[AMGAnalyticsPlugin.pluginName] = createAnalyticsPlugin()
        case .YOUBORA:
            config[YouboraPlugin.pluginName] = createYouboraPlugin()
        default:
            break
        }
        
        config[IMAPlugin.pluginName] = getIMAPluginConfig()
        
        
        return PluginConfig(config: config)
        // Analytics disabled until the backend is complete
        //return PluginConfig(config: [AMGAnalyticsPlugin.pluginName: createAnalyticsPlugin()])
        // return PluginConfig(config: [IMAPlugin.pluginName: getIMAPluginConfig(adTagUrl: ""), AMGAnalyticsPlugin.pluginName: createAnalyticsPlugin()])
    }
    
    func updatePluginConfig() {
        
       // var config: [String: Any] = [:]
        switch analyticsConfiguration.analyticsService {
        case .AMGANALYTICS:
       //     config[AMGAnalyticsPlugin.pluginName] = createAnalyticsPlugin()
        //    config[IMAPlugin.pluginName] = getIMAPluginConfig()
            player.updatePluginConfig(pluginName: AMGAnalyticsPlugin.pluginName, config: getIMAPluginConfig()) //PluginConfig(config: config))
        case .YOUBORA:
         //   config[YouboraPlugin.pluginName] = createYouboraPlugin()
           // config[IMAPlugin.pluginName] = getIMAPluginConfig()
            player.updatePluginConfig(pluginName: YouboraPlugin.pluginName, config: createYouboraPlugin())//PluginConfig(config: config))
        default:
            break
        }
        
        var imaconfig: [String: Any] = [:]
        imaconfig[IMAPlugin.pluginName] = getIMAPluginConfig()
        player.updatePluginConfig(pluginName: IMAPlugin.pluginName, config: PluginConfig(config: imaconfig))
        
        return
    }
    
    private func loadCurrentMedia() {
        if let media = currentMedia {
            loadMedia(media: media, mediaType: currentMediaType)
        }
    }
    
    //    public func isLive() -> Bool {
    //        return player.isLive()
    //    }
    
    private func loadMedia(media: MediaItem, mediaType: AMGMediaType){
        currentMedia = media
        currentMediaType = mediaType
        if partnerID > 0{
            if let player = player {
                updatePluginConfig()
                player.prepare(media.media())
                if mediaType == .Live{
                    self.currentMediaType = .Live
                    self.controlUI?.setIsLive()
                } else {
                    isLive(){response in
                        DispatchQueue.main.async {
                            if response {
                                self.currentMediaType = .Live
                                self.controlUI?.setIsLive()
                            } else {
                                self.currentMediaType = .VOD
                                self.controlUI?.setIsVOD()
                            }
                        }
                    }
                }
                
                player.play()
            }
        }
    }
    
    /**
     Queues and runs the specified media item if available
     
     - Parameters:
     - serverUrl: The URL the media is hosted on
     - entryID: The unique ID for the media item, as specified by StreamAMG
     - ks: If the media requires a KS to play, it should be passed here, otherwise this should be `nil` or completely ommitted
     */
    public func loadMedia(serverUrl: String, entryID: String, ks: String? = nil, title: String? = nil, mediaType: AMGMediaType = .VOD, drmLicenseURI: String? = nil, drmFPSCertificate: String? = nil){
        var kalturaMediaType: MediaType = .vod
        switch mediaType {
        case .Live, .Live_Audio:
            kalturaMediaType = .dvrLive
            controlUI?.setIsLive()
        default:
            kalturaMediaType = .vod
            controlUI?.setIsVOD()
        }
        
        if partnerID > 0{
            loadMedia(media: MediaItem(serverUrl: serverUrl, partnerId: partnerID, entryId: entryID, ks: ks, title: title, mediaType: kalturaMediaType, drmLicenseURI: drmLicenseURI, drmFPSCertificate: drmFPSCertificate), mediaType: mediaType)
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
    public func loadMedia(serverUrl: String, partnerID: Int, entryID: String, ks: String? = nil, title: String? = nil, mediaType: AMGMediaType = .VOD, drmLicenseURI: String? = nil, drmFPSCertificate: String? = nil){
        self.partnerID = partnerID
        loadMedia(serverUrl: serverUrl, entryID: entryID, ks: ks, title: title, mediaType: mediaType, drmLicenseURI: drmLicenseURI, drmFPSCertificate: drmFPSCertificate)
    }
    
    // IMA
    
    /**
     Attaches an advert to all media played
     
     Once fired, the advert can be cancelled by sending an empty string to this function
     
     - Parameter adTagUrl: The VAST URL of the advert to be consumed
     */
    
    
    public func toggleLive(){
        if currentMediaType == .Live {
            currentMediaType = .VOD
            controlUI?.setIsVOD()
        } else {
            currentMediaType = .Live
            controlUI?.setIsLive()
        }
    }
    
    public func setSpoilerFree(enabled: Bool) {
        controlUI?.setSpoilerFree(enabled)
    }

    public func serveAdvert(adTagUrl: String){
        currentAdvert = adTagUrl
    self.player?.updatePluginConfig(pluginName: IMAPlugin.pluginName, config: getIMAPluginConfig())
    }
    
    private func getIMAPluginConfig() -> IMAConfig {
        let adsConfig = IMAConfig()
        if !currentAdvert.isEmpty {
        adsConfig.set(adTagUrl: currentAdvert)
        }
        return adsConfig
    }
    
    // Player Delegate
    
    /**
     Manually play the queued media track
     */
    public func play() {
        
        if playerState == .idle {
            loadCurrentMedia()
        }
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
     Set the playhead to the 'live' position
     */
    public func goLive() {
        if let duration = player?.duration {
            player?.currentTime = duration - 1
        }
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
    
    
    
    public func playerLayer() -> AVPlayerLayer? {
        return playerView?.layer as? AVPlayerLayer
    }
    
    public func updateYouboraUserID(_ name: String) {
        analyticsConfiguration.userName = name
    }
    
    public func updateYouboraParameter(id: Int, value: String) {
        analyticsConfiguration.updateYouboraParameter(id: id, value: value)
    }
}
