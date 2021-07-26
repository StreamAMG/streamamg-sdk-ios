//
//  AMGPlayKit+StandardCasting.swift
//  AMGPlayKit
//
//  Created by Mike Hall on 01/06/2021.
//

import Foundation
//import GoogleCast
import MediaPlayer

extension AMGPlayKit {
    
    public func castingURL() -> URL? {
        if let avPlayer = playerLayer()?.player {
            if let asset = avPlayer.currentItem!.asset as? AVURLAsset{
                return asset.url
            }
        }
        return nil
    }
}
