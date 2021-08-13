//
//  PlayKitProtocols.swift
//  StreamAMG
//
//  Created by Mike Hall on 20/07/2021.
//

import Foundation

public protocol AMGPlayerDelegate {
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
}


public protocol AMGControlDelegate {
    func play()
    func pause()
    func changePlayHead(position: TimeInterval)
    func changeMediaLength(length: TimeInterval)
}

public protocol AMGPictureInPictureDelegate {
    func pictureInPictureStatus(isPossible: Bool)
    func pictureInPictureWillStart()
    func pictureInPictureDidStop()
}
