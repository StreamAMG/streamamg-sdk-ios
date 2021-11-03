//
//  AMGPlayKit+PlayKit2Go.swift
//  StreamAMG
//
//  Created by Mike Hall on 14/10/2021.
//

import Foundation
import PlayKit

extension AMGPlayKit {
    
    public func loadPlayKit2GoMedia(entryID: String) -> Bool {
        guard let url = PlayKit2Go.instance.playbackURL(entryID: entryID) else {
            print("Error returning media")
            return false
        }
        let mediaEntry = LocalAssetsManager.managerWithDefaultDataStore().createLocalMediaEntry(for: entryID, localURL: url)
        controlUI?.setIsVOD()
           player.prepare(MediaConfig(mediaEntry: mediaEntry))
           player.play()
        return true
    }
    
}
