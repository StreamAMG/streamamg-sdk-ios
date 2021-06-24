//
//  AMGPlayKitStandardControlsConfigurationModel.swift
//  AMGPlayKit
//
//  Created by Mike Hall on 10/05/2021.
//

import Foundation
/**
 An enum constant defenition to define the position of various UI Control elements in the standard controls
 */
public enum AMGControlPosition: String, Codable {
    case top = "top", bottom = "bottom", left = "left", right = "right", topleft = "topleft", topright = "topright", bottomleft = "bottomleft", bottomright = "bottomright", centre = "centre"

    enum Key: CodingKey {
        case rawValue
    }

    enum CodingError: Error {
        case unknownValue
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Key.self)
        let label = try values.decode(String.self, forKey: .rawValue)
        switch label {
        case "top": self = .top
        case "bottom": self = .bottom
        case "left": self = .left
        case "right": self = .right
        case "topleft": self = .topleft
        case "topright": self = .topright
        case "bottomleft": self = .bottomleft
        case "bottomright": self = .bottomright
        case "centre": self = .centre
        default:
            self = .bottom
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {

        case .top:
            try container.encode("top", forKey: .rawValue)
        case .bottom:
            try container.encode("bottom", forKey: .rawValue)
        case .left:
            try container.encode("left", forKey: .rawValue)
        case .right:
            try container.encode("right", forKey: .rawValue)
        case .topleft:
            try container.encode("topleft", forKey: .rawValue)
        case .topright:
            try container.encode("topright", forKey: .rawValue)
        case .bottomleft:
            try container.encode("bottomleft", forKey: .rawValue)
        case .bottomright:
            try container.encode("bottomright", forKey: .rawValue)
        case .centre:
            try container.encode("centre", forKey: .rawValue)
        }
    }
}

public struct AMGPlayKitStandardControlsConfigurationModel: Codable {
    var fadeInTogglesPausePlay = false
    var fadeInTime = 0
    var fadeOutTime = 0
    var fadeOutAfter = 5000
    var slideBarPosition: AMGControlPosition = .bottom
    var trackTimeShowing = false
    var currentTimeShowing = false

    var isLiveImage: String? = nil
    var logoImage: String? = nil
    var playImage: String? = nil
    var pauseImage: String? = nil
    var skipForwardTime = 5000
    var skipBackwardTime = 5000
    
    var hideFullscreen = false
    var hideFullscreenOnFS = false
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
    var trackTimeShowing = false
    var currentTimeShowing = false
    var skipForwardTime = 5000
    var skipBackwardTime = 5000
    var hideFullscreen = false
    var hideFullscreenOnFS = false


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

    /**
     Toggle the visibility of the current playhead position (the current play time)
     */
    public func setCurrentTimeShowing(_ isOn: Bool) -> AMGControlBuilder {
        currentTimeShowing = isOn
        return self
    }

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
    
    public func hideFullScreenButtonOnFullScreen() -> AMGControlBuilder {
        hideFullscreenOnFS = true
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
        return AMGPlayKitStandardControlsConfigurationModel(fadeInTogglesPausePlay: fadeInTogglesPausePlay, fadeInTime: fadeInTime, fadeOutTime: fadeOutTime, fadeOutAfter: fadeOutAfter, slideBarPosition: slideBarPosition, trackTimeShowing: trackTimeShowing, currentTimeShowing: currentTimeShowing, hideFullscreen: hideFullscreen, hideFullscreenOnFS: hideFullscreenOnFS)
    }

}
