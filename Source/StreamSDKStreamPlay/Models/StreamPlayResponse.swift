//
//  StreamPlayResponse.swift
//  StreamAMGStreamPlay
//
//  Created by Mike Hall on 25/01/2021.
//

import Foundation


/**
 * Model returned from a valid, successful call by a StreamPlayRequest
 */
public struct StreamPlayResponse: Codable {
    public var fixtures: [FixturesModel] = []
    public var total: Int
    public var limit: Int
    public var offset: Int
    
    /**
     * Logs a list of all returned fixtures to the console - debugging method only
     *
     * Core should be configured to have logging enabled
     */
    public func logResponse() {
        logListSP(data: "SP --------------------------------------")
        fixtures.forEach{ fixture in
            logListSP(data: fixture.name ?? "No Name")
        }
    }
    
    func fetchTotal() -> String {
        return String(total)
    }

    func fetchLimit() -> String {
        return String(limit)
    }

    func nextPage() -> Int{
        var page = offset + limit
        if (page >= total){
            page = offset
        }
        return page
    }

    func previousPage() -> Int{
        var page = offset - limit
        if (page <= 0){
            page = 0
        }
        return page
    }

    func fetchPageNumber() -> String {
        if (limit > 0) {
            return "\((offset / limit) + 1)"
        }
        return "-"
    }

    func fetchPageTotal() -> String {
        var pageTotal = total / limit
        if (pageTotal * limit < total){
            pageTotal += 1
        }
        return "\(pageTotal)"
    }
    
    
    
}

/**
 * A single fixture returned by the StreamPlay API
 */
public struct FixturesModel: Codable {
    public var id: Int?
    public var type: String?
    public var partnerId: Int?
    public var featured: Bool?
    public var name: String?
    public var description: String?
    public var startDate: String?
    public var endDate: String?
    public var createdAt: String?
    public var updatedAt: String?
    public var videoDuration: Int?
    public var externalIds: ExternalIDModel?
    public var season: FixtureDetailModel?
    public var competition: FixtureDetailModel?
    public var homeTeam: FixtureDetailModel?
    public var awayTeam: FixtureDetailModel?
    public var stadium: FixtureDetailModel?
    public var mediaData: [ScheduleMediaDataModel]
    public var thumbnail: String?
    public var thumbnailFlavors: FixtureThumbnailFlavorsModel?
    private var eventIsLive: Bool? = false
    
    
    /**
     * Checks the stored 'is live' value of this fixture.
     *
     *- Returns: A boolean reporting the last updated 'is live' status of this fixture
     *
     *Defaults to 'false' and is changed manually using the ```setLiveStatus(isLive: Bool)``` function
     */
    public func isLive() -> Bool {
        return eventIsLive ?? false
    }
    
    /**
     * Allows the 'is live' status of this fixture to be amended
     *
     * - Parameter isLive: Boolean value determining whether the event is currently live
     */
    public mutating func setLiveStatus(isLive: Bool){
        eventIsLive = isLive
    }
}



/**
 * Any external IDs that tie with this fixture
 */
public struct ExternalIDModel: Codable {
    public var optaFixtureId: String?
    public var paFixtureId: String?
    public var sportsradarFixtureId: String?
}

/**
 * A model that can house information about a specific item in a fixture (Team details, stadium details, etc)
 */
public struct FixtureDetailModel: Codable {
    public var id: Int?
    public var name: String?
    public var logo: String?
    public var logoFlavours: FixtureDetailLogoFlavorsModel?
}

/**
 * URLs for images held by the details in different resolutions
 */
public struct FixtureDetailLogoFlavorsModel: Codable {
    
    enum CodingKeys: String, CodingKey {
        case logo50 = "50"
        // Response will contain lat & long but
        // we will store as coordinate
        case logo100 = "100"
        case logo200 = "200"
        case logo300 = "300"
        case source
    }
    public var logo50: String?
    public var logo100: String?
    public var logo200: String?
    public var logo300: String?
    public var source: String?
}

/**
 * URLs for the main fixture thumbnail image in different resolutions
 */
public struct FixtureThumbnailFlavorsModel: Codable {
    public var logo250: String?
    public var logo640: String?
    public var logo1024: String?
    public var logo1920: String?
    public var source: String?
    
    enum CodingKeys: String, CodingKey {
        case logo250 = "250"
        case logo640 = "640"
        case logo1024 = "1024"
        case logo1920 = "1920"
        case source
    }
}

/**
 * Media data model - contains information regarding any associated media
 */
public struct ScheduleMediaDataModel: Codable {
    public var mediaType: String?
    public var entryId: String?
    public var isLiveUrl: String?
    public var isLiveTime: Int64?
    public var thumbnailUrl: String?
    public var drm: Bool?
}
