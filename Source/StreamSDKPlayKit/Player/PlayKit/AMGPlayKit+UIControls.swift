//
//  AMGPlayKit+UIControls.swift
//  AMGPlayKit
//
//  Created by Mike Hall on 27/05/2021.
//

import UIKit

extension AMGPlayKit {
    
    /**
        Configures the player to use the baked in standard controls, using an optional configuration file
     
        - Parameter config: A configuration model created by either deserializing a JSON file, or by creation with the AMGControlBuilder builder class
     */
    public func addStandardControl(config: AMGPlayKitStandardControlsConfigurationModel? = nil) {
        var controlConfig = AMGPlayKitStandardControlsConfigurationModel()
        if let config = config {
            controlConfig = config
        }
    controlUI = AMGPlayKitStandardControl(hostView: self, delegate: self, config: controlConfig)
        controlVisibleDuration = TimeInterval(controlConfig.fadeOutAfter) / 1000
        //controlUI?.alpha = 0.0
        controlUI?.showControls(false)
        skipForwardTime = TimeInterval(controlConfig.skipForwardTime) / 1000
        skipBackwardTime = TimeInterval(controlConfig.skipBackwardTime) / 1000
        controlUI?.isUserInteractionEnabled = true
        enableTap()
       addSubview(controlUI!)
    }
    
    func enableTap() {
        if let tap = tap {
        self.addGestureRecognizer(tap)
            controlUI?.isUserInteractionEnabled = true
        }
    }
    
    func disableTap() {
        if let tap = tap {
        self.removeGestureRecognizer(tap)
            controlUI?.isUserInteractionEnabled = false
        }
    }
    
    @objc func bringControlToForeground(_ sender: UITapGestureRecognizer) {
        controlUI?.showControls(true)
        startControlVisibilityTimer()
    }
    
    func setUpOverlays() {
        addImageToImageView(image: UIImage(), view: isLiveImageView, x: 10, y: 10, w: 70)
        addImageToImageView(image: UIImage(), view: logoImageView, x: self.frame.width - 10 - 70, y: 10, w: 70)
        
        addSubview(isLiveImageView)
        addSubview(logoImageView)
    }
    
    internal func addImageToImageView(image: UIImage, view: UIImageView, x: CGFloat = 0, y: CGFloat = 0, w: CGFloat = 150){
        if image.size.height > 0 {
        let ratio = image.size.width / image.size.height
        let imageHeightAtWidth = w / ratio
        view.frame = CGRect(x: x, y: y, width: w, height: imageHeightAtWidth)
        }
        view.image = image
        view.isHidden = true
    }

    /**
        Manually start the fade out timer for overlayed UI controls
     */
    public func startControlVisibilityTimer(){
        cancelTimer()
        controlVisibleTimer = Timer.scheduledTimer(timeInterval: controlVisibleDuration, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
    }
    
    @objc func hideControls(){
        controlUI?.showControls(false)
    }
    
    /**
        Manually halt the fade out timer for overlayed UI controls - the timer will not restart until another action that starts it occurs
     */
    public func cancelTimer() {
        if let timer = controlVisibleTimer {
            timer.invalidate()
        }
    }
    
    // Is Live Image manipulation
    
    /**
     Define the status of the 'is live' badge - the badge must be added via either of the 'setIsLiveImage' functions previous to this happening
     */
    public func setiSliveImageShowing(_ shouldShow: Bool){
        isLiveImageView.isHidden = !shouldShow
    }
    
    /**
     Sets the 'is live' image for display int he top left corner of the player using a named asset from the app's asset catalogue
     */
    public func setIsLiveImage(named: String, atWidth: CGFloat = 70){
        fetchImageForViewNamed(view: isLiveImageView, named: named, atWidth: atWidth)
    }
    
    /**
     Sets the 'is live' image for display int he top left corner of the player by defining the URL (as a string)
     */
    public func setIsLiveImage(url: String, atWidth: CGFloat = 70){
        fetchImageForViewFrom(view: isLiveImageView, url: url, atWidth: atWidth)
    }
    
    // Logo image manipulation
    
    /**
     Define the status of the 'logo' badge - the badge must be added via either of the 'setLogoImage' functions previous to this happening
     */
    public func setlogoImageShowing(_ shouldShow: Bool){
        logoImageView.isHidden = !shouldShow
    }
    
    /**
     Sets the 'logo' image for display int he top right corner of the player using a named asset from the app's asset catalogue
     */
    public func setLogoImage(named: String, atWidth: CGFloat = 70){
        fetchImageForViewNamed(view: logoImageView, named: named, atWidth: atWidth)
    }
    
    /**
     Sets the 'logo' image for display int he top right corner of the player by defining the URL (as a string)
     */
    public func setLogoImage(url: String, atWidth: CGFloat = 70){
        fetchImageForViewFrom(view: logoImageView, url: url, atWidth: atWidth)
    }
    
    
    internal func fetchImageForViewFrom(view: UIImageView, url: String, atWidth: CGFloat){
        DispatchQueue.global().async { [weak self] in
            if let urlFormString = URL(string: url), let data = try? Data(contentsOf: urlFormString) {
                if let myImage = UIImage(data: data) {
                    DispatchQueue.main.async { [self] in
                        if let self = self {
                            let imageWidth = atWidth
                            self.addImageToImageView(image: myImage, view: view, x: self.frame.width - 10 - imageWidth, y: 10, w: imageWidth)
                        }
                    }
                }
            }
        }
    }
    
    
    internal func fetchImageForViewNamed(view: UIImageView, named: String, atWidth: CGFloat){
        if let myImage = UIImage(named: named) {
            let imageWidth = atWidth
            self.addImageToImageView(image: myImage, view: view, x: self.frame.width - 10 - imageWidth, y: 10, w: imageWidth)
        }
    }
    
    
}
