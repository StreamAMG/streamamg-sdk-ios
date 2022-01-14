//
//  PlayKit2GoDelegate.swift
//  StreamAMG
//
//  Created by Mike Hall on 15/10/2021.
//

import Foundation

public protocol PlayKit2GoDelegate: AnyObject {
    func downloadDidError(item: PlayKitDownloadItem)
    func downloadDidUpdate(item: PlayKitDownloadItem)
    func downloadDidComplete(item: PlayKitDownloadItem)
    func downloadDidChangeStatus(item: PlayKitDownloadItem)
}
