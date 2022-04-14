//
//  MediaContext.swift
//  StreamAMG
//
//  Created by Mike Hall on 24/11/2021.
//

import Foundation

public struct MediaContext: Codable {
    public let flavorAssets: [FlavorAsset]
    
    public func fetchBitrates() -> [Int64] {
        return flavorAssets.compactMap {$0.bitrate}.sorted()
    }
}

public struct FlavorAsset: Codable {
    public let width: Int64?
    public let height: Int64?
    public let bitrate: Int64?
    public let id:String?
    public let entryId:String?
}
