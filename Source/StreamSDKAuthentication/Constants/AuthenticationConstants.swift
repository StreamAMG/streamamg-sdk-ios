//
//  AuthenticationConstants.swift
//  StreamSDKAuthentication
//
//  Created by Mike Hall on 23/02/2021.
//

import Foundation
public enum SAResult: Int {
    case SAUnknown = -1,
         SAWrongEmailOrPassword = 0,
         SAUserRestriction = 2,
         SALoginOK = 3,
         SALogoutOK = 4,
         SALogoutFail = 5,
         SAConcurrency = 6
    
//    func meaning() -> String {
//        switch self {
//
//        case .Granted:
//            return ""
//        case .NoActiveSession:
//            return "No active session"
//        case .NoSubscription:
//            return "No subscription"
//        case .NoEntitlement:
//            return "No entitlement"
//        case .Blocked:
//            return "Account blocked"
//        case .TooManyRequests:
//            return "Too many requests"
//        case .Error:
//            return "Unknown reason"
//        }
//    }
}
