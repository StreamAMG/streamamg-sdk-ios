//
//  CloudMatrixResponse.swift
//  StreamSDK-CloudMatrix
//
//  Created by Mike Hall on 21/01/2021.
//

import Foundation
/**
 * Model returned from a valid, successful call by a CloudMatrixRequest
 */
public struct CloudMatrixResponse: Codable {
    public let feedMetaData: CloudMatrixFeedMetaDataModel?
    public let sections: [CloudMatrixSectionModel]?
    public let itemData: [CloudMatrixItemDataModel]?
    public let pagingData: CloudMatrixPagingDataModel?
    public var currentSection: Int? = 0
    /**
     * Logs a list of all returned titles to the console - debugging method only
     *
     * Core should be configured to have logging enabled
     */
    public func logResponse(){
        logListCM(data: "CM --------------------------------------")
        if (sections != nil) {
            sections?.forEach{ section in
                logListCM(data: section.name ?? "No Section Name")
                section.itemData.forEach { result in
                    logListCM(data: result.metaData?.title ?? "No Title")
                }
            }
        } else {
            logSearchResults()
        }
    }
    
    func logSearchResults() {
        if (itemData != nil) {
            itemData!.forEach {result in
                logListCM(data: result.metaData?.title ?? "No Title")
            }
        } else {
            logListCM(data: "No results available")
        }
    }
    
    public func fetchResults() -> [CloudMatrixItemDataModel] {
        var results: [CloudMatrixItemDataModel] = []
        if let sections = sections {
            sections.forEach {section in
                results.append(contentsOf: section.itemData)
            }
        } else if let itemData = itemData {
            results.append(contentsOf: itemData)
        }
        
        return results
    }
    
    /**
     * Returns the total number of items available in the current request
     */
    public func fetchTotal() -> String {
        if let sections = sections, let currentSection = currentSection, currentSection < sections.count{
            let section = sections[currentSection]
            return String(section.pagingData.totalCount)
        }
        if let pagingData = pagingData  {
            return String(pagingData.totalCount)
        }
        return "0"
    }
    
    /**
     * Returns the number of entries per page in this response
     */
    public func fetchLimit() -> String {
        if let sections = sections, let currentSection = currentSection {
            let section = sections[currentSection]
            return String(section.pagingData.pageSize)
        }
        if let pagingData = pagingData  {
            return String(pagingData.pageSize)
        }
        return "0"
    }
    
    public func fetchRetrieved() -> String {
        if let sections = sections, let currentSection = currentSection {
            let section = sections[currentSection]
            return String(section.pagingData.itemCount)
        }
        if let pagingData = pagingData  {
            return String(pagingData.itemCount)
        }
        return "0"
        
    }
    
    /**
     * Returns the current page this response contains - normalised to start at 1
     */
    public func fetchPageNumber() -> String {
        if let sections = sections, let currentSection = currentSection {
            let section = sections[currentSection]
            return String(section.pagingData.pageIndex + 1)
        }
        if let pagingData = pagingData  {
            return String(pagingData.pageIndex + 1)
        }
        return "0"
    }
    
    /**
     * Returns the total number of pages available for the current request
     */
    public func fetchPageTotal() -> String {
        if let sections = sections, let currentSection = currentSection {
            let section = sections[currentSection]
            return String(section.pagingData.pageCount)
        }
        if let pagingData = pagingData  {
            return String(pagingData.pageCount)
        }
        return "0"
    }
    
    /**
     * Returns the full paging data model for this response
     */
    public func fetchPagingData(section: Int? = nil) -> CloudMatrixPagingDataModel {
        if let sections = sections, let currentSection = currentSection {
            let section = sections[currentSection]
            return section.pagingData
        }
        if let pagingData = pagingData  {
            return pagingData
        }
        return CloudMatrixPagingDataModel()
    }
    
    public func nextPage() -> Int {
        if let sections = sections, let currentSection = currentSection, currentSection < sections.count{
            let section = sections[currentSection]
            let thisPage = section.pagingData.pageIndex
            if (thisPage + 1 < section.pagingData.pageCount) {
                return thisPage + 1
            }
            return thisPage    //section.currentPage * section.pagingData.pageSize
        }
        if let pagingData = pagingData  {
            let thisPage = pagingData.pageIndex
            if (thisPage + 1 < pagingData.pageCount) {
                return thisPage + 1
            }
            return thisPage
        }
        return 0
    }
    
    /**
     * Returns the index of the previous page available, or 0 if not
     */
    
    public func previousPage() -> Int {
        if let sections = sections, let currentSection = currentSection, currentSection < sections.count{
            let section = sections[currentSection]
            let thisPage = section.pagingData.pageIndex
            if (thisPage - 1 >= 0) {
                return thisPage - 1
            }
            return thisPage    //section.currentPage * section.pagingData.pageSize
        }
        if let pagingData = pagingData  {
            let thisPage = pagingData.pageIndex
            if (thisPage - 1 >= 0) {
                return thisPage - 1
            }
            return thisPage
        }
        return 0
    }
    
}


/**
 * Feed meta data model
 */
public struct CloudMatrixFeedMetaDataModel: Codable {
    public var id: String?
    public var name: String?
    public var title: String?
    public var description: String?
    public var target: String?
}

/**
 * Section model - Contains information regarding a block of identifiable data -
 */
public struct CloudMatrixSectionModel: Codable {
    public var id: String?
    public var name: String?
    public var itemData: [CloudMatrixItemDataModel] = []
    public var pagingData: CloudMatrixPagingDataModel = CloudMatrixPagingDataModel()
    
}

public struct CloudMatrixPagingDataModel: Codable {
    public var totalCount: Int = 0
    public var itemCount: Int = 0
    public var pageCount: Int = 0
    public var pageSize: Int = 0
    public var pageIndex: Int = 0
}

/**
 * Media data model - contains information regarding any associated media
 */
public struct CloudMatrixMediaDataModel: Codable {
    public let mediaType: String?
    public let entryId: String?
    public let entryStatus: String?
    public let thumbnailUrl: String?
}

/**
 * Sort data model
 */
public struct CloudMatrixSortDataModel: Codable {
    public let feedId: String?
    public let sectionId: String?
    public let order: Int?
}

public struct CloudMatrixItemDataModel: Codable {
    public var id: String?
    public let mediaData: CloudMatrixMediaDataModel?
    public let metaData: CloudMatrixMetaDataModel? //Dictionary[String: Any] //
    public var sortData: [CloudMatrixSortDataModel]? = []
    public let publicationData: CloudMatrixPublicationDataModel?
    
    /**
     * Convenience method - Returns the MetaData 'Title' component
     */
    public func getTitle() -> String? {
        if let metaData = metaData {
            return metaData.title
        }
        return nil
    }
    /**
     * Convenience method - Returns the MetaData 'Body' component
     */
    public func getBody() -> String? {
        if let metaData = metaData {
            return metaData.body
        }
        return nil
    }
    /**
     * Convenience method - Returns the MetaData 'VideoDuration' component
     */
    public func getDuration() -> Int? {
        if let metaData = metaData {
            return metaData.duration
        }
        return nil
    }
    /**
     * Convenience method - Returns the MetaData 'Tags' array
     */
    public func getTags() -> [String]? {
        if let metaData = metaData {
            return metaData.tags
        }
        return nil
    }
    /**
     * Convenience method - Calls the MetaData 'GetString' method
     */
    public func getMetaDataString(key: String) ->  String? {
        if let metaData = metaData {
            return metaData.getString(key: key)
        }
        return nil
    }
    /**
     * Convenience method - Calls the MetaData 'GetLong' method
     */
    public func getMetaDataLong(key: String) ->  Int64? {
        if let metaData = metaData {
            return metaData.getLong(key: key)
        }
        return nil
    }
    /**
     * Convenience method - Calls the MetaData 'GetInt' method
     */
    public func getMetaDataInt(key: String) ->  Int? {
        if let metaData = metaData {
            return metaData.getInt(key: key)
        }
        return nil
    }
    /**
     * Convenience method - Calls the MetaData 'GetDouble' method
     */
    public func getMetaDataDouble(key: String) ->  Double? {
        if let metaData = metaData {
            return metaData.getDouble(key: key)
        }
        return nil
    }
    /**
     * Convenience method - Calls the MetaData 'GetBool' method
     */
    public func getMetaDataBool(key: String) ->  Bool? {
        if let metaData = metaData {
            return metaData.getBool(key: key)
        }
        return nil
    }
    /**
     * Convenience method - Calls the MetaData 'GetArray' method
     */
    public func getMetaDataArray(key: String) ->  [Any]? {
        if let metaData = metaData {
            return metaData.getArray(key: key)
        }
        return nil
    }
    /**
     * Convenience method - Calls the MetaData 'GetStringArray' method
     */
    public func getMetaDataStringArray(key: String) ->  [String]? {
        if let metaData = metaData {
            return metaData.getStringArray(key: key)
        }
        return nil
    }
}

public struct CloudMatrixMetaDataModel: Codable {
    typealias Value = [String: Any]
    let dictionary: Value?
    public init(from decoder: Decoder) throws {
        dictionary = try? decoder.container(keyedBy: AnyCodingKey.self).decode(Value.self)
    }
    public func encode(to encoder: Encoder) throws {
        
    }
    
    /**
     * Returns a specific String for a give Key of an item in the MetaData section of the returned API JSON object
     * Will return a null if the key does not exist or would return an object that is not a String value
     */
    public func getString(key: String) -> String? {
        if let string = dictionary?[key], let returnString = string as? String {
            return returnString
        }
        return nil
    }
    
    
    /**
     * Returns a specific 32 bit integer for a give Key of an item in the MetaData section of the returned API JSON object
     * Will return a null if the key does not exist, would return an object that is not an Int value or would return an Int that would overflow
     */
    public func getInt(key: String) -> Int? {
        return dictionary?[key] as! Int?
    }
    
    /**
     * Returns a specific Double (or float as a Double) for a give Key of an item in the MetaData section of the returned API JSON object
     * Will return a null if the key does not exist or would return an object that is not a Double / Float value
     */
    public func getDouble(key: String) -> Double? {
        return dictionary?[key] as! Double?
    }
    
    /**
     * Returns a specific 32 bit integer for a give Key of an item in the MetaData section of the returned API JSON object
     * Will return a null if the key does not exist or would return an object that is not a Long / Int value
     */
    public func getLong(key: String) -> Int64? {
        return dictionary?[key] as! Int64?
    }
    
    /**
     * Returns a boolean value for a give Key of an item in the MetaData section of the returned API JSON object
     * Will return a null if the key does not exist or would return an object that is not a Boolean value
     */
    public func getBool(key: String) -> Bool? {
        return dictionary?[key] as! Bool?
    }
    
    /**
     * Returns an undefined array for a give Key of an item in the MetaData section of the returned API JSON object
     * Will return a null if the key does not exist or is not an array
     * The array is an array of 'Any'. In most cases, StringArray should be used
     */
    public func getArray(key: String) -> [Any]? {
        if (dictionary?[key] is [Any]) {
            return dictionary?[key] as? [Any]
        }
        return nil
    }
    
    /**
     * Returns a guaranteed array of Strings for a give Key of an item in the MetaData section of the returned API JSON object
     * Will return a null if the key does not exist, is not an array or contains any elements that are not strings
     * The array is an array of 'Any'. In most cases, StringArray should be used
     */
    public func getStringArray(key: String) -> [String]? {
        
        if let array = dictionary?[key] as? [String] {
            return array
        }
        return nil
    }
    
    /**
     * Guaranteed to exist, but MAY be null
     */
    public var title: String? {
        get {getString(key: "title")}
    }
    /**
     * Guaranteed to exist, but MAY be null
     */
    public var body: String? {
        get {getString(key: "body")}
    }
    /**
     * Guaranteed to exist, but MAY be null - returns the 'VideoDuration' property in seconds
     */
    public var duration: Int? {
        get {getInt(key: "VideoDuration")}
    }
    /**
     * Guaranteed to exist, but MAY be null
     */
    public var category: String? {
        get {getString(key: "category")}
    }
    /**
     * Guaranteed to exist, but MAY be null - A list of strings set as tags for this entry
     */
    public var tags: [String]? {
        get {getStringArray(key: "tags")}
    }
    
}

public struct CloudMatrixPublicationDataModel: Codable {
    public let createdAt: String?
    public let updatedAt: String?
    public let released: Bool?
    public let releaseFrom: String?
    public let releaseTo: String?
}

private
struct AnyCodingKey: CodingKey {
    let stringValue: String
    private (set) var intValue: Int?
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) {
        self.intValue = intValue
        stringValue = String(intValue)
    }
}

extension KeyedDecodingContainer {
    
    private
    func decode(_ type: [Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [Any] {
        var values = try nestedUnkeyedContainer(forKey: key)
        return try values.decode(type)
    }
    
    private
    func decode(_ type: [String: Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [String: Any] {
        try nestedContainer(keyedBy: AnyCodingKey.self, forKey: key).decode(type)
    }
    
    func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        var dictionary: [String: Any] = [:]
        for key in allKeys {
            if try decodeNil(forKey: key) {
                dictionary[key.stringValue] = NSNull()
            } else if let bool = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = bool
            } else if let string = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = string
            } else if let int = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = int
            } else if let double = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = double
            } else if let dict = try? decode([String: Any].self, forKey: key) {
                dictionary[key.stringValue] = dict
            } else if let array = try? decode([Any].self, forKey: key) {
                dictionary[key.stringValue] = array
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {
    mutating func decode(_ type: [Any].Type) throws -> [Any] {
        var elements: [Any] = []
        while !isAtEnd {
            if try decodeNil() {
                elements.append(NSNull())
            } else if let int = try? decode(Int.self) {
                elements.append(int)
            } else if let bool = try? decode(Bool.self) {
                elements.append(bool)
            } else if let double = try? decode(Double.self) {
                elements.append(double)
            } else if let string = try? decode(String.self) {
                elements.append(string)
            } else if let values = try? nestedContainer(keyedBy: AnyCodingKey.self),
                      let element = try? values.decode([String: Any].self) {
                elements.append(element)
            } else if var values = try? nestedUnkeyedContainer(),
                      let element = try? values.decode([Any].self) {
                elements.append(element)
            }
        }
        return elements
    }
}
