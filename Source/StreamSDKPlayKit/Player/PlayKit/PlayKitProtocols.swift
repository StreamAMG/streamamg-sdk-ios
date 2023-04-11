//
//  PlayKitProtocols.swift
//  StreamAMG
//
//  Created by Mike Hall on 20/07/2021.
//

import Foundation
import PlayKit

public protocol AMGPlayerDelegate: AnyObject {
    func play()
    func pause()
    func scrub(position: TimeInterval)
    func skipForward()
    func skipBackward()
    func setControlDelegate(_ delegate: AMGControlDelegate)
    func cancelTimer()
    func startControlVisibilityTimer()
    func goLive()
    func minimise()
    func fullScreen()
    func setBitrateAuto()
    func setMaximumBitrate(bitrate: FlavorAsset?)
    func setTrack(track: Track)
}


public protocol AMGControlDelegate: AnyObject {
    func play()
    func pause()
    func changePlayHead(position: TimeInterval)
    func changeMediaLength(length: TimeInterval)
}

public protocol AMGPictureInPictureDelegate: AnyObject {
    func pictureInPictureStatus(isPossible: Bool)
    func pictureInPictureWillStart()
    func pictureInPictureDidStop()
}

public protocol AMGCustomLayoutDelegate: AnyObject {
    func setControlsListener(controlsListener : AMGPlayKitControlsListener)
    func updateFullScreen(isFullScreen: Bool)
    func setPlayerFrame(frame : CGRect)
}
