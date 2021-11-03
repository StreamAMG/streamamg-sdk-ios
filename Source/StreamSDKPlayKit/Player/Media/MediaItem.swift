//
//  MediaItem.swift
//  AMGPlayKit
//
//  Created by Mike Hall on 29/03/2021.
//

import Foundation
import PlayKit

class MediaItem: PlayableItem {
    var serverURL: URL?
    var partnerID: Int
    var uiConfID: Int = -1
    var entryID: String
    var ks: String?
    var mediaType: MediaType = .vod
    var drmLicenseURI: String? = nil
    var drmFPSCertificate: String? = nil
    var mediaTitle: String? = nil
    
    init(serverUrl: String, partnerId: Int, entryId: String,ks: String? = nil, title: String? = nil, mediaType: MediaType = .vod, drmLicenseURI: String? = nil, drmFPSCertificate: String? = nil) {
        self.serverURL = URL(string: serverUrl) ?? nil
        self.partnerID = partnerId
        self.entryID = entryId
        self.ks = ks
        self.mediaType = mediaType
        self.drmLicenseURI = drmLicenseURI
        self.drmFPSCertificate = drmFPSCertificate
        self.mediaTitle = title
    }
    
    func media() -> MediaConfig {
        return mediaConfig
    }
}
