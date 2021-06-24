//
//  File.swift
//  StreamSDK-Core
//
//  Created by Mike Hall on 20/01/2021.
//

import Foundation

public enum StreamAPIEnvironment {
    case PRODUCTION, DEVELOPMENT
}

/**
 *List of available search operands
 */
public enum StreamAMGQueryType: CaseIterable {
   case EQUALS,
    GREATERTHAN,
    GREATERTHANOREQUALTO,
    LESSTHAN,
    LESSTHANOREQUALTO,
    EXISTS,
    FUZZY,
    WILDCARD,
    OR_EQUALS

    public func queryOperator() -> String {
        switch self {
        case .GREATERTHAN:
            return ">"
        case .GREATERTHANOREQUALTO:
            return ">="
        case .LESSTHAN:
            return "<"
        case .LESSTHANOREQUALTO:
            return "<="
        case .EQUALS:
            return ""
        case .EXISTS:
            return ""
        case .FUZZY:
            return ""
        case .WILDCARD:
            return ""
        case .OR_EQUALS:
            return ""
        }
    }
    
    public func description() -> String {
        switch self {
        case .EQUALS:
            return "is equal to"
        case .GREATERTHAN:
            return "is greater to"
        case .GREATERTHANOREQUALTO:
            return "is greater than or equal to"
        case .LESSTHAN:
            return "is less than"
        case .LESSTHANOREQUALTO:
            return "is less than or equal to"
        case .EXISTS:
            return "exists"
        case .FUZZY:
            return "is like"
        case .WILDCARD:
            return "starts with"
        case .OR_EQUALS:
            return "or equals"
        }
    }
}

/**
 *All available logging types
 */
public enum StreamSDKLogType {
    case ALL, NETWORK, LISTS, BOOLVALUES, STANDARD
}

public enum StreamSDKComponent: String {
    case CORE, CLOUDMATRIX, STREAMPLAY, AUTHENTICATION
}
