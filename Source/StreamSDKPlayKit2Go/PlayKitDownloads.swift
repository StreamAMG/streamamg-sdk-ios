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

    
    public func percentageForItem(entryID: String) -> Float {
        if let item = completed.first(where: {$0.entryID == entryID}) {
            return 100
        }
        if let item = downloading.first(where: {$0.entryID == entryID}) {
            return item.percentageComplete()
        }
        if let item = paused.first(where: {$0.entryID == entryID}) {
            return item.percentageComplete()
        }
        if let item = new.first(where: {$0.entryID == entryID}) {
            return 0
        }
        if let item = metadataLoaded.first(where: {$0.entryID == entryID}) {
            return 0
        }
        return -1
    }
    
    
    public func downloadedForItem(entryID: String) -> Int64 {
        if let item = completed.first(where: {$0.entryID == entryID}) {
            return item.currentDownloadedSize
        }
        if let item = downloading.first(where: {$0.entryID == entryID}) {
            return item.currentDownloadedSize
        }
        if let item = paused.first(where: {$0.entryID == entryID}) {
            return item.currentDownloadedSize
        }
        if new.first(where: {$0.entryID == entryID}) != nil {
            return 0
        }
        if metadataLoaded.first(where: {$0.entryID == entryID}) != nil {
            return 0
        }
        return -1
    }
}

public struct PlayKitDownloadItem {
    public var entryID: String = ""
    public var completedFraction: Float = 0
    public var available: Bool = false
    public var totalSize: Int64 = 0
    public var currentDownloadedSize: Int64 = 0
    public var error: PlayKit2GoError? = nil
    
    public func percentageComplete() -> Float {
        return completedFraction * 100
    }
}

public enum PlayKit2GoError {
    case Already_Queued_Or_Completed, Download_Error, Unknown_Error, Download_Does_Not_Exist, Item_Not_Found, Internal_Error
}

