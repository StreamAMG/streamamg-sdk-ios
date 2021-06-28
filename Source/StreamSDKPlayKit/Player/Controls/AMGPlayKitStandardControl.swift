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

public protocol AMGControlDelegate {
    func play()
    func pause()
    func changePlayHead(position: TimeInterval)
    func changeMediaLength(length: TimeInterval)
}

class AMGPlayKitStandardControl: UIView, AMGControlDelegate {

    var isPlaying = true
    var player: AMGPlayerDelegate? = nil
    var playerView: UIView? = nil
    let playPause = UIButton(type: UIButton.ButtonType.custom)
    let forwardButton = UIButton(type: UIButton.ButtonType.custom)
    let backwardButton = UIButton(type: UIButton.ButtonType.custom)
    let fullscreenButton = UIButton(type: UIButton.ButtonType.custom)
    var playImage: UIImage = UIImage()
    var skipForawrdImage: UIImage = UIImage()
    var skipBackwardImage: UIImage = UIImage()
    var pauseImage: UIImage = UIImage()
    var fullScreenImage: UIImage = UIImage()
    var thumb: UIImage = UIImage()
    var scrubBar: UISlider = UISlider()
    
    var scrubBarBackground: UIView = UIView()

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

    var hideFullScreenButtonInFullScreen = false
    var hideFullScreenButton = false

    private var playheadCounter = 0

    private var configModel: AMGPlayKitStandardControlsConfigurationModel = AMGPlayKitStandardControlsConfigurationModel()
    
    private var mainView: UIView = UIView(frame: CGRect.zero)
    private var bottomScrubView: UIView = UIView(frame: CGRect.zero)
    private var bottomScrubViewTrack: UIView = UIView(frame: CGRect.zero)

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
        hideFullScreenButtonInFullScreen = configModel.hideFullscreenOnFS
        
        var trackColour = UIColor.init(red: 0.29, green: 0.761, blue: 0.957, alpha: 1.0)
        
        mainView.frame = CGRect(x: 0, y: 0, width: w, height: h)
        bottomScrubView.frame = CGRect(x: 0, y: h - 2, width: w, height: 2)
        bottomScrubViewTrack.frame = CGRect(x: 0, y: 0, width: 0, height: 2)
        
        bottomScrubView.backgroundColor = .white
        bottomScrubViewTrack.backgroundColor = trackColour
        
        bottomScrubView.addSubview(bottomScrubViewTrack)
        
        addSubview(mainView)
        addSubview(bottomScrubView)
        
        guard let bundleURL = Bundle.main.url(forResource: "AMGPlayKitBundle", withExtension: "bundle") else {
            print("Can't find bundle")
            return
        }
        guard let bundle = Bundle(url: bundleURL) else {
            print("Can't use bundle")
            return
        }
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
        } else if let myImage = UIImage(named: "fullScreenButton", in: bundle, compatibleWith: .none){
            fullScreenImage = myImage
        }
        if let myImage = UIImage(named: "slider_thumb", in: bundle, compatibleWith: .none){
            thumb = myImage
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

        let scrubBarBackY = h-45
        let scrubBarBackX = CGFloat(20)
        let scrubBarBackW = w-40
        let scrubBarBackH = CGFloat(40)
        
        scrubBarBackground = UIView(frame: CGRect(x: scrubBarBackX, y: scrubBarBackY, width: scrubBarBackW, height: scrubBarBackH))
        
        scrubBarBackground.layer.cornerRadius = 10
        scrubBarBackground.backgroundColor = UIColor.init(red: 0.043, green: 0.106, blue: 0.118, alpha: 0.7)
        mainView.addSubview(scrubBarBackground)
        
        

//        switch configModel.slideBarPosition {
//        case .top:
//            scrubBarYPosition = 30
//        case .centre:
//        scrubBarYPosition = y + playPauseSize
//        default:
//            if configModel.trackTimeShowing || configModel.currentTimeShowing {
//                scrubBarYPosition -= 20
//            }
//            break
//        }
        
        var scrubBarx: CGFloat = 20
        var scrubBarw: CGFloat = scrubBarBackW-40
        
        if configModel.trackTimeShowing {
            startTime = timeLabel()
            endTime = timeLabel()
            let endTimeX = scrubBarBackW - endTime.frame.width
            endTime.frame = CGRect(x: endTimeX, y: endTime.frame.origin.y, width: endTime.frame.width, height: endTime.frame.height)
            endTime.textAlignment = .left
            scrubBarBackground.addSubview(startTime)
            scrubBarBackground.addSubview(endTime)
            scrubBarx = startTime.frame.width
            scrubBarw = scrubBarBackW - startTime.frame.width - endTime.frame.width
            trackTimeShowing = true
        } else {
            trackTimeShowing = false
        }

        scrubBar.frame = CGRect(x: scrubBarx, y: 10, width: scrubBarw, height: 20)
        scrubBar.minimumValue = 0
        scrubBar.maximumValue = 100
        scrubBar.addTarget(self, action: #selector(sliderMoved(_:)), for: .allEvents)
        scrubBar.addTarget(self, action: #selector(sliderTouched(_:)), for: .touchDown)
        scrubBar.addTarget(self, action: #selector(sliderReleased(_:)), for: .touchUpInside)
        scrubBar.addTarget(self, action: #selector(sliderReleased(_:)), for: .touchUpOutside)
        scrubBar.setThumbImage(thumb, for: .normal)
        scrubBar.maximumTrackTintColor = trackColour
        scrubBarBackground.addSubview(scrubBar)


//        if configModel.currentTimeShowing {
//            currentTime = timeLabel(position: .centre)
//            addSubview(currentTime)
//            currentTimeShowing = true
//        } else {
//            currentTimeShowing = false
//        }
        
        if !hideFullScreenButton {
        fullscreenButton.frame = CGRect(x: w - skipSize - 20, y: 20, width: skipSize, height: skipSize)
        fullscreenButton.tintColor = UIColor.white
        fullscreenButton.contentMode = .scaleToFill
        fullscreenButton.setImage(fullScreenImage, for: .normal)
        fullscreenButton.addTarget(self, action: #selector(fullScreenToggle), for: .touchUpInside)
            mainView.addSubview(fullscreenButton)
        }
        
        showControls(false)

    }

    func setFullScreen(_ isFS: Bool) {
        isFullScreen = isFS
        if hideFullScreenButton {
            return
        }
        fullscreenButton.isHidden = isFullScreen && hideFullScreenButtonInFullScreen
    }


    private func timeLabel() -> UILabel {
        let x = CGFloat(0)
        let y = CGFloat(0)
        let label = UILabel(frame: CGRect(x: x, y: y, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.text = "00:00:000"
        label.sizeToFit()
        let labelY: CGFloat = (40 - label.frame.height) / 2
        label.frame = CGRect(x: x, y: labelY, width: label.frame.width, height: label.frame.height)
        label.textAlignment = .right
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

    @objc func sliderTouched(_ sender: UISlider){
        updatePlayHeadManually = true
        player?.cancelTimer()
    }

    @objc func sliderReleased(_ sender: UISlider){
        player?.scrub(position: TimeInterval(sender.value))
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
            if currentTimeShowing {
                currentTime.text = timeForDisplay(time: position)
                startTime.text = "00:00"
                endTime.text = timeForDisplay(time: mediaLength)
            } else {
                let timeRemaining = mediaLength - position
                startTime.text = timeForDisplay(time: position)
                endTime.text = timeForDisplay(time: timeRemaining)
            }
        } else if currentTimeShowing {
            currentTime.text = timeForDisplay(time: position)
        }
        }
    }
    
    func setTrackSize(position: TimeInterval) {
        let percentage = position / mediaLength
        let width = frame.width * CGFloat(percentage)
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

        
        
        let scrubBarBackY = h-45
        let scrubBarBackX = CGFloat(20)
        let scrubBarBackW = w-40
        let scrubBarBackH = CGFloat(40)
        
        scrubBarBackground.frame = CGRect(x: scrubBarBackX, y: scrubBarBackY, width: scrubBarBackW, height: scrubBarBackH)
        
        
        var scrubBarx: CGFloat = 20
        var scrubBarw: CGFloat = scrubBarBackW-40
        
        if configModel.trackTimeShowing {
            let endTimeX = scrubBarBackW - endTime.frame.width
            endTime.frame = CGRect(x: endTimeX, y: endTime.frame.origin.y, width: endTime.frame.width, height: endTime.frame.height)
            scrubBarx = startTime.frame.width + 5
            scrubBarw = scrubBarBackW - startTime.frame.width - endTime.frame.width - 10
            trackTimeShowing = true
        } else {
            trackTimeShowing = false
        }

        scrubBar.frame = CGRect(x: scrubBarx, y: 10, width: scrubBarw, height: 20)
        fullscreenButton.frame = CGRect(x: w - skipSize - 20, y: 20, width: skipSize, height: skipSize)
    }
    
    func showControls(_ shouldShow: Bool) {
        mainView.isHidden = !shouldShow
        bottomScrubView.isHidden = shouldShow
    }


}
