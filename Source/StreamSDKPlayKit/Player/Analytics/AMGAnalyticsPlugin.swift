//
//  AMGAnalyticsPlugin.swift
//  AMGPlayKit
//
//  Created by Sam Easterby-Smith on 11/12/2020.
//

import Foundation
import PlayKit
import KalturaNetKit
import SwiftyJSON

/**
 
 # AMGAnalyticsPlugin
 
 */
public class AMGAnalyticsPlugin: BasePlugin, AnalyticsPluginProtocol {
    
    
    private static var partnerID = 0
    private static var userLocation: String?
    private static var deviceType: String?
    
    private static var baseURL = "https://stats.mp.streamamg.com/SessionUpdate?"
    
    private static var requestMethod: RequestMethod = .get
    private static var requestHeader: [String:String] = [:]
    
    // MARK: - Private local variables
    
    private var periodicObserverUUID: UUID?
    
    // Time Mapping
    private var realtimeStart: Date?
    private var lastPosition: TimeInterval = 0
    private var timeStamp: TimeInterval = 0
    
    private var seekTimeStarted: TimeInterval? = nil
    
    private var heatMap = HeatMap()
    
    private var config: AMGAnalyticsPluginConfig? = nil
    
    
    var currentDuration: TimeInterval = 0
    var currentLoadStatus = 0
    
    var sessionID: String = ""
    
    /************************************************************/
    // MARK: - PKPlugin
    /************************************************************/
    
    public var isFirstPlay: Bool = true
    
    public override class var pluginName: String {
        return "AMGAnalyticsPlugin"
    }
    
    public required init(player: Player, pluginConfig: Any?, messageBus: MessageBus) throws {
        try super.init(player: player, pluginConfig: pluginConfig, messageBus: messageBus)
        self.periodicObserverUUID = self.player?.addPeriodicObserver(interval: 1.0, observeOn: DispatchQueue.main, using: { (time) in
            self.lastPosition = time
        })
        self.registerEvents()
    }
    
    
    public override func onUpdateMedia(mediaConfig: MediaConfig) {
        super.onUpdateMedia(mediaConfig: mediaConfig)
        
        
        self.isFirstPlay = true
    }
    
    
    public override func destroy() {
        
        
        super.destroy()
    }
    
    /************************************************************/
    // MARK: - AnalyticsPluginProtocol
    /************************************************************/
    
    /// default events to register
    public var playerEventsToRegister: [PlayerEvent.Type] {
        //        return [
        //            PlayerEvent.ended,
        //            PlayerEvent.error,
        //            PlayerEvent.pause,
        //            PlayerEvent.stopped,
        //            PlayerEvent.loadedMetadata,
        //            PlayerEvent.playing,
        //            PlayerEvent.sourceSelected,
        //            PlayerEvent.stateChanged,
        //            PlayerEvent.playheadUpdate
        //        ]
        PlayerEvent.allEventTypes
    }
    
    public static func setUserLocation(_ location: String) {
        userLocation = location
    }
    
    public static func setUserDeviceType(_ userDevice: String) {
        deviceType = userDevice
    }
    
    public static func setPartnerID(_ id: Int) {
        partnerID = id
    }
    
    public static func setAnalyticsURL(_ url: String) {
        baseURL = url
    }
    
    public static func setAnalyticsCustomHeader(_ requestHeader: [String:String]) {
        self.requestHeader = requestHeader
    }
    
    public static func setAnalyticsRequestMethod(_ requestMethod: RequestMethod) {
        self.requestMethod = requestMethod
    }
    
    public func registerEvents() {
        PKLog.debug("plugin \(type(of:self)) register to all player events")
        
        self.playerEventsToRegister.forEach { event in
            //          PKLog.debug("Register event: \(event.self)")
            switch event {
            case let e where e.self == PlayerEvent.ended:
                self.messageBus?.addObserver(self, events: [e.self]) { [weak self] event in
                    guard let self = self else { return }
                    self.heatMap.playFinished()
                    self.sendEvent(event: event, eventID: 8)
                }
            case let e where e.self == PlayerEvent.error:
                self.messageBus?.addObserver(self, events: [e.self]) { [weak self] event in
                    guard let self = self else { return }
                    self.currentLoadStatus = self.errorFromEvent(event: event)
                    self.sendEvent(event: event)
                }
            case let e where e.self == PlayerEvent.errorLog:
                self.messageBus?.addObserver(self, events: [e.self]) { [weak self] event in
                    guard let self = self else { return }
                    self.currentLoadStatus = 2
                    self.sendEvent(event: event)
                }
            case let e where e.self == PlayerEvent.pause:
                self.messageBus?.addObserver(self, events: [e.self]) { [weak self] event in
                    guard let self = self else { return }
                    if let time = self.player?.currentTime{
                        self.heatMap.pause(at: time)
                    }
                    self.sendEvent(event: event)
                }
            case let e where e.self == PlayerEvent.play:
                self.messageBus?.addObserver(self, events: [e.self]) { [weak self] event in
                    guard let self = self else { return }
                    if let time = self.player?.currentTime{
                        self.heatMap.play(at: time)
                    }
                    self.sendEvent(event: event, eventID: 2)
                }
            case let e where e.self == PlayerEvent.seeking:
                self.messageBus?.addObserver(self, events: [e.self]) { [weak self] event in
                    guard let self = self else { return }
                    if let timeTo = self.player?.currentTime{
                        if self.seekTimeStarted == nil {
                            self.seekTimeStarted = timeTo
                        }
                    }
                    self.sendEvent(event: event, eventID: 9)
                }
            case let e where e.self == PlayerEvent.seeked:
                self.messageBus?.addObserver(self, events: [e.self]) { [weak self] event in
                    guard let self = self else { return }
                    if let timeTo = self.player?.currentTime, let timeFrom = self.seekTimeStarted{
                        self.heatMap.playheadMovedByUser(from: timeFrom, to: timeTo)
                        self.seekTimeStarted = nil
                    }
                    self.sendEvent(event: event)
                }
            case let e where e.self == PlayerEvent.stopped:
                self.messageBus?.addObserver(self, events: [e.self]) { [weak self] event in
                    guard let self = self else { return }
                    if let time = self.player?.currentTime{
                        self.heatMap.pause(at: time)
                    }
                    self.sendEvent(event: event)
                }
            case let e where e.self == PlayerEvent.loadedMetadata:
                self.messageBus?.addObserver(self, events: [e.self]) { [weak self] event in
                    guard let self = self else { return }
                    self.currentLoadStatus = 0
                    if let duration = self.player?.duration{
                        self.heatMap.resetHeatMap(duration: duration)
                    } else {
                        self.heatMap.resetHeatMap(duration: 0)
                    }
                    self.sendEvent(event: event)
                }
            case let e where e.self == PlayerEvent.playheadUpdate:
                self.messageBus?.addObserver(self, events: [e.self]) { [weak self] event in
                    guard let self = self else { return }
                    if let playHead = self.player?.currentTime{
                        self.heatMap.updateHeatMap(currentTime: playHead)
                    }
                    if (self.timeStamp + 6 < Date().timeIntervalSince1970){
                        self.timeStamp = Date().timeIntervalSince1970
                        self.sendEvent(event: event)
                    }
                }
            case let e where e.self == PlayerEvent.playing:
                self.messageBus?.addObserver(self, events: [e.self]) { [weak self] event in
                    guard let self = self else { return }
                    self.currentLoadStatus = 1
                    self.sendEvent(event: event, eventID: 1)
                }
            case let e where e.self == PlayerEvent.sourceSelected:
                self.messageBus?.addObserver(self, events: [e.self]) { [weak self] event in
                    guard let self = self else { return }
                    // guard let mediaSource = event.mediaSource else { return }
                    self.sendEvent(event: event)
                }
            default:
                break
            }
        }
        
    }
    
    func errorFromEvent(event: PKEvent) -> Int {
        if let data = event.data, let error = data["error"] as? String {
            print("Error: \(error)")
            if error.contains("7000") { // media source issue
                print("Error 7000")
                return 0 // 2 // Need to work out what is happening here....
            }
            if error.contains("7100") { // timeout issue
                return 4 //
            }
        }
        return 2
    }
    
    func sendEvent(event: PKEvent, eventID: Int = 0) {
        do {
            try self.sendRequest(eventID: eventID)
        } catch {
            print("**** ERROR ****")
            print(error.localizedDescription)
        }
    }
    
    public func unregisterEvents() {
        self.messageBus?.removeObserver(self, events: playerEventsToRegister)
    }
    
    // MARK: - Send Requests
    
    public func sendRequest(eventID: Int) throws {
        guard let player = player else {
            throw AMGAnalyticsError.noPlayer
        }
        guard let mediaEntry = player.mediaEntry else {
            throw AMGAnalyticsError.noMediaEntry
        }
        //        guard let config = config else {
        //            throw AMGAnalyticsError.noConfig
        //        }
        
        
        timeStamp = Date().timeIntervalSince1970
        
        let request = AMGAnalyticsRequest(
            sessionID: sessionID,
            entryID: mediaEntry.id,
            partnerID: AMGAnalyticsPlugin.partnerID,
            //uiConfID: nil, // No longer required
            //kSession: nil, // No longer required
            heatmap: heatMap.report(),
            entryDuration: Int64(heatMap.duration * 1000),   //mediaEntry.duration,
            connectedDuration: heatMap.connectionDuration(),
            playedDuration: heatMap.durationPlayed(),
            videoLoadStatus: currentLoadStatus,
            referrerURL: nil,
            videoEvent: eventID,
            //username: nil, // We really shoudn't be sending usernames
            videoLoadTime: nil,
            timeStamp: Date(),
            userLocation: AMGAnalyticsPlugin.userLocation,
            deviceType: AMGAnalyticsPlugin.deviceType
        )
        
        let requestBuilder = try request.requestBuilder()
        requestBuilder.responseSerializer = AMGAnalyticsResponseSerializer()
        
        requestBuilder.set { [weak self] (response) in
            // print("Status code: \(response.statusCode)")
            // print("Status code: \(response.error.debugDescription)")
            // print("Status code: \(response.error?.localizedDescription ?? "Status code NA")")
            
            // if response.statusCode == 200 {
            // print("Request OK")
            // }
            
            if let amgResponse = response.data as? AMGAnalyticsResponse {
                switch amgResponse {
                case .success(let sessionID):
                    self?.sessionID = sessionID
                case .failure(let errorMessage):
                    print("Analytics request failed: \(String(describing: errorMessage))")
                }
            }
            
        }
        let builtRequest = requestBuilder.build()
        KNKRequestExecutor.shared.send(request: builtRequest)
    }
    
    // MARK: - Nested Types
    enum AMGAnalyticsError: Error {
        case unableToCreateRequestBuilder
        case noPlayer
        case noMediaEntry
        case noConfig
    }
    
    enum VideoLoadStatus: Int {
        case noAttemptToPlay    = 0
        case successful         = 1
        case errorReceived      = 2
        case notAuthorized      = 3
        case timeout            = 4
    }
    
    struct AMGAnalyticsRequestWrapper: Codable {
        let data: AMGAnalyticsRequest
        enum CodingKeys: String, CodingKey {
            case data = "Data"
        }
    }
    
    struct AMGAnalyticsRequest: Codable {
        
        let sessionID: String
        let entryID: String
        let partnerID: Int
        //let uiConfID: Int?
        //let kSession: String?
        let heatmap: String
        let entryDuration: Int64?
        let connectedDuration: Int64?
        let playedDuration: Int64?
        let videoLoadStatus: Int?
        let referrerURL: String?
        //let username: String?
        let videoEvent: Int
        let videoLoadTime: Int?
        let timeStamp: Date
        let userLocation: String?
        let deviceType: String?
        
        enum CodingKeys: String, CodingKey {
            case sessionID = "sid"
            case entryID = "eid"
            case heatmap = "dhm"
            case partnerID = "pid"
            case entryDuration = "den"
            case connectedDuration = "dcn"
            case playedDuration = "dpl"
            case referrerURL = "rurl"
            case videoLoadTime = "vlt"
            case videoLoadStatus = "vls"
            case videoEvent = "vnt"
            case timeStamp = "tsp"
            case userLocation = "user_location"
            case deviceType = "device"
            
            
        }
        
        func date() -> String {
            return ""
        }
        
        func requestBuilder() throws -> RequestBuilder {
            
            guard let requestBuilder = RequestBuilder(url: baseURL) else {
                throw AMGAnalyticsError.unableToCreateRequestBuilder
            }
            
            if !sessionID.isEmpty{
                requestBuilder.setParam(key: "sid", value: sessionID)
            }
            
            requestBuilder.setParam(key: "eid", value: entryID)
            requestBuilder.setParam(key: "dhm", value: heatmap)
            requestBuilder.setParam(key: "pid", value: "\(partnerID)")
            if let entryDuration = entryDuration{
                requestBuilder.setParam(key: "den", value: "\(entryDuration)")
            }
            if let connectedDuration = connectedDuration{
                requestBuilder.setParam(key: "dcn", value: "\(connectedDuration)")
            }
            if let playedDuration = playedDuration{
                requestBuilder.setParam(key: "dpl", value: "\(playedDuration)")
            }
            if let referrerURL = referrerURL{
                requestBuilder.setParam(key: "rurl", value: referrerURL)
            }
            
            if let videoLoadTime = videoLoadTime{
                requestBuilder.setParam(key: "vlt", value: "\(videoLoadTime)")
            }
            if let videoLoadStatus = videoLoadStatus{
                requestBuilder.setParam(key: "vls", value: "\(videoLoadStatus)")
            }
            requestBuilder.setParam(key: "vnt", value: "\(videoEvent)")
            requestBuilder.setParam(key: "tsp", value: "\(timeStamp)")
            
            for value in requestHeader {
                requestBuilder.add(headerKey: value.key, headerValue: value.value)
            }
            
            if requestMethod == .post {
                
                if let userLocationExist = userLocation {
                    requestBuilder.setParam(key: "user_location", value: "\(userLocationExist)")
                }
                
                if let deviceTypeExist = deviceType {
                    requestBuilder.setParam(key: "device", value: "\(deviceTypeExist)")
                }
                
                requestBuilder.method = .post
                
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                if let json = try? encoder.encode(AMGAnalyticsRequestWrapper(data: self)), let body = String(data: json, encoding: .utf8){
                    let swiftyJson = JSON(parseJSON: body)
                    requestBuilder.jsonBody = swiftyJson
                    print("Sending: °\(body)")
                }
            } else {
                requestBuilder.method = .get
            }
            
            return requestBuilder
            
        }
    }
}

struct AMGAnalyticsResponseWrapper: Codable {
    let sid: String?
    let OK: String?
}


enum AMGAnalyticsResponse {
    case success(sessionID: String)
    case failure(errorMessage: String?)
}

struct AMGAnalyticsResponseSerializer: ResponseSerializer {
    
    enum ResponseError: Error{
        case unableToDecodeData
        case unexpectedFormat
    }
    
    func serialize(data: Data) throws -> Any {
        
        do {
            let decoded = try JSONDecoder().decode(AMGAnalyticsResponseWrapper.self, from: data)
            if let sid = decoded.sid {
                return AMGAnalyticsResponse.success(sessionID: sid)
            } else {
                return AMGAnalyticsResponse.failure(errorMessage: "Unknown Error")
            }
        } catch {
            /// AMG Analytics 
            guard let dataAsString = String(data: data, encoding: .utf8) else {
                throw ResponseError.unableToDecodeData
            }
           
            let components = dataAsString.split(separator: ":")
            guard components.count == 2 else {
                throw ResponseError.unexpectedFormat
            }
            
            let ok = components[0]
            let payload = String(components[1])
            
            if ok == "OK" {
                return AMGAnalyticsResponse.success(sessionID: payload)
            } else if ok == "KO" {
                return AMGAnalyticsResponse.failure(errorMessage: payload)
            } else {
                throw ResponseError.unexpectedFormat
            }
        }
    }
    
    
}
