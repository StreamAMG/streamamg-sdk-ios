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
        var uniqueAssets: [Int: FlavorAsset] = [:] // Dictionary to store unique assets by height
        
        for flavorAsset in flavorAssets {
            if let height = flavorAsset.height {
                if let existingAsset = uniqueAssets[Int(height)] {
                    if let existingBitrate = existingAsset.bitrate, let currentBitrate = flavorAsset.bitrate {
                        if existingBitrate < currentBitrate {
                            uniqueAssets[Int(height)] = flavorAsset // Replace with higher bitrate asset
                        }
                    }
                } else {
                    uniqueAssets[Int(height)] = flavorAsset // Add new unique asset
                }
            }
        }
        
        return Array(uniqueAssets.values).sorted { $0.bitrate ?? 0 < $1.bitrate ?? 0 } // Convert dictionary values to an array and return it sorted
    }
}

public struct FlavorAsset: Codable, Equatable {
    public let width: Int64?
    public let height: Int64?
    public let bitrate: Int64?
    public let id:String?
    public let entryId:String?
}
