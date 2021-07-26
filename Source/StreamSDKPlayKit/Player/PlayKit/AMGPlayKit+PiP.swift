//
//  AMGPlayKit+PiP.swift
//  StreamAMG
//
//  Created by Mike Hall on 20/07/2021.
//

import Foundation
import AVKit
import PlayKit

extension AMGPlayKit: AVPictureInPictureControllerDelegate {
    
    internal func enablePictureInPicture() {
        if AVPictureInPictureController.isPictureInPictureSupported() {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.allowAirPlay,.allowBluetoothA2DP])
            guard let playerLayer = playerLayer() else { return }
            pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer)
            pictureInPictureController?.delegate = self
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(enterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            pipPossibleObservation = pictureInPictureController?.observe(\AVPictureInPictureController.isPictureInPicturePossible,
                                                                         options: [.initial, .new]) { [weak self] _, change in
                guard let strongSelf = self else { return }
                strongSelf.pipDelegate?.pictureInPictureStatus(isPossible: change.newValue ?? false)
            }
        } else {
            pipDelegate?.pictureInPictureStatus(isPossible: false)
        }
    }
    
    public func setPictureInPictureDelegate(_ delegate: AMGPictureInPictureDelegate) {
        pipDelegate = delegate
    }
    
    public func disablePictureInPicture(){
        pipPossibleObservation = nil
        pictureInPictureController?.delegate = nil
        pictureInPictureController = nil
        pipDelegate = nil
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    public func togglePictureInPicture(){
        if let pipcontroller = self.pictureInPictureController,
           pipcontroller.isPictureInPictureActive {
            self.pictureInPictureController?.stopPictureInPicture()
        } else {
            self.pictureInPictureController?.startPictureInPicture()
        }
    }
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController,
                                    restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        pipDelegate?.pictureInPictureWillStart()
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        pipDelegate?.pictureInPictureDidStop()
    }
    
    @objc internal func enterBackground(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
        self.player.play()
        }
    }
}
