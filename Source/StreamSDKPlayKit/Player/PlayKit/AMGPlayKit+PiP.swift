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
    
    public func enablePictureInPicture(delegate: AMGPictureInPictureDelegate? = nil) {
        pipDelegate = delegate
        if AVPictureInPictureController.isPictureInPictureSupported() {
            do {
            try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Error starting PIP - \(error.localizedDescription)")
            }
            guard let playerLayer = playerLayer() else { return }
            pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer)
            pictureInPictureController?.delegate = self
            
            
//            let notificationCenter = NotificationCenter.default
//            notificationCenter.addObserver(self, selector: #selector(enterBackground), name: UIApplication.willResignActiveNotification, object: nil)
//            notificationCenter.addObserver(self, selector: #selector(recoverFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
            
            
            pipPossibleObservation = pictureInPictureController?.observe(\AVPictureInPictureController.isPictureInPicturePossible,
                                                                         options: [.initial, .new]) { [weak self] _, change in
                guard let strongSelf = self else { return }
                strongSelf.pipDelegate?.pictureInPictureStatus(isPossible: change.newValue ?? false)
            }
        } else {
            pipDelegate?.pictureInPictureStatus(isPossible: false)
        }
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
        // Restore user interface
        completionHandler(true)
    }
    
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        pipDelegate?.pictureInPictureWillStart()
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        pipDelegate?.pictureInPictureDidStop()
    }
    
    
    @objc internal func enterBackground(){
//        //pipPlayer = playerLayer()?.player
//        TempPlayer = player.unsafelyUnwrapped
//  //      playerLayer()?.player = nil
//        player = nil
//        print("Test My Layer!")
    }
    
    @objc internal func recoverFromBackground() {
//     //   if let pipPlayer = player { //} , let playLayer = playerLayer() {
//   //         playLayer.player = pipPlayer
//        player = TempPlayer //PlayKitManager.shared.    ////pipPlayer
//  //          playerLayer()?.player = //pipPlayer as! AVPlayer
//  //      }
    }
    
    
    
}

//class PlayerView: UIView {
//    var player: AVPlayer? {
//        get {
//            return playerLayer.player
//        }
//
//        set {
//            playerLayer.player = newValue
//        }
//    }
//
//    var playerLayer: AVPlayerLayer {
//        return layer as! AVPlayerLayer
//    }
//
//    override class var layerClass: AnyClass {
//        return AVPlayerLayer.self
//    }
//}
