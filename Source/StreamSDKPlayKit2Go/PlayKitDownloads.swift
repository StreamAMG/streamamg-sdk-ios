//
//  PlayKitDownloads.swift
//  StreamAMG
//
//  Created by Mike Hall on 15/10/2021.
//

import Foundation

public struct PlayKitDownloads {
    public var completed: [PlayKitDownloadItem] = []
    public var new: [PlayKitDownloadItem] = []
    public var paused: [PlayKitDownloadItem] = []
    public var downloading: [PlayKitDownloadItem] = []
    public var failed: [PlayKitDownloadItem] = []
    public var metadataLoaded: [PlayKitDownloadItem] = []
    public var removed: [PlayKitDownloadItem] = []

    
}

public struct PlayKitDownloadItem {
    public var entryID: String = ""
    public var completedFraction: Float = 0
    public var available: Bool = false
    public var error: PlayKit2GoError? = nil
    
    public func percentageComplete() -> Float {
        return completedFraction * 100
    }
}

public enum PlayKit2GoError {
    case Already_Queued_Or_Completed, Download_Error, Unknown_Error, Download_Does_Not_Exist, Item_Not_Found, Internal_Error
}

