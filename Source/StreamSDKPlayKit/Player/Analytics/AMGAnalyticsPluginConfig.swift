//
//  AMGAnalyticsPluginConfig.swift
//  Pods
//
//  Created by Mike Hall on 26/03/2021.
//

import Foundation
import PlayKit

/************************************************************/
// MARK: AMGAnalyticsPluginConfig
/************************************************************/

@objc public class AMGAnalyticsPluginConfig: NSObject {
    
    /************************************************************/
    // MARK: - Enum
    /************************************************************/
    
    @objc public enum PlaybackType : Int {
        case unknown
        case live
        case vod
    }
    
    /************************************************************/
    // MARK: - Properties
    /************************************************************/
    
    private let defaultBaseUrl = "https://stats.mp.streamamg.com/SessionUpdate"
    
    /// application ID.
    let applicationId = Bundle.main.bundleIdentifier
    /// The partner account ID on Kaltura's platform.
    @objc public var partnerId: Int
    /// The media's entry ID.
    @objc public var entryId: String?
    /// The player id and configuration the content was played on.
    @objc public var uiconfId: Int
    /// The Kaltura encoded session data.
    @objc public var ks: String?
    /// The users id.
    @objc public var userId: String?
    /// The category id describing the current played context.
    @objc public var playbackContext: String?
    /// Received from plugin config if nothing there take app id wit relavant prefix.
    @objc public var referrer: String?
    /// Kaltura api base url
    @objc public var baseUrl: String
    /// Optional vars
    @objc public var customVar1, customVar2, customVar3: String?
    /// If not using providers user must mention playback type (live/ vod)
    /// Set by defualt to unknown
    @objc public var playbackType: PlaybackType = .unknown
    /// DVR Threshold set by default to 2 minutes.
    @objc public var dvrThreshold = 120
    /// The application version.
    @objc public var applicationVersion: String?
    /// The playlist Id.
    @objc public var playlistId: String?
    
    /************************************************************/
    // MARK: Internal Properties
    /************************************************************/
    
    var sessionStartTime: String?
    var hasDVR: Bool?
    
    /************************************************************/
    // MARK: - Initialization
    /************************************************************/
    
    @objc public init(partnerId: Int, entryId: String? = nil, ks: String? = nil, userId: String? = nil, playbackContext: String? = nil, referrer: String? = nil, applicationVersion: String? = nil, playlistId: String? = nil, customVar1: String? = nil, customVar2: String? = nil, customVar3: String? = nil) {
        self.baseUrl = defaultBaseUrl
        // uiconfId is optional, set to -1 as default
        // can be overridden
        self.uiconfId = -1
        self.partnerId = partnerId
        self.entryId = entryId
        self.ks = ks
        self.userId = userId
        self.playbackContext = playbackContext
        self.applicationVersion = applicationVersion
        self.playlistId = playlistId
        self.customVar1 = customVar1
        self.customVar2 = customVar2
        self.customVar3 = customVar3
        super.init()
        
        if let sentReferrer = referrer, self.isValidReferrer(sentReferrer) {
            self.referrer = sentReferrer
        } else {
            PKLog.warning("Invalid referrer argument. Should start with app:// or http:// or https://")
            if let appId = applicationId {
                self.referrer = "app://" + appId
            } else {
                PKLog.warning("The app's bundle identifier is not set")
            }
        }
    }
    
    /************************************************************/
    // MARK: Private Implementation
    /************************************************************/
    
    private func isValidReferrer(_ referrer: String) -> Bool {
        let validPrefixes = ["app://", "http://", "https://"]
        var isValid = false
        for p in validPrefixes {
            if referrer.hasPrefix(p) {
                isValid = true
                break
            }
        }
        return isValid
    }
}

/************************************************************/
// MARK: - Extensions
/************************************************************/

extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
