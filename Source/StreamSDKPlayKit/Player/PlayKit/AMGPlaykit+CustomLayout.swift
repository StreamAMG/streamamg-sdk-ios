//
//  AMGPlaykit+CustomLayout.swift
//  StreamAMG
//
//  Created by Zachariah Tom on 18/11/2022.
//

import Foundation

extension AMGPlayKit : AMGCustomLayoutDelegate {
    
    public func setControlsListener(controlsListener : AMGPlayKitControlsListener) {
        self.controlsListener = controlsListener
    }
    
    public func updateFullScreen(isFullScreen: Bool) {
        self.controlUI?.setFullScreen(isFullScreen)
    }
    
    public func setPlayerFrame(frame : CGRect) {
        DispatchQueue.main.async { [self] in
            self.frame = frame
            playerView?.frame = frame
            controlUI?.frame = frame
            controlUI?.resize()
            playerView?.layoutSubviews()
        }
    }
}
