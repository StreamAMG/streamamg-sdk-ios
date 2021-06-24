//
//  StreamPlayIsLiveService.swift
//  StreamSDKStreamPlay
//
//  Created by Mike Hall on 27/01/2021.
//

import Foundation
/**
 Class used to control an 'IsLive' API call
 */
public class StreamPlayIsLiveService {
    static var heartbeat: Timer? = nil
    static var calls: [IsLiveCall] = []
    static var timerRefresh: TimeInterval = 30
    /**
      Adds an 'IsLive' check to the service with a delegate and, if requested, processes it until it is cancelled
     * @param id A unique identifier for this call
     * @param url The fully formed URL to call
     * @param delegate A class conforming to 'StreamPlayIsLiveInterface' which will handle any response from the IsLive URL
     * @param allowDuplicateURLs defines whether the service should handle the same URL in more than one job - Defaults to 'false'
     * @param shouldRepeat determines whether the IsLive check should be made once, or continually.
     */
    public static func addIsLiveCall(id: String, url: String, delegate: StreamPlayIsLiveDelegate, allowDuplicates: Bool = false, shouldRepeat:Bool = true){
        if !shouldRepeat {
            let call = IsLiveCall.init(id: id, url: url, delegate: delegate, completion: nil)
            call.checkForPoll()
            return
        }
        if let error = checkExistingCalls(id: id, url: url, allowDuplicateURLs: allowDuplicates){
            delegate.isLiveErrorRecieved(model: error)
            return
        }
        let call = IsLiveCall.init(id: id, url: url, delegate: delegate, completion: nil)
        call.checkForPoll()
        calls.append(call)
        runTimer()
    }
    /**
      Adds an 'IsLive' check to the service with a callback and, if requested, processes it until it is cancelled
     * @param id A unique identifier for this call
     * @param url The fully formed URL to call
     * @param callback A function to be run after the job is complete, has the signature '((StreamPlayIsLiveModel?, StreamPlayIsLiveErrorModel?) -> Unit)'
     * @param allowDuplicateURLs defines whether the service should handle the same URL in more than one job - Defaults to 'false'
     * @param shouldRepeat determines whether the IsLive check should be made once, or continually.
     */
    public static func addIsLiveCall(id: String, url: String, completion: @escaping ((Result<StreamPlayIsLiveModel, StreamPlayIsLiveErrorModel>) -> Void), allowDuplicates: Bool = false, shouldRepeat:Bool = true){
        if !shouldRepeat {
            let call = IsLiveCall.init(id: id, url: url, delegate: nil, completion: completion)
            call.checkForPoll()
            return
        }
        if let error = checkExistingCalls(id: id, url: url, allowDuplicateURLs: allowDuplicates){
            completion(.failure(error))
            return
        }
        let call = IsLiveCall.init(id: id, url: url, delegate: nil, completion: completion)
        call.checkForPoll()
        calls.append(call)
        runTimer()
    }
    /**
      Adds an 'IsLive' check to the service with a delegate and, if requested, processes it until it is cancelled
     * Returns a unique ID for this call
     * @param url The fully formed URL to call
     * @param delegate A class conforming to 'StreamPlayIsLiveInterface' which will handle any response from the IsLive URL
     * @param allowDuplicateURLs defines whether the service should handle the same URL in more than one job - Defaults to 'false'
     * @param shouldRepeat determines whether the IsLive check should be made once, or continually.
     */
    public static func addIsLiveCall(url: String, delegate: StreamPlayIsLiveDelegate, allowDuplicates: Bool = false, shouldRepeat:Bool = true) -> String{
        let id = createID()
        addIsLiveCall(id: id, url: url, delegate: delegate, allowDuplicates: allowDuplicates, shouldRepeat: shouldRepeat)
        return id
    }
    /**
      Adds an 'IsLive' check to the service with a callback and, if requested, processes it until it is cancelled
     * Returns a unique ID for this call
     * @param url The fully formed URL to call
     * @param callback A function to be run after the job is complete, has the signature '((StreamPlayIsLiveModel?, StreamPlayIsLiveErrorModel?) -> Unit)'
     * @param allowDuplicateURLs defines whether the service should handle the same URL in more than one job - Defaults to 'false'
     * @param shouldRepeat determines whether the IsLive check should be made once, or continually.
     */
    public static func addIsLiveCall(url: String, completion: @escaping ((Result<StreamPlayIsLiveModel, StreamPlayIsLiveErrorModel>) -> Void), allowDuplicates: Bool = false, shouldRepeat:Bool = true) -> String{
        let id = createID()
        addIsLiveCall(id: id, url: url, completion: completion, allowDuplicates: allowDuplicates, shouldRepeat: shouldRepeat)
        return id
    }
    
    static func createID() -> String {
        var id = ""
        while (id.count == 0){
            id = UUID.init().uuidString
            if checkExistingCalls(id: id, url: "", allowDuplicateURLs: true) != nil {
               id = ""
            }
               }
        return id
    }
    
    
    static func runTimer(){
        if calls.count > 0 {
            if heartbeat == nil {
                heartbeat = Timer.scheduledTimer(timeInterval: timerRefresh, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            }
        }
    }
    /**
     Stops the IsLive checker running
     */
    public static func pauseService(){
        heartbeat?.invalidate()
        heartbeat = nil
    }
    /**
    Resumes the IsLive checker
     */
    public static func resumeService(){
        runTimer()
    }
    
    @objc static func fireTimer(){
        calls.forEach{isLiveCall in
            isLiveCall.checkForPoll()
        }
    }
    /**
      Sets the time between 'pulses' - where the service checks for any IsLive calls that need sending
      Note - this is NOT the time between actual checks, that is handled by the API itself, this is the time between checking each IsLive object to see if it needs to be fired
     * @param pulse The time, in milliseconds, between checks - default is 30000 (30 seconds)
     */
    public static func setServicePulse(pulse: TimeInterval){
        timerRefresh = pulse
    }
    /**
       Removes a particular call from the service
       The service will be stopped if there are no more calls
    * @param id The id (either submitted to or created by the initial call being added) of the job to be removed
    */
    static public func removeCheck(id: String){
        calls.removeAll(where: {$0.id == id})
        if calls.count == 0 {
            heartbeat?.invalidate()
        }
    }
    /**
       Removes all calls from the service
       The service will be stopped
    */
    static public func removeAllChecks(){
        calls.removeAll()
        heartbeat?.invalidate()
    }
    
    static func checkExistingCalls(id: String, url: String, allowDuplicateURLs: Bool) -> StreamPlayIsLiveErrorModel? {
        var error: StreamPlayIsLiveErrorModel? = nil
        calls.forEach{call in
            if call.id == id {
                if error == nil{
                    error = StreamPlayIsLiveErrorModel.init(id: id)
                }
                error?.addMessage(message: "Live call ID \(id) already exists")
            }
            if !allowDuplicateURLs {
                if call.url == url {
                    if error == nil{
                        error = StreamPlayIsLiveErrorModel.init(id: id)
                    }
                    error?.addMessage(message: "Live call URL \(url) already exists - if this is expected, you should call the 'addIsLive' function using 'allowDuplicateURLs=true'")
                }
            }
            
        }
        return error
    }
    
}
