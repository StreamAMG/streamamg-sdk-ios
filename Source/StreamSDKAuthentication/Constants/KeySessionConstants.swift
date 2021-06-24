//
//  KeySessionConstants.swift
//  StreamSDKAuthentication
//
//  Created by Mike Hall on 22/02/2021.
//

import Foundation

public enum SAKSResult: Int {
    case Granted = -1,
         NoActiveSession = 0,
         NoSubscription = 1,
         NoEntitlement = 2,
         Blocked = 3,
         TooManyRequests = 4,
         UnknownEntryID = 5,
         Error = -2
    
    func meaning() -> String {
        switch self {
        case .Granted:
            return ""
        case .NoActiveSession:
            return "No active session"
        case .NoSubscription:
            return "No subscription"
        case .NoEntitlement:
            return "No entitlement"
        case .Blocked:
            return "Account blocked"
        case .TooManyRequests:
            return "Too many requests"
        case .UnknownEntryID:
            return "Unknown Entry ID"
        case .Error:
            return "Unknown reason"
        }
    }
}
