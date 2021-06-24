//
//  PlayableItem.swift
//  playkitdemo
//
//  Created by Sam Easterby-Smith on 02/12/2020.
//

import Foundation
import PlayKit

public protocol PlayableItem {
    var serverURL: URL? { get }
    var partnerID: Int { get }
    var uiConfID: Int { get }
    var entryID: String { get }
    var ks: String? { get }
    var mediaType: MediaType { get }
    
    var drmLicenseURI: String? { get }
    var drmFPSCertificate: String? { get }
    
}


public extension PlayableItem {
    
    
    var contentURL: URL?{
        guard let serverURL = serverURL else {
            return nil
        }
        //    return URL(string: "https://storage.googleapis.com/interactive-media-ads/media/bbb/1428000/playlist.m3u8")
        //  return URL(string: "https://storage.googleapis.com/interactive-media-ads/media/bbb.m3u8")
   return URL(string:"\(serverURL)/p/\(partnerID)/sp/\(partnerID)00/playManifest/entryId/\(entryID)/format/applehttp/protocol/http/a.m3u8?ks=\(ks ?? "")")
    }
    
    var castURL: URL?{
        guard let serverURL = serverURL else {
            return nil
        }
        
        return URL(string: "https://open.http.mp.streamamg.com/index.php/extwidget/preview/partner_id/\(partnerID)/uiconf_id/\(uiConfID)/entry_id/\(entryID)/embed/iframe?flashvars[streamerType]=auto&ks=\(ks ?? "")")
//        return URL(string:"\(serverURL)/p/\(partnerID)/sp/\(partnerID)00/playManifest/entryId/\(entryID)/format/applehttp/protocol/http/a.m3u8?ks=\(ks ?? "")")
    }
    
    //https://open.http.mp.streamamg.com/index.php/extwidget/preview/partner_id/3000557/uiconf_id/30024970/entry_id/0_7q5hg59p/embed/iframe?flashvars[streamerType]=auto

    
    var mediaEntry: PKMediaEntry {
        let source = PKMediaSource(self.entryID, contentUrl: self.contentURL, drmData: self.drmParams, mediaFormat: .hls)
        print("URL = \(contentURL)")
        let mediaEntry = PKMediaEntry(self.entryID, sources: [source])
        mediaEntry.mediaType = mediaType
        return mediaEntry
    }
    
    var mediaConfig: MediaConfig {
        return MediaConfig(mediaEntry: mediaEntry)
    }
    
    var drmParams: [DRMParams]? {
        guard let drmlicenseURI = self.drmLicenseURI,
              let drmFPSCertificate = self.drmFPSCertificate,
              let url = URL(string: drmFPSCertificate)
        else { return nil }
        
        do {
            let cerData = try Data(contentsOf: url)
            let base64Certificate = cerData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

            return [FairPlayDRMParams(licenseUri: drmlicenseURI, base64EncodedCertificate: base64Certificate)]
        } catch {
            return nil
        }
    }
}
