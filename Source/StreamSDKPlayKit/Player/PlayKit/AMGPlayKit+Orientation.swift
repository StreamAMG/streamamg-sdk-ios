//
//  AMGPlayKit+Orientation.swift
//  AMGPlayKit
//
//  Created by Mike Hall on 11/06/2021.
//

import Foundation
import UIKit


extension AMGPlayKit {
    
    
    override public var bounds: CGRect {
        didSet {
            resizeScreen()
        }
    }
    
    override public var frame: CGRect {
        didSet {
            resizeScreen()
        }
    }
    
    func resizeScreen(){
        
        playerView?.frame = self.bounds
        controlUI?.frame = self.bounds
        
        var isInFullScreen = false
        /// Checking current player rotation status
        if UIApplication.shared.statusBarOrientation.isLandscape {
            isInFullScreen = true
        } else {
            isInFullScreen = false
        }
        
        self.controlUI?.setFullScreen(isInFullScreen)
        
        controlUI?.resize()
    }
    
    public func minimise() {
        DispatchQueue.main.async { [self] in
            if orientationTime > Date().timeIntervalSince1970 - 1.0 {
                return
            }
            orientationTime = Date().timeIntervalSince1970
            
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                UIApplication.shared.inputViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                UIApplication.shared.inputViewController?.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            } else {
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
            
            resizeScreen()
            playerView?.layoutIfNeeded()
        }
    }
    
    public func fullScreen() {
        DispatchQueue.main.async {
            if self.orientationTime > Date().timeIntervalSince1970 - 1.0 {
                return
            }
            
            self.orientationTime = Date().timeIntervalSince1970
            
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let orientation = windowScene?.interfaceOrientation
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation == .portrait ? .landscape : .portrait))
                UIApplication.shared.inputViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                UIApplication.shared.inputViewController?.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            } else {
                var value = UIInterfaceOrientation.landscapeRight.rawValue
                if UIApplication.shared.statusBarOrientation == .landscapeLeft {
                    value = UIInterfaceOrientation.landscapeLeft.rawValue
                }
                
                UIDevice.current.setValue(value, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
            
            self.resizeScreen()
            self.playerView?.layoutIfNeeded()
        }
    }
    
}
