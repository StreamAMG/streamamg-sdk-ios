//
//  PlayKitConstants.swift
//  StreamAMG
//
//  Created by Mike Hall on 23/07/2021.
//

import Foundation

public enum AMGMediaType {
    case Live, VOD, Audio, Live_Audio
}

/**
 An enum constant defenition to define the position of various UI Control elements in the standard controls
 */
public enum AMGControlPosition: String, Codable {
    case top = "top", bottom = "bottom", left = "left", right = "right", topleft = "topleft", topright = "topright", bottomleft = "bottomleft", bottomright = "bottomright", centre = "centre"

    enum Key: CodingKey {
        case rawValue
    }

    enum CodingError: Error {
        case unknownValue
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Key.self)
        let label = try values.decode(String.self, forKey: .rawValue)
        switch label {
        case "top": self = .top
        case "bottom": self = .bottom
        case "left": self = .left
        case "right": self = .right
        case "topleft": self = .topleft
        case "topright": self = .topright
        case "bottomleft": self = .bottomleft
        case "bottomright": self = .bottomright
        case "centre": self = .centre
        default:
            self = .bottom
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {

        case .top:
            try container.encode("top", forKey: .rawValue)
        case .bottom:
            try container.encode("bottom", forKey: .rawValue)
        case .left:
            try container.encode("left", forKey: .rawValue)
        case .right:
            try container.encode("right", forKey: .rawValue)
        case .topleft:
            try container.encode("topleft", forKey: .rawValue)
        case .topright:
            try container.encode("topright", forKey: .rawValue)
        case .bottomleft:
            try container.encode("bottomleft", forKey: .rawValue)
        case .bottomright:
            try container.encode("bottomright", forKey: .rawValue)
        case .centre:
            try container.encode("centre", forKey: .rawValue)
        }
    }
    
    
    
}

public enum AMGMediaFormat {
    case MP4, HLS
}

public enum AMGAnalyticsService {
    case DISABLED, YOUBORA, AMGANALYTICS
}
