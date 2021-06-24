//
//  StreamPlayIsLiveModel.swift
//  StreamSDKStreamPlay
//
//  Created by Mike Hall on 27/01/2021.
//

import Foundation

public struct StreamPlayIsLiveModel: Codable {
    public let isLive: Bool
    let pollingFrequency: Int
    
    public var liveStreamID: String? = ""
    
    public func nextPoll() -> TimeInterval {
        return Date.init().timeIntervalSince1970 + Double(pollingFrequency)
    }
    
}
