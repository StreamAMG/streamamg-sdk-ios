//
//  AMGPlayKitStandardControlsConfigurationModel.swift
//  AMGPlayKit
//
//  Created by Mike Hall on 10/05/2021.
//

import Foundation


public struct AMGPlayKitStandardControlsConfigurationModel: Codable {
    var fadeInTogglesPausePlay = false
    var fadeInTime = 0
    var fadeOutTime = 0
    var fadeOutAfter = 5000
 //   var slideBarPosition: AMGControlPosition = .bottom
    var trackTimeShowing = true
 //   var currentTimeShowing = false

    var isLiveImage: String? = nil
    var logoImage: String? = nil
    var playImage: String? = nil
    var pauseImage: String? = nil
    var skipForwardImage: String? = nil
    var skipBackwardImage: String? = nil
    var fullScreenImage: String? = nil
    var minimiseImage: String? = nil
    var skipForwardTime = 10000
    var skipBackwardTime = 10000
    
    var hideFullscreen = false
    var hideMinimise = false
    
    var liveTrack = "#D0FF39"
    var vodTrack = "#71ABF3"
    
    
}

/**
 Builder class for the AMGPlayKitStandardControlsConfigurationModel structure

 This is used when configuring the standard UI Control class for a more customisable look and feel
 */
public class AMGControlBuilder {

    public init() {}

    var fadeInTogglesPausePlay = false
    var fadeInTime = 0
    var fadeOutTime = 0
    var fadeOutAfter = 5000
    var slideBarPosition: AMGControlPosition = .bottom
    var trackTimeShowing = true
//    var currentTimeShowing = false
    var skipForwardTime = 5000
    var skipBackwardTime = 5000
    var hideFullscreen = false
    var hideMinimise = false
    var isLiveImage: String? = nil
    var logoImage: String? = nil
    var playImage: String? = nil
    var pauseImage: String? = nil
    var skipForwardImage: String? = nil
    var skipBackwardImage: String? = nil
    var fullScreenImage: String? = nil
    var minimiseImage: String? = nil

    
    /**
    Specify the image to use for the play button
     */
    public func playImage(_ image: String) -> AMGControlBuilder {
        self.playImage = image
        return self
    }
    
    /**
    Specify the image to use for the pause button
     */
    public func pauseImage(_ image: String) -> AMGControlBuilder {
        self.pauseImage = image
        return self
    }
    
    /**
    Specify the image to use for the fullscreen button
     */
    public func fullScreenImage(_ image: String) -> AMGControlBuilder {
        self.fullScreenImage = image
        return self
    }
    
    /**
    Specify the image to use for the skip forwards button
     */
    public func skipForwardImage(_ image: String) -> AMGControlBuilder {
        self.skipForwardImage = image
        return self
    }
    
    /**
    Specify the image to use for the skip backward button
     */
    public func skipBackwardImage(_ image: String) -> AMGControlBuilder {
        self.skipBackwardImage = image
        return self
    }
    
    /**
    Specify the image to use for the 'is live'
     */
    public func isLiveImage(_ image: String) -> AMGControlBuilder {
        self.isLiveImage = image
        return self
    }
    
    /**
    Specify the image to use for the logo / watermark
     */
    public func logoImage(_ image: String) -> AMGControlBuilder {
        self.logoImage = image
        return self
    }

    /**
     Not currently supported

     Toggle whether the current media toggles play state when the controls are made visible
     */
    public func setFadeInToggleOn(_ isOn: Bool) -> AMGControlBuilder {
        fadeInTogglesPausePlay = isOn
        return self
    }

    /**
     Not currently supported

     Set the duration of the fade in animation of the controls in miliseconds
     */
    public func setFadeInTime(_ time: Int) -> AMGControlBuilder {
        fadeInTime = time
        return self
    }

    /**
     Not currently supported

     Set the duration of the fade out animation of the controls in miliseconds
     */
    public func setFadeOutTime(_ time: Int) -> AMGControlBuilder {
        fadeOutTime = time
        return self
    }

    /**
     Set the delay, in miliseconds, of the inactivity timer before hiding the controls
     */
    public func setHideDelay(_ time: Int) -> AMGControlBuilder {
        fadeOutAfter = time
        return self
    }

    /**
     Set the position of the scrub bar on the player, can be one of .top, .middle or .bottom
     All other AMGControlPosition values will default to using .bottom
     */
    public func setSlideBarPosition(_ position: AMGControlPosition) -> AMGControlBuilder {
        switch position {
        case .top, .centre, .bottom:
        slideBarPosition = position
        default:
        slideBarPosition = .bottom
        }
        return self
    }

    /**
     Toggle the visibility of the current track time
     If the current play time toggle is on, this will display the start as 00:00 and the end as the duration of the media
     If the current play time toggle is off, this will display the start as the CURRENT time and the end as the time remaining
     */
    public func setTrackTimeShowing(_ isOn: Bool) -> AMGControlBuilder {
        trackTimeShowing = isOn
        return self
    }

//    /**
//     Toggle the visibility of the current playhead position (the current play time)
//     */
//    public func setCurrentTimeShowing(_ isOn: Bool) -> AMGControlBuilder {
//        currentTimeShowing = isOn
//        return self
//    }

    /**
    Set the time skipped for backward and forward skip in miliseconds
     */
    public func setSkipTime(_ time: Int) -> AMGControlBuilder {
        skipForwardTime = time
        skipBackwardTime = time
        return self
    }

    /**
    Set the time skipped for forward skip in miliseconds
     */
    public func setSkipForwardTime(_ time: Int) -> AMGControlBuilder {
        skipForwardTime = time
        return self
    }

    /**
    Set the time skipped for backward skip in miliseconds
     */
    public func setSkipBackwardTime(_ time: Int) -> AMGControlBuilder {
        skipBackwardTime = time
        return self
    }
    
    public func hideMinimiseButton() -> AMGControlBuilder {
        hideMinimise = true
        return self
    }

    public func hideFullScreenButton() -> AMGControlBuilder {
        hideFullscreen = true
        return self
    }


    /**
     Returns a complete and valid AMGPlayKitStandardControlsConfigurationModel
     */
    public func build() -> AMGPlayKitStandardControlsConfigurationModel {
        return AMGPlayKitStandardControlsConfigurationModel(fadeInTogglesPausePlay: fadeInTogglesPausePlay, fadeInTime: fadeInTime, fadeOutTime: fadeOutTime, fadeOutAfter: fadeOutAfter, trackTimeShowing: trackTimeShowing, isLiveImage: isLiveImage, logoImage: logoImage, playImage: playImage, pauseImage: pauseImage, skipForwardImage: skipForwardImage, skipBackwardImage: skipBackwardImage, fullScreenImage: fullScreenImage, hideFullscreen: hideFullscreen, hideMinimise: hideMinimise)
        
        
        
        //return AMGPlayKitStandardControlsConfigurationModel(fadeInTogglesPausePlay: fadeInTogglesPausePlay, fadeInTime: fadeInTime, fadeOutTime: fadeOutTime, fadeOutAfter: fadeOutAfter, slideBarPosition: slideBarPosition, trackTimeShowing: trackTimeShowing, currentTimeShowing: currentTimeShowing, hideFullscreen: hideFullscreen, hideFullscreenOnFS: hideFullscreenOnFS)
    }

}
