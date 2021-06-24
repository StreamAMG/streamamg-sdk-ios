//
//  AMGPlayKit+Orientation.swift
//  AMGPlayKit
//
//  Created by Mike Hall on 11/06/2021.
//

import Foundation
import UIKit


extension AMGPlayKit {
    func resizeScreen(){
        playerView?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        controlUI?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        controlUI?.resize()
    }
}
