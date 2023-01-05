//
//  CaptionAsset.swift
//  StreamAMG
//
//  Created by Franco Driansetti on 11/11/2022.
//

import Foundation

// MARK: - CaptionAssetElement
public struct CaptionAssetElement: Codable {
    let partnerID: Int?
    let ks: String?
    let userID: Int?
    let objects: [Object]?
    let totalCount: Int?
}

// MARK: - Object
public struct Object: Codable, Equatable {
    public let captionParamsID: Int?
    public let language, languageCode: String?
    public let isDefault: Bool?
    public let label: String?
    public let format: String?
    public let status: Int?
    public let id: String?
    public let entryID: String?
    public let partnerID: Int?
    public let version: String?
    public let size: Int?
    public let tags: String?
    public let fileEXT: String?
    public let createdAt, updatedAt: Int?
    public let objectDescription: String?
}
