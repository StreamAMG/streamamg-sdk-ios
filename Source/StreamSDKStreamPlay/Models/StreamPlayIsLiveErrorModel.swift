//
//  StreamPlayIsLiveErrorModel.swift
//  StreamSDKStreamPlay
//
//  Created by Mike Hall on 27/01/2021.
//

import Foundation
/**
  Model returned when an IsLive service is unavailable or reports an error
 */
public class StreamPlayIsLiveErrorModel: Error {
    var errorCode: Int? = nil
    var messages: [String] = []
    
    public var liveStreamID: String = ""
    
    init(id: String) {
        liveStreamID = id
    }
    
    public func addMessage(message: String) {
        messages.append(message)
    }
    /**
     Returns an error code - generally HTTP - for a failed call
     * Returns -1 if no code is available
     */
    public func getErrorCode() -> Int{
        if let errorCode = errorCode {
            return errorCode
        }
        return -1
    }
    
    
    /**
      Returns all error messages in a single String Array
     */
    public func getErrorMessages() -> [String] {
        return messages
    }
    /**
      Returns a single string containing all errors reported
     */
    public func getErrorMessagesAsString() -> String {
        if messages.count == 0 {
            return "No errors returned by API"
        }
        var errorMessages = ""
        messages.forEach{message in
            if errorMessages.count > 0 {
                errorMessages += ", "
            }
            errorMessages += message
        }
        return errorMessages
    }
    
}
