//
//  CloudMatrixConstants.swift
//  StreamSDK-CloudMatrix
//
//  Created by Mike Hall on 21/01/2021.
//

import Foundation

public enum CloudMatrixFunction: String {
    case FEED, SEARCH, TERMS
    
    internal func method() -> String {
        return self.rawValue.lowercased()
    }
}

public enum CloudMatrixQueryType: CaseIterable {
    case ID, MEDIATYPE, ENTRYID, ENTRYSTATUS, THUMBNAILURL, BODYTEXT, VIDEODURATION, TITLETEXT, TAGS, CREATEDDATE, UPDATEDDATE, RELEASED, RELEASEFROM, RELEASETO
    
    public func query() -> String {
        switch self {
        case .ID:
            return "id"
        case .MEDIATYPE:
            return "mediaData.mediaType"
        case .ENTRYID:
            return "mediaData.entryId"
        case .ENTRYSTATUS:
            return "mediaData.entryStatus"
        case .THUMBNAILURL:
            return "mediaData.thumbnailUrl"
        case .BODYTEXT:
            return "metaData.body"
        case .VIDEODURATION:
            return "metaData.VideoDuration"
        case .TITLETEXT:
            return "metaData.title"
        case .TAGS:
            return "metaData.tags"
        case .CREATEDDATE:
            return "publicationData.createdAt"
        case .UPDATEDDATE:
            return "publicationData.updatedAt"
        case .RELEASED:
            return "publicationData.released"
        case .RELEASEFROM:
            return "publicationData.releaseFrom"
        case .RELEASETO:
            return "publicationData.releaseTo"
        }
    }
    
    public func description() -> String {
        switch self {
        case .ID:
            return "Item ID"
        case .MEDIATYPE:
            return "Media Type"
        case .ENTRYID:
            return "Entry ID"
        case .ENTRYSTATUS:
            return "Entry Status"
        case .THUMBNAILURL:
            return "Thumbnail URL"
        case .BODYTEXT:
            return "Body Text"
        case .VIDEODURATION:
            return "Video length (in seconds)"
        case .TITLETEXT:
            return "Title Text"
        case .TAGS:
            return "Tags"
        case .CREATEDDATE:
            return "Media Creation Date"
        case .UPDATEDDATE:
            return "Media Last Updated Date"
        case .RELEASED:
            return "Media has been Released"
        case .RELEASEFROM:
            return "Media Released From Date"
        case .RELEASETO:
            return "Media Released To Date"
        }
    }
}


