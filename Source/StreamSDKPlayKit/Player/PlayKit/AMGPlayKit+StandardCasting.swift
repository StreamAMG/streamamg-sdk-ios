//
//  AMGPlayKit+StandardCasting.swift
//  AMGPlayKit
//
//  Created by Mike Hall on 01/06/2021.
//

import Foundation
import MediaPlayer

extension AMGPlayKit {
    
    public func castingURL(format: AMGMediaFormat = .HLS) -> URL? {
        
            switch format {
            case .MP4:
        if let med = currentMedia, let server = med.serverURL, let asset = URL(string: "\(server)/p/\(med.partnerID)/sp/0/playManifest/entryId/\(med.entryID)/format/url/\(validKS(ks: med.ks))protocol/https/video/mp4"){
            return asset
        }
                
                case .HLS:
                    if let med = currentMedia, let server = med.serverURL, let asset = URL(string: "\(server)/p/\(med.partnerID)/sp/0/playManifest/entryId/\(med.entryID)/format/applehttp/\(validKS(ks: med.ks))protocol/http/manifest.m3u8"){
                return asset
            }
            }
        return nil
    }
    
    public func castingURL(server: String, partnerID: Int, entryID: String, ks: String? = nil, format: AMGMediaFormat = .HLS) -> URL? {
        switch format {
        case .MP4:
        if let asset = URL(string: "\(server)/p/\(partnerID)/sp/0/playManifest/entryId/\(entryID)/format/url/\(validKS(ks: ks))protocol/https/video/mp4"){
            return asset
        }
        case .HLS:
        if let asset = URL(string: "\(server)/p/\(partnerID)/sp/0/playManifest/entryId/\(entryID)/format/applehttp/\(validKS(ks: ks))protocol/http/manifest.m3u8"){
            return asset
        }
        }
        return nil
    }
    
    private func validKS(ks: String?)-> String {
            if let ks = ks {
                return "ks/\(ks)/"
            }
            return ""
        }
}
