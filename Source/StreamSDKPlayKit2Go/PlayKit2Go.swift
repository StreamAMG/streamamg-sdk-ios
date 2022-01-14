//
//  PlayKit2Go.swift
//  StreamAMG
//
//  Created by Mike Hall on 13/10/2021.
//

import Foundation
import DownloadToGo
import PlayKit

public class PlayKit2Go: ContentManagerDelegate {
    
    public static let instance = PlayKit2Go()
    let cm = ContentManager.shared
    let lam = LocalAssetsManager.managerWithDefaultDataStore()
    weak var delegate: PlayKit2GoDelegate? = nil
    
    private var allValidIDs: [String] = []
    private init() {
        cm.delegate = self
    }
    
    public func setup() {
        do {
            try cm.setup()
            try cm.start(){
            }
            try cm.startItems(inStates: .inProgress, .interrupted)
            startItemsReady()
        } catch {
            print("Error starting PlayKit2Go service - \(error.localizedDescription)")
        }
    }
    
    public func handleEventsForBackgroundURLSession(identifier: String, completionHandler: @escaping () -> Void){
        ContentManager.shared.handleEventsForBackgroundURLSession(identifier: identifier, completionHandler: completionHandler)
    }
    
    public func download(serverUrl: String, partnerID: Int, entryID: String, ks: String? = nil) {
        
        var item: DTGItem?
        
        do {
            item = try cm.itemById(entryID)
            if item == nil {
                    guard let mediaItem = mediaEntry(serverUrl: serverUrl, partnerID: partnerID, entryID: entryID, ks: ks), let mediaSource = lam.getPreferredDownloadableMediaSource(for: mediaItem) else {
                            print("No media source")
                            return
                        }
                item = try cm.addItem(id: mediaItem.id, url: mediaSource.contentUrl!)
            }
        } catch {
            print("Error starting download for item \(entryID) - \(error.localizedDescription)")
        }
        
        guard let dtgItem = item else {
            print("Can't add item")
            return
        }
        
        DispatchQueue.global().async {
            do {
                var options: DTGSelectionOptions
                options = DTGSelectionOptions()
//                    .setMinVideoHeight(300)
//                    .setMinVideoBitrate(.avc1, 3_000_000)
//                    .setMinVideoBitrate(.hevc, 5_000_000)
//                    .setPreferredVideoCodecs([.hevc, .avc1])
                    .setPreferredAudioCodecs([.ac3, .mp4a])
                    .setAllTextLanguages()
                    .setAllAudioLanguages()
                options.allowInefficientCodecs = true
                try self.cm.loadItemMetadata(id: entryID, options: options)
                
            } catch {
                DispatchQueue.main.async {
                    if let error = error as? DTGError {
                        switch error {
                        case .itemNotFound( _):
                            self.delegate?.downloadDidError(item: PlayKitDownloadItem(entryID: entryID, completedFraction: 0, available: false, totalSize: 0, currentDownloadedSize: 0, error: .Item_Not_Found))
                        case .invalidState( _):
                            self.delegate?.downloadDidError(item: PlayKitDownloadItem(entryID: entryID, completedFraction: 0, available: false, totalSize: 0, currentDownloadedSize: 0, error: .Already_Queued_Or_Completed))
                        default:
                            self.delegate?.downloadDidError(item: PlayKitDownloadItem(entryID: entryID, completedFraction: 0, available: false, totalSize: 0, currentDownloadedSize: 0, error: .Unknown_Error))
                        }
                    } else if let error = error as? DownloadToGo.HLSLocalizerError {
                        switch error {
                        case .unknownPlaylistType:
                            self.delegate?.downloadDidError(item: PlayKitDownloadItem(entryID: entryID, completedFraction: 0, available: false, totalSize: 0, currentDownloadedSize: 0, error: .Download_Error))
                        
                        case .malformedPlaylist:
                            self.delegate?.downloadDidError(item: PlayKitDownloadItem(entryID: entryID, completedFraction: 0, available: false, totalSize: 0, currentDownloadedSize: 0, error: .Download_Error))
                        case .invalidState:
                            self.delegate?.downloadDidError(item: PlayKitDownloadItem(entryID: entryID, completedFraction: 0, available: false, totalSize: 0, currentDownloadedSize: 0, error: .Already_Queued_Or_Completed))
                        }
                        
                    } else {
                    print("loadItemMetadata failed \(error)")
                    }
                }
            }
        }
        
    }
    
    public func remove(entryID: String) {
        do {
            guard let url = try self.cm.itemPlaybackUrl(id: entryID) else {
                print("Can't get local url for \(entryID)")
                return
            }
            
            lam.unregisterDownloadedAsset(location: url, callback: { (error) in
                DispatchQueue.main.async {
                    print("Unregister complete for \(entryID)")
                }
            })
            
            try? cm.removeItem(id: entryID)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func setDelegate(_ delegate: PlayKit2GoDelegate){
        self.delegate = delegate
    }
    
    private func validKS(ks: String?)-> String {
        if let ks = ks {
            return "ks/\(ks)/"
        }
        return ""
    }
    
    public func playbackURL(entryID: String) -> URL?{
        do {
                guard let url = try self.cm.itemPlaybackUrl(id: entryID) else {
                    print("Can't get local url")
                    return nil
                }
            let fileManager = FileManager.default
            var path = "\(cm.storagePath.appendingPathComponent("items", isDirectory: false))"
            path = "\(path)\(url.path)"
            
            if let testURL = URL(string: path), fileManager.fileExists(atPath: testURL.path){
            return url
            } else {
                self.delegate?.downloadDidError(item: PlayKitDownloadItem(entryID: entryID, completedFraction: 0, available: false, totalSize: 0, currentDownloadedSize: 0, error: .Item_Not_Found))
            }
        } catch {
            print("Error returning URL for \(entryID)")
        }
        
        return nil
    }
    
    public func item(id: String, didDownloadData totalBytesDownloaded: Int64, totalBytesEstimated: Int64?, completedFraction: Float) {
        delegate?.downloadDidUpdate(item: PlayKitDownloadItem(entryID: id, completedFraction: completedFraction, available: false, totalSize: totalBytesEstimated ?? totalBytesDownloaded, currentDownloadedSize: totalBytesDownloaded ?? totalBytesDownloaded, error: nil))
    }
    
    public func item(id: String, didChangeToState newState: DTGItemState, error: Error?) {
        switch newState {
        case .metadataLoaded:
            do {
                try cm.startItem(id: id)
            } catch {
            }
        case .completed:
            let dlSize = fetchAllStoredItems().downloadedForItem(entryID: id)
            delegate?.downloadDidComplete(item: PlayKitDownloadItem(entryID: id, completedFraction: 1, available: true, totalSize: dlSize, currentDownloadedSize: dlSize, error: nil))
        default:
            delegate?.downloadDidChangeStatus(item: PlayKitDownloadItem(entryID: id, completedFraction: 0, available: false, totalSize: 0, currentDownloadedSize: 0, error: nil))
            break
        }
        
        if let error = error {
            print("Item: \(id) errored: \(error.localizedDescription)")
        }
    }
    
    func startItemsReady() {
        listAllItems(forState: .metadataLoaded).forEach{item in
            do {
                try cm.startItem(id: item)
            } catch {
                
            }
        }
    }
    
    public func listDownloadedItems() -> [String] {
        return listAllItems(forState: .completed)
    }
    
    public func fetchAllStoredItems() -> PlayKitDownloads {
        var downloads = PlayKitDownloads()
        allValidIDs.removeAll()
        downloads.completed = getItems(forState: .completed)
        downloads.new = getItems(forState: .new)
        downloads.metadataLoaded = getItems(forState: .metadataLoaded)
        downloads.downloading = getItems(forState: .inProgress)
        downloads.paused = getItems(forState: .paused)
        downloads.failed = getItems(forState: .failed)
        downloads.failed.append(contentsOf: getItems(forState: .interrupted))
        downloads.failed.append(contentsOf: getItems(forState: .dbFailure))
        downloads.removed = getItems(forState: .removed)
        return downloads
    }
    
    func getItems(forState: DTGItemState) -> [PlayKitDownloadItem] {
        var list: [PlayKitDownloadItem] = []
        do {
            try cm.itemsByState(forState).forEach{item in
                allValidIDs.append(item.id)
             var myItem = PlayKitDownloadItem()
                myItem.entryID = item.id
                myItem.available = false
                myItem.error = nil
                switch forState {
                case .new:
                    myItem.completedFraction = 0
                case .metadataLoaded:
                    myItem.completedFraction = 0
                case .inProgress:
                    myItem.completedFraction = item.completedFraction
                    myItem.currentDownloadedSize = item.downloadedSize
                    myItem.totalSize = item.estimatedSize ?? item.downloadedSize
                case .paused:
                    myItem.completedFraction = item.completedFraction
                case .completed:
                    myItem.completedFraction = 1
                    myItem.currentDownloadedSize = item.downloadedSize
                    myItem.totalSize = item.downloadedSize
                    myItem.available = true
                case .failed:
                    myItem.completedFraction = item.completedFraction
                    myItem.error = .Download_Error
                case .interrupted:
                    myItem.completedFraction = item.completedFraction
                    myItem.error = .Unknown_Error
                case .removed:
                    myItem.completedFraction = 0
                case .dbFailure:
                    myItem.completedFraction = 0
                    myItem.error = .Internal_Error
                }
                
                
                list.append(myItem)
            }
        } catch {
            
        }
        return list
    }
    
    public func listAllItems(forState: DTGItemState) -> [String] {
        var returner: [String] = []
        do {
            let list = try cm.itemsByState(forState)
        list.forEach{ item in
            returner.append(item.id)
        }
        } catch {
            print("Error getting downloaded items")
        }
        
        return returner
    }
    
    public func isItemTracked(entryID: String) -> Bool {
        return allValidIDs.contains(entryID)
    }
    
    internal func mediaEntry(serverUrl: String, partnerID: Int, entryID: String, ks: String? = nil) -> PKMediaEntry? {
        guard let url = URL(string: "\(serverUrl)/p/\(partnerID)/sp/0/playManifest/entryId/\(entryID)/format/applehttp/\(validKS(ks: ks))protocol/http/manifest.m3u8") else {
            return nil
        }
        let source = PKMediaSource(entryID, contentUrl: url, mediaFormat: .hls)
        let mediaEntry = PKMediaEntry(entryID, sources: [source])
        return mediaEntry
    }
    
}
