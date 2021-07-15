//
//  AMGPlayKitState.swift
//  StreamAMG
//
//  Created by Mike Hall on 30/06/2021.
//

import Foundation

public struct AMGPlayKitState{
    public var state: AMGPlayerState
    public var duration: TimeInterval = -1
}

public struct AMGPlayKitError{
    public var errorCode: Int = 0
    public var errorMessage: String = ""
}

public enum AMGPlayerState {
    case Stopped, Playing, Error, Ad_Started, Ad_Ended, Ended, Loaded, Play, Stop, Pause, Idle, Loading, Buffering, Ready
}

public enum AMGPlayerError: Int, CaseIterable {
    case SOURCE_ERROR = 7000,
         RENDERER_ERROR = 7001,
         UNEXPECTED = 7002,
         SOURCE_SELECTION_FAILED = 7003,
         FAILED_TO_INITIALIZE_PLAYER = 7004,
         DRM_ERROR = 7005,
         TRACK_SELECTION_FAILED = 7006,
         LOAD_ERROR = 7007,
         OUT_OF_MEMORY = 7008,
         REMOTE_COMPONENT_ERROR = 7009,
         TIMEOUT = 7010
    
    public func errorDescription() -> String {
        switch self {
        case .SOURCE_ERROR:
            return "SOURCE_ERROR"
        case .RENDERER_ERROR:
            return "RENDERER_ERROR"
        case .UNEXPECTED:
            return "UNEXPECTED"
        case .SOURCE_SELECTION_FAILED:
            return "SOURCE_SELECTION_FAILED"
        case .FAILED_TO_INITIALIZE_PLAYER:
            return "FAILED_TO_INITIALIZE_PLAYER"
        case .DRM_ERROR:
            return "DRM_ERROR"
        case .TRACK_SELECTION_FAILED:
            return "TRACK_SELECTION_FAILED"
        case .LOAD_ERROR:
            return "LOAD_ERROR"
        case .OUT_OF_MEMORY:
            return "OUT_OF_MEMORY"
        case .REMOTE_COMPONENT_ERROR:
            return "REMOTE_COMPONENT_ERROR"
        case .TIMEOUT:
            return "TIMEOUT"
        }
    }
}
