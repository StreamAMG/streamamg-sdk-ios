//
//  MediaContext.swift
//  StreamAMG
//
//  Created by Mike Hall on 24/11/2021.
//

import Foundation

public struct MediaContext: Codable {
    public let flavorAssets: [FlavorAsset]
    
    public func fetchBitrates() -> [FlavorAsset] {
        return flavorAssets.sorted(by: {$0.width ?? 0 < $1.width ?? 0})
    }
}

public struct FlavorAsset: Codable, Equatable {
    public let width: Int64?
    public let height: Int64?
    public let bitrate: Int64?
    public let id:String?
    public let entryId:String?
}
