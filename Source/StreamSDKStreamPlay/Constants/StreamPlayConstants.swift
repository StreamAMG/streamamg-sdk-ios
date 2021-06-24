//
//  StreamPlayConstants.swift
//  StreamAMGStreamPlay
//
//  Created by Mike Hall on 25/01/2021.
//

import Foundation

public enum StreamPlaySport: String {
    case  FOOTBALL,BASKETBALL,RUGBY_LEAGUE,SNOOKER,POOL,DARTS,BOXING,GYMNASTICS,FISHING,NETBALL,TEN_PIN_BOWLING,PING_PONG,GOLF

func value() -> String{
    return self.rawValue.lowercased()
}
}

public enum StreamPlayQueryType: Int {
    case PARAMETER,
    MEDIA,
    EXTRA
}

public enum StreamPlayQueryField: CaseIterable {
   case ID,
    MEDIA_TYPE,
    MEDIA_ENTRYID,
    MEDIA_DRM,
    FIXTURE_TYPE,
    FIXTURE_NAME,
    FIXTURE_DESCRIPTION,
    FIXTURE_OPTA_ID,
    FIXTURE_SPORTS_RADAR_ID,
    FIXTURE_PA_ID,
    SEASON_ID,
    SEASON_NAME,
    COMPETITION_ID,
    COMPETITION_NAME,
    HOME_TEAM_ID,
    HOME_TEAM_NAME,
    AWAY_TEAM_ID,
    AWAY_TEAM_NAME,
    STADIUM_ID,
    STADIUM_NAME,
    LOCATION_ID,
    LOCATION_NAME,
    EVENT_TYPE
    
    public func query() -> String {
        switch self {
        case .ID:
        return "id"
        case .MEDIA_TYPE:
        return "mediaData.mediaType"
        case .MEDIA_ENTRYID:
        return "mediaData.entryId"
        case .MEDIA_DRM:
        return "mediaData.drm"
        case .FIXTURE_TYPE:
        return "type"
        case .FIXTURE_NAME:
        return "name"
        case .FIXTURE_DESCRIPTION:
        return "description"
        case .FIXTURE_OPTA_ID:
        return "externalIds.optaFixtureId"
        case .FIXTURE_SPORTS_RADAR_ID:
        return "externalIds.sportsradarFixtureId"
        case .FIXTURE_PA_ID:
        return "externalIds.paFixtureId"
        case .SEASON_ID:
        return "season.id"
        case .SEASON_NAME:
        return "season.name"
        case .COMPETITION_ID:
        return "competition.id"
        case .COMPETITION_NAME:
        return "competition.name"
        case .HOME_TEAM_ID:
        return "homeTeam.id"
        case .HOME_TEAM_NAME:
        return "homeTeam.name"
        case .AWAY_TEAM_ID:
        return "awayTeam.id"
        case .AWAY_TEAM_NAME:
        return "awayTeam.name"
        case .STADIUM_ID:
        return "stadium.id"
        case .STADIUM_NAME:
        return "stadium.name"
        case .LOCATION_ID:
        return "location.id"
        case .LOCATION_NAME:
        return "location.name"
        case .EVENT_TYPE:
        return "eventType"
        }
    }
    
    public func queryDescription() -> String {
        switch self {
        case .ID:
        return "Item ID"
        case .MEDIA_TYPE:
        return "Media Type"
        case .MEDIA_ENTRYID:
        return "Entry ID"
        case .MEDIA_DRM:
        return "Entry Status"
        case .FIXTURE_TYPE:
        return "Fixture type"
        case .FIXTURE_NAME:
        return "Fixture name"
        case .FIXTURE_DESCRIPTION:
        return "Fixture description"
        case .FIXTURE_OPTA_ID:
        return "Opta ID"
        case .FIXTURE_SPORTS_RADAR_ID:
        return "Sports Radar ID"
        case .FIXTURE_PA_ID:
        return "PA ID"
        case .SEASON_ID:
        return "Season ID"
        case .SEASON_NAME:
        return "Season Name"
        case .COMPETITION_ID:
        return "Competition ID"
        case .COMPETITION_NAME:
        return "Competition name"
        case .HOME_TEAM_ID:
        return "Home Team ID"
        case .HOME_TEAM_NAME:
        return "Home Team name"
        case .AWAY_TEAM_ID:
        return "Away Team ID"
        case .AWAY_TEAM_NAME:
        return "Away Team name"
        case .STADIUM_ID:
        return "Stadium ID"
        case .STADIUM_NAME:
        return "Stadium name"
        case .LOCATION_ID:
        return "Location ID"
        case .LOCATION_NAME:
        return "Location name"
        case .EVENT_TYPE:
        return "Event type"
        }
    }
    
    public func queryType() -> StreamPlayQueryType {
        switch self {
        case .MEDIA_TYPE, .MEDIA_ENTRYID, .MEDIA_DRM:
            return .MEDIA
        default:
            return.PARAMETER
        }
    }
}
