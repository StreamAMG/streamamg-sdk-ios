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
        if #available(iOS 13.0, *) {
            self.controlUI?.setFullScreen(UIDevice.current.orientation.isValidInterfaceOrientation ? UIDevice.current.orientation.isLandscape : (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape ?? false))
        } else {
            self.controlUI?.setFullScreen(UIDevice.current.orientation.isValidInterfaceOrientation ? UIDevice.current.orientation.isLandscape : UIApplication.shared.statusBarOrientation.isLandscape)
        }
        controlUI?.resize()
    }
    
    public func minimise() {
        if orientationTime > Date().timeIntervalSince1970 - 1.0 {
            return
        }
        orientationTime = Date().timeIntervalSince1970
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        controlUI?.setFullScreen(false)
        resizeScreen()
        playerView?.layoutIfNeeded()
    }
    
    public func fullScreen() {
        if orientationTime > Date().timeIntervalSince1970 - 1.0 {
            return
        }
        orientationTime = Date().timeIntervalSince1970
        var value = UIInterfaceOrientation.landscapeRight.rawValue
        if UIApplication.shared.statusBarOrientation == .landscapeLeft {
            value = UIInterfaceOrientation.landscapeLeft.rawValue
        }
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        controlUI?.setFullScreen(true)
        resizeScreen()
        playerView?.layoutIfNeeded()
    }
    
}
