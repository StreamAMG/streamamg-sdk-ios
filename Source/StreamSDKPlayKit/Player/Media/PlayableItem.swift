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
    var mediaTitle: String? { get }
    var captionAssets: CaptionAssetElement? { get }
    
    var drmLicenseURI: String? { get }
    var drmFPSCertificate: String? { get }
    
}


public extension PlayableItem {
    
    
    var contentURL: URL?{
        guard let serverURL = serverURL else {
            return nil
        }
   return URL(string:"\(serverURL)/p/\(partnerID)/sp/\(partnerID)00/playManifest/entryId/\(entryID)/format/applehttp/protocol/http/a.m3u8?ks=\(ks ?? "")")
    }
    
    var castURL: URL?{
        guard let serverURL = serverURL else {
            return nil
        }
    
        
        
        return URL(string: "\(serverURL)/index.php/extwidget/preview/partner_id/\(partnerID)/uiconf_id/\(uiConfID)/entry_id/\(entryID)/embed/iframe?flashvars[streamerType]=auto&ks=\(ks ?? "")")
    }

    
    var mediaEntry: PKMediaEntry {
        let source = PKMediaSource(self.entryID, contentUrl: self.contentURL, drmData: self.drmParams, mediaFormat: .hls)
        let mediaEntry = PKMediaEntry(self.entryID, sources: [source])
        mediaEntry.mediaType = mediaType
        mediaEntry.name = self.mediaTitle
        if let captionAssetsExist = self.captionAssets {
            mediaEntry.externalSubtitles = externalSubtitlesList(list: captionAssetsExist, duration: mediaEntry.duration)
        }
       
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
    
    
    /// Generates URL for the API to serve caption by its id converting it to segmented WebVTT.
    /// - Parameters:
    ///   - list: list of CaptionAssetElement
    ///   - duration: duration of the video
    /// - Returns: List of PKExternalSubtitle
    func externalSubtitlesList(list: CaptionAssetElement, duration:TimeInterval) -> [PKExternalSubtitle]?{
        
        guard let objectExist = list.objects else {
            return nil
        }
        var externalSubtitles:[PKExternalSubtitle] = []
        
        for value in objectExist{
            guard let serverURL = serverURL, let captionAssetID = value.id, let languageName = value.language, let languageCode = value.languageCode else {
                break
            }
            
            let url = "\(serverURL)/api_v3/index.php/service/caption_captionasset/action/serveWebVTT/captionAssetId/\(captionAssetID)/segmentIndex/-1/version/2/captions.vtt"
            externalSubtitles.append(PKExternalSubtitle(id: captionAssetID, name: languageName, language: languageCode, vttURLString: url, duration: 512))
        }
        
        return externalSubtitles
        
    }
}
