//
//  AMGPlayKitStandardControl.swift
//  AMGPlayKit
//
//  Created by Mike Hall on 04/05/2021.
//

import UIKit

/**
 This protocol handles call backs to the controls themselves, including play state and playhead position
 */


class AMGPlayKitStandardControl: UIView, AMGControlDelegate {

    var isPlaying = true
    weak var player: AMGPlayerDelegate? = nil
    var playerView: UIView? = nil
    let playPause = UIButton(type: UIButton.ButtonType.custom)
    let forwardButton = UIButton(type: UIButton.ButtonType.custom)
    let backwardButton = UIButton(type: UIButton.ButtonType.custom)
    let fullscreenButton = UIButton(type: UIButton.ButtonType.custom)
    let minimiseButton = UIButton(type: UIButton.ButtonType.custom)
    let settingsButton = UIButton(type: UIButton.ButtonType.custom)
    var playImage: UIImage = UIImage()
    var skipForawrdImage: UIImage = UIImage()
    var skipBackwardImage: UIImage = UIImage()
    var pauseImage: UIImage = UIImage()
    var fullScreenImage: UIImage = UIImage()
    var settingsImage: UIImage = UIImage()
    var minimiseImage: UIImage = UIImage()
    var thumb: UIImage = UIImage()
    var checkmark: UIImage = UIImage()
    var scrubBar: UISlider = UISlider()
    
    var scrubBarBackground: UIView = UIView()
    var spoilerFreeBackground: UIView = UIView()
    var spoilerFreeTextView: UIView = UIView()
    var spoilerFreeLeftView: UIView = UIView()
    var spoilerFreeRightView: UIView = UIView()
    
    
    var bitrateView: UIView? = nil
    
    
    var liveButton = UIButton()

    var mediaLength: TimeInterval = 0

    var updatePlayHeadManually = false

    var startTime: UILabel = UILabel()
    var endTime: UILabel = UILabel()
    var currentTime: UILabel = UILabel()

    var trackTimeShowing = false
    var currentTimeShowing = false

    var isLiveTag = UIImage()
    var logo = UIImage()

    var isFullScreen = false

    var hideMinimiseButton = false
    var hideFullScreenButton = false
    
    var spoilerFreeEnabled = false
    
    var liveTrackColour: UIColor = UIColor.white
    var vodTrackColour: UIColor = UIColor.white
    
    var isLive = false

    private var playheadCounter = 0

    private var configModel: AMGPlayKitStandardControlsConfigurationModel = AMGPlayKitStandardControlsConfigurationModel()
    
    private var mainView: UIView = UIView(frame: CGRect.zero)
    private var bottomScrubView: UIView = UIView(frame: CGRect.zero)
    private var bottomScrubViewTrack: UIView = UIView(frame: CGRect.zero)
    
    private var bottomTrackEnabled = false
    
    private var bitrates: [FlavorAsset] = []
    private var selectedBitrate = 0
    private var bitrateColors: [UIColor] = []
    
    var bitrateScroll: UIScrollView = UIScrollView(frame: .zero) // UIView = UIView()

    init (hostView: UIView, delegate: AMGPlayerDelegate, config: AMGPlayKitStandardControlsConfigurationModel? = nil){
        super.init(frame: CGRect(x: 0, y: 0, width: hostView.frame.width, height: hostView.frame.height))
        playerView = hostView
        player = delegate
        player?.setControlDelegate(self)
        if let model = config {
            configModel = model
        }
        setUpControls()
    }

    required init?(coder: NSCoder) {
        super.init(frame: CGRect.zero)
        print ("Standard control should not be instantiated via Storyboard")
    }
    
    func setIsLive(){
        setLiveColours()
        isLive = true
        updateIsLive()
    }
    
    func setIsVOD() {
        setVodColours()
        isLive = false
        updateIsLive()
    }
    
    func setIsAudio() {
        setVodColours()
        isLive = false
        updateIsLive()
    }
    
    func setIsAudioLive() {
        setLiveColours()
        isLive = true
        updateIsLive()
    }
    
    internal func setLiveColours(){
        bottomScrubViewTrack.backgroundColor = liveTrackColour
        scrubBar.minimumTrackTintColor = liveTrackColour
        spoilerFreeLeftView.backgroundColor = liveTrackColour
        spoilerFreeRightView.backgroundColor = liveTrackColour
        liveButton.setTitleColor(liveTrackColour, for: .normal)
    }
    
    internal func setVodColours(){
        bottomScrubViewTrack.backgroundColor = vodTrackColour
        scrubBar.minimumTrackTintColor = vodTrackColour
        spoilerFreeLeftView.backgroundColor = vodTrackColour
        spoilerFreeRightView.backgroundColor = vodTrackColour
    }
    
    func setSpoilerFree(_ isSF: Bool){
        spoilerFreeEnabled = isSF
        spoilerFreeBackground.isHidden = !spoilerFreeEnabled
        scrubBarBackground.isHidden = spoilerFreeEnabled
    }

    func setUpControls(){
        // Set up play / pause button images and actions
        let playPauseSize :CGFloat = 60
        let skipSize :CGFloat = 40
        let w = self.frame.width
        let h = self.frame.height
        let x = (w / 2) - (playPauseSize / 2)
        let y = (h / 2) - (playPauseSize / 2)
        let skipY = (h / 2) - (skipSize / 2)
        hideFullScreenButton = configModel.hideFullscreen
        hideMinimiseButton = configModel.hideMinimise
        
       // var trackColour = UIColor.init(red: 0.29, green: 0.761, blue: 0.957, alpha: 1.0)
        if let colour = UIColor.init(amghex: configModel.liveTrack){
        liveTrackColour = colour
        }
        if let colour = UIColor.init(amghex: configModel.vodTrack){
        vodTrackColour = colour
        }
        mainView.frame = CGRect(x: 0, y: 0, width: w, height: h)
        bottomScrubView.frame = CGRect(x: 0, y: h - 2, width: w, height: 2)
        bottomScrubViewTrack.frame = CGRect(x: 0, y: 0, width: 0, height: 2)
        
        bottomScrubView.backgroundColor = .white
        bottomScrubViewTrack.backgroundColor = vodTrackColour
        
        bottomScrubView.addSubview(bottomScrubViewTrack)
        
        addSubview(mainView)
        if bottomTrackEnabled {
        addSubview(bottomScrubView)
        }
        
        guard let bundleURL = Bundle.main.url(forResource: "AMGPlayKitBundle", withExtension: "bundle") else {
            print("Can't find bundle")
            return
        }
        guard let bundle = Bundle(url: bundleURL) else {
            print("Can't use bundle")
            return
        }
        
        guard let fontURL = bundle.url(forResource: "spartan", withExtension: "otf") else {
            print("Spartan font was not found in the module bundle")
            return
        }
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
        
        if let customImage = configModel.playImage, let myImage = UIImage(named: customImage) {
        playImage = myImage
        } else if let myImage = UIImage(named: "standard_ui_playButton", in: bundle, compatibleWith: .none){
        playImage = myImage
        }
        if let customImage = configModel.pauseImage, let myImage = UIImage(named: customImage) {
            pauseImage = myImage
        } else if let myImage = UIImage(named: "standard_ui_pauseButton", in: bundle, compatibleWith: .none){
            pauseImage = myImage
        }
        if let customImage = configModel.skipForwardImage, let myImage = UIImage(named: customImage) {
            skipForawrdImage = myImage
        } else if let myImage = UIImage(named: "skipForwardButton", in: bundle, compatibleWith: .none){
            skipForawrdImage = myImage
        }
        if let customImage = configModel.skipBackwardImage, let myImage = UIImage(named: customImage) {
            skipBackwardImage = myImage
        } else if let myImage = UIImage(named: "skipBackButton", in: bundle, compatibleWith: .none){
            skipBackwardImage = myImage
        }
        if let customImage = configModel.fullScreenImage, let myImage = UIImage(named: customImage) {
            fullScreenImage = myImage
        } else if let myImage = UIImage(named: "fullscrButton", in: bundle, compatibleWith: .none){
            fullScreenImage = myImage
        }
        if let customImage = configModel.minimiseImage, let myImage = UIImage(named: customImage) {
            minimiseImage = myImage
        } else if let myImage = UIImage(named: "minimiseButton", in: bundle, compatibleWith: .none){
            minimiseImage = myImage
        }
//        if let customImage = configModel.minimiseImage, let myImage = UIImage(named: customImage) {
//            minimiseImage = myImage
//        } else
        if let myImage = UIImage(named: "settingsButton", in: bundle, compatibleWith: .none){
            settingsImage = myImage
        }
        if let myImage = UIImage(named: "slider_thumb", in: bundle, compatibleWith: .none){
            thumb = myImage
        }
        if let customImage = UIImage(named: "checkmark", in: bundle, compatibleWith: .none) {
            checkmark = customImage
        }
        
        if let color = UIColor(named: "bitrate_dark_gray", in: bundle, compatibleWith: .none) {
            bitrateColors.append(color)
        }
        if let color = UIColor(named: "bitrate_medium_gray", in: bundle, compatibleWith: .none) {
            bitrateColors.append(color)
        }
        
        playPause.frame = CGRect(x: x, y: y, width: playPauseSize, height: playPauseSize)
        playPause.tintColor = UIColor.white
        playPause.contentMode = .scaleToFill
        playPause.setImage(pauseImage, for: .normal)
        playPause.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        mainView.addSubview(playPause)

        backwardButton.frame = CGRect(x: x - skipSize - 20, y: skipY, width: skipSize, height: skipSize)
        backwardButton.tintColor = UIColor.white
        backwardButton.contentMode = .scaleToFill
        backwardButton.setImage(skipBackwardImage, for: .normal)
        backwardButton.addTarget(self, action: #selector(skipBack), for: .touchUpInside)
        mainView.addSubview(backwardButton)

        forwardButton.frame = CGRect(x: x + playPauseSize + 20, y: skipY, width: skipSize, height: skipSize)
        forwardButton.tintColor = UIColor.white
        forwardButton.contentMode = .scaleToFill
        forwardButton.setImage(skipForawrdImage, for: .normal)
        forwardButton.addTarget(self, action: #selector(skipForward), for: .touchUpInside)
        mainView.addSubview(forwardButton)
        // Add scrub bar

        let scrubBarBackY = h-70
        let scrubBarBackX = CGFloat(20)
        let scrubBarBackW = w-40
        let scrubBarBackH = CGFloat(60)
        
        scrubBarBackground = UIView(frame: CGRect(x: scrubBarBackX, y: scrubBarBackY, width: scrubBarBackW, height: scrubBarBackH))
        //scrubBarBackground.layer.cornerRadius = 10
        //scrubBarBackground.backgroundColor = UIColor.init(red: 0.043, green: 0.106, blue: 0.118, alpha: 0.7) //UIColor.clear //
        mainView.addSubview(scrubBarBackground)
        
        spoilerFreeBackground = UIView(frame: CGRect(x: scrubBarBackX, y: scrubBarBackY, width: scrubBarBackW, height: scrubBarBackH))
        //scrubBarBackground.layer.cornerRadius = 10
        spoilerFreeBackground.backgroundColor = UIColor.clear //UIColor.init(red: 0.043, green: 0.106, blue: 0.118, alpha: 0.7)
        mainView.addSubview(spoilerFreeBackground)
        
        spoilerFreeBackground.isHidden = !spoilerFreeEnabled
        scrubBarBackground.isHidden = spoilerFreeEnabled
        
        let spoilerLabel = UILabel(frame: CGRect(x: x, y: y, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        spoilerLabel.font = UIFont(name: "LeagueSpartan-Bold", size: 12)   //.systemFont(ofSize: 12)
        spoilerLabel.textColor = .white
        spoilerLabel.text = "Spoiler Free"
        spoilerLabel.sizeToFit()
        spoilerLabel.frame = CGRect(x: 60, y: 0, width: spoilerLabel.frame.width, height: 20)
        
        let spoilerFreeImage = UIImage(named: "spoilerfree", in: bundle, compatibleWith: .none)
        let spoilerFreeIcon = UIImageView(frame: CGRect(x: 24, y: 3, width: 18, height: 15))
        spoilerFreeIcon.tintColor = UIColor.white
        spoilerFreeIcon.image = spoilerFreeImage
        spoilerFreeIcon.contentMode = .scaleToFill
        
        spoilerFreeTextView = UIView(frame: CGRect(x: 0, y: 10, width: spoilerLabel.frame.width + 80, height: 20 ))
        
        spoilerFreeTextView.addSubview(spoilerFreeIcon)
        spoilerFreeTextView.addSubview(spoilerLabel)
        
        spoilerFreeBackground.addSubview(spoilerFreeTextView)
        spoilerFreeBackground.addSubview(spoilerFreeLeftView)
        spoilerFreeBackground.addSubview(spoilerFreeRightView)
        
        
        var scrubBarx: CGFloat = 10
        var scrubBarw: CGFloat = scrubBarBackW-20
        
        if configModel.trackTimeShowing {
            startTime = timeLabel()
           // endTime = timeLabel()
//            let endTimeX = scrubBarBackW - endTime.frame.width
//            endTime.frame = CGRect(x: endTimeX, y: endTime.frame.origin.y, width: endTime.frame.width, height: endTime.frame.height)
//            endTime.textAlignment = .left
            scrubBarBackground.addSubview(startTime)
//            scrubBarBackground.addSubview(endTime)
          //  scrubBarx = startTime.frame.width
          //  scrubBarw = scrubBarBackW - startTime.frame.width // - endTime.frame.width
            trackTimeShowing = true
        } else {
            trackTimeShowing = false
        }

        scrubBar.frame = CGRect(x: scrubBarx, y: 5, width: scrubBarw, height: 20)
        scrubBar.minimumValue = 0
        scrubBar.maximumValue = 100
        scrubBar.addTarget(self, action: #selector(sliderMoved(_:)), for: .allEvents)
        scrubBar.addTarget(self, action: #selector(sliderTouched(_:)), for: .touchDown)
        scrubBar.addTarget(self, action: #selector(sliderReleased(_:)), for: .touchUpInside)
        scrubBar.addTarget(self, action: #selector(sliderReleased(_:)), for: .touchUpOutside)
        scrubBar.setThumbImage(thumb, for: .normal)
        scrubBar.maximumTrackTintColor = UIColor.white
        scrubBarBackground.addSubview(scrubBar)
        
        let dummyLiveText = UITextView(frame: CGRect(x: 0,y: 0,width: CGFloat.greatestFiniteMagnitude, height: 20))
        dummyLiveText.font = UIFont(name: "LeagueSpartan-Bold", size: 12)
        dummyLiveText.text = "GO LIVE"
        dummyLiveText.sizeToFit()
        liveButton.titleLabel?.font = UIFont(name: "LeagueSpartan-Bold", size: 12) //.systemFont(ofSize: 12)
        liveButton.setTitleColor(.white, for: .normal)
        liveButton.setTitle("GO LIVE", for: .normal)
        liveButton.frame = CGRect(x: 10, y: 30, width: dummyLiveText.frame.width, height: 20)
        liveButton.addTarget(self, action: #selector(goLive), for: .touchUpInside)
        liveButton.titleLabel?.textAlignment = .left
        scrubBarBackground.addSubview(liveButton)

        
        if !hideFullScreenButton {
            fullscreenButton.frame = CGRect(x: w - skipSize - 20, y: 20, width: skipSize, height: skipSize)
            fullscreenButton.tintColor = UIColor.white
            fullscreenButton.contentMode = .scaleToFill
            fullscreenButton.setImage(fullScreenImage, for: .normal)
            fullscreenButton.addTarget(self, action: #selector(fullScreenToggle), for: .touchUpInside)
            mainView.addSubview(fullscreenButton)
        }
        
        if configModel.bitrateSelector {
            settingsButton.frame = CGRect(x: w - skipSize - 20, y: h - skipSize - 5, width: skipSize, height: skipSize)
            settingsButton.tintColor = UIColor.white
            settingsButton.contentMode = .scaleToFill
            settingsButton.setImage(settingsImage, for: .normal)
            settingsButton.addTarget(self, action: #selector(openBitrateView), for: .touchUpInside)
            settingsButton.layer.cornerRadius = 8
            mainView.addSubview(settingsButton)
        }
        
        updateIsLive()
        updateSpoilerFree()
        showControls(false)
        
        //createBitrateView()

    }

    
    func updateIsLive(){
        var scrubBarx: CGFloat = 10
        let scrubBarBackW = scrubBarBackground.frame.width
        var scrubBarw: CGFloat = scrubBarBackW - 20
        
        if isLive {
            liveButton.isHidden = false
            startTime.isHidden = true
//            scrubBarx = liveButton.frame.width + 5
//            scrubBarw = scrubBarBackW - liveButton.frame.width - 10
        } else {
            liveButton.isHidden = true
            if trackTimeShowing {
                startTime.isHidden = false
//                let endTimeX = scrubBarBackW - endTime.frame.width
//                endTime.frame = CGRect(x: endTimeX, y: endTime.frame.origin.y, width: endTime.frame.width, height: endTime.frame.height)
//                scrubBarx = startTime.frame.width + 5
//                scrubBarw = scrubBarBackW - startTime.frame.width // - endTime.frame.width - 10
            } else {
                
                startTime.isHidden = true
            }
        }
        scrubBar.frame = CGRect(x: scrubBarx, y: 10, width: scrubBarw, height: 20)
    }
    
    
    func updateSpoilerFree(){
        //spoilerFreeBackground.frame = scrubBarBackground.frame
        let halfSize = (spoilerFreeBackground.frame.width - spoilerFreeTextView.frame.width) / 2
        spoilerFreeLeftView.frame = CGRect(x: 0, y: 18, width: halfSize, height: 4)
        spoilerFreeTextView.frame = CGRect(x: halfSize, y: 10, width: spoilerFreeTextView.frame.width, height: 20)
        spoilerFreeRightView.frame = CGRect(x: halfSize + spoilerFreeTextView.frame.width, y: 18, width: halfSize, height: 4)
    }

    func setFullScreen(_ isFS: Bool) {
        isFullScreen = isFS
        if hideFullScreenButton {
            return
        }
        fullscreenButton.isHidden = isFullScreen && hideMinimiseButton
    }


    private func timeLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 10, y: 35, width: 200, height: 20))
        label.font = UIFont(name: "LeagueSpartan-Bold", size: 12)  //.systemFont(ofSize: 8)
        label.textColor = .white
        label.textAlignment = .left
        label.text = ""
        return label
    }

    @objc func sliderMoved(_ sender: UISlider){
        if updatePlayHeadManually {
        playheadCounter += 1
        if playheadCounter % 50 == 0 {
        player?.scrub(position: TimeInterval(sender.value))
        }
        }
    }
    
    @objc func goLive() {
        player?.goLive()
        liveButton.titleLabel?.text = "Live"
    }

    @objc func sliderTouched(_ sender: UISlider){
        updatePlayHeadManually = true
        player?.cancelTimer()
    }

    @objc func sliderReleased(_ sender: UISlider){
        var time: Double = Double(sender.value)
        if time >= mediaLength - 0.5 {
            time = mediaLength - 0.5
        }
        player?.scrub(position: TimeInterval(time))
        updatePlayHeadManually = false
        player?.startControlVisibilityTimer()
    }

    @objc func togglePlayPause() {
        if (isPlaying){
        player?.pause()
        } else {
            player?.play()
        }
    }

    @objc func skipBack() {
        player?.skipBackward()
    }

    @objc func skipForward() {
        player?.skipForward()
    }
    
    @objc func fullScreenToggle() {
        if (isFullScreen){
        player?.minimise()
        } else {
            player?.fullScreen()
        }
    }
    
    
    @objc func closeBitrateView() {
        bitrateView?.removeFromSuperview()
        player?.startControlVisibilityTimer()
        settingsButton.backgroundColor = .clear
    }
    
    
    @objc func openBitrateView() {
        bitrateView = UIView.init(frame: self.bounds)
        bitrateView?.backgroundColor = .clear // UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.3)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeBitrateView))
        bitrateView?.addGestureRecognizer(gesture)
        createBitrateSelector(withBitrateList: bitrates)
        addSubview(bitrateView!)
        player?.cancelTimer()
        settingsButton.backgroundColor = bitrateColors.count > 0 ? bitrateColors.first : UIColor.black
    }

    func play() {
        isPlaying = true
        playPause.setImage(pauseImage, for: .normal)
    }

    func pause() {
        isPlaying = false
        playPause.setImage(playImage, for: .normal)
    }

    func changePlayHead(position: TimeInterval) {
        if !updatePlayHeadManually {
            if position <= 0 {
                scrubBar.value = 0
            } else if position >= mediaLength {
                scrubBar.value = Float(mediaLength)
            } else {
                scrubBar.value = Float(position)
            }
            setTrackSize(position: position)
            if trackTimeShowing {
                startTime.text = "\(timeForDisplay(time: position)) / \(timeForDisplay(time: mediaLength))"
            } else if currentTimeShowing {
                currentTime.text = timeForDisplay(time: position)
            }
        }
        if (position < mediaLength - 1) {
            liveButton.setTitle("GO LIVE", for: .normal)
        } else {
            liveButton.setTitle("LIVE", for: .normal)
        }
    }
    
    func setTrackSize(position: TimeInterval) {
        var width: CGFloat = 0.0
        if position > 0.0 || mediaLength > 0.0 {
        let percentage = position / mediaLength
        width = frame.width * CGFloat(percentage)
        }
        bottomScrubViewTrack.frame = CGRect(x: 0, y: 0, width: width, height: 2)
    }

    func changeMediaLength(length: TimeInterval) {
        mediaLength = length
        scrubBar.maximumValue = Float(length)
        scrubBar.value = 0
        setTrackSize(position: 0)
    }

    func timeForDisplay(time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional  //.full // or .short or .abbreviated
        formatter.allowedUnits = [.second, .minute, .hour]

        var formattedTimeLeft = formatter.string(from: time)!
        let formattedSplit = formattedTimeLeft.split(separator: ":")
        if formattedSplit.count == 1 {
            if formattedSplit[0].count == 1 {
                return "00:0\(formattedSplit[0])"
            } else {
                return "00:\(formattedSplit[0])"
            }
        }
        formattedTimeLeft = ""
        formattedSplit.forEach {split in
            if (formattedTimeLeft.count > 0){
                formattedTimeLeft += ":"
            }
            if split.count == 1 {
                formattedTimeLeft += "0\(split)"
            } else {
                formattedTimeLeft += split
            }
        }
        return formattedTimeLeft
    }

    func resize() {
        let playPauseSize :CGFloat = 60
        let skipSize :CGFloat = 40
        let w = self.frame.width
        let h = self.frame.height
        let x = (w / 2) - (playPauseSize / 2)
        let y = (h / 2) - (playPauseSize / 2)
        let skipY = (h / 2) - (skipSize / 2)
        
        
        mainView.frame = CGRect(x: 0, y: 0, width: w, height: h)
        bottomScrubView.frame = CGRect(x: 0, y: h - 2, width: w, height: 2)
        bottomScrubViewTrack.frame = CGRect(x: 0, y: 0, width: 0, height: 2)
        
        playPause.frame = CGRect(x: x, y: y, width: playPauseSize, height: playPauseSize)

        backwardButton.frame = CGRect(x: x - skipSize - 20, y: skipY, width: skipSize, height: skipSize)

        forwardButton.frame = CGRect(x: x + playPauseSize + 20, y: skipY, width: skipSize, height: skipSize)

        let scrubBarBackY = h-70
        let scrubBarBackX = CGFloat(20)
        let scrubBarBackW = w-40
        let scrubBarBackH = CGFloat(60)
        
        scrubBarBackground.frame = CGRect(x: scrubBarBackX, y: scrubBarBackY, width: scrubBarBackW, height: scrubBarBackH)
        spoilerFreeBackground.frame = CGRect(x: scrubBarBackX, y: scrubBarBackY, width: scrubBarBackW, height: scrubBarBackH)
        

    
        fullscreenButton.frame = CGRect(x: w - skipSize - 20, y: 20, width: skipSize, height: skipSize)
        
        
        settingsButton.frame = CGRect(x: w - skipSize - 20, y: h - skipSize - 5, width: skipSize, height: skipSize)
        
        if (isFullScreen) {
            fullscreenButton.setImage(minimiseImage, for: .normal)
        } else {
            fullscreenButton.setImage(fullScreenImage, for: .normal)
        }
        
        if let bView = bitrateView {
            bView.frame = self.bounds
            self.bitrateScroll.heightAnchor.constraint(equalToConstant: min(bView.frame.height - 10, self.bitrateScroll.contentSize.height)).isActive = true
        }
        
        updateIsLive()
        updateSpoilerFree()
    }
    
    func showControls(_ shouldShow: Bool) {
        mainView.isHidden = !shouldShow
        bottomScrubView.isHidden = shouldShow
        closeBitrateView()
    }
    
    
    
    func createBitrateSelector(withBitrateList: [FlavorAsset]){
        bitrates = withBitrateList
        let maxWidth: CGFloat = 165
        var count = 1
        DispatchQueue.main.async {
            self.bitrateScroll.removeFromSuperview()
            self.bitrateScroll = UIScrollView(frame: .zero)
            self.bitrateScroll.alwaysBounceVertical = false;
            self.bitrateScroll.translatesAutoresizingMaskIntoConstraints = false
            self.bitrateScroll.contentInsetAdjustmentBehavior = .never
            self.bitrateScroll.contentSize = CGSize(width: maxWidth, height: CGFloat(self.bitrates.count + 1) * 48)
            self.bitrateScroll.backgroundColor = .clear
            self.bitrateScroll.layer.cornerRadius = 8
            
            self.createBitrateLabel(text: "Auto", width: maxWidth, index: 0)
            withBitrateList.forEach { bitrate in
                self.createBitrateLabel(text: "\(bitrate.bitrate ?? 0)", width: maxWidth, index: count)
                count += 1
            }
            self.bitrateView?.addSubview(self.bitrateScroll)
            
            if let bView = self.bitrateView {
                self.bitrateScroll.trailingAnchor.constraint(equalTo: bView.trailingAnchor, constant: -65).isActive = true
                self.bitrateScroll.heightAnchor.constraint(equalToConstant: min(bView.frame.height - 10, self.bitrateScroll.contentSize.height)).isActive = true
                self.bitrateScroll.bottomAnchor.constraint(equalTo: bView.bottomAnchor, constant: -5).isActive = true
                self.bitrateScroll.widthAnchor.constraint(equalToConstant: maxWidth).isActive = true
            }
        }
    }
    
    func createBitrateLabel(text: String, width: CGFloat, index: Int) {
        let tText = UIButton(frame: CGRect(x: 0, y: CGFloat(48 * index), width: width, height: 48))
        tText.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        tText.setTitle(text, for: .normal)
        tText.setTitleColor(.white, for: .normal)
        tText.contentHorizontalAlignment = .left
        tText.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        
        if index == selectedBitrate {
            tText.backgroundColor = bitrateColors.count > 0 ? bitrateColors.first : UIColor.black
            tText.setImage(checkmark.withRenderingMode(.alwaysOriginal), for: .normal)
            tText.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            tText.imageEdgeInsets = UIEdgeInsets(top: 0, left: width - 30, bottom: 0, right: 0)
        } else {
            tText.backgroundColor = bitrateColors.count > 1 ? bitrateColors[1] : UIColor.darkGray
        }
        
        tText.tag = index
        tText.addTarget(self, action: #selector(swapBitRate(button:)), for: .touchUpInside)
        
        let divider = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 0.5))
        divider.backgroundColor = bitrateColors.count > 0 ? bitrateColors.first : UIColor.black
        tText.addSubview(divider)
        self.bitrateScroll.addSubview(tText)
    }
    
    func removeStandardView(){
        player = nil
        playerView = nil
    }

    @objc func swapBitRate(button: UIButton) {
        let myTag = button.tag
        if myTag == selectedBitrate || bitrates.count == 0 || tag > bitrates.count {
            closeBitrateView()
            return
        }
        
        if myTag == 0 {
            selectedBitrate = 0
            player?.setMaximumBitrate(bitrate: bitrates.last!)
            closeBitrateView()
            return
        }
        
        selectedBitrate = myTag
        player?.setMaximumBitrate(bitrate: bitrates[myTag - 1])
        closeBitrateView()
        return
    }
}
