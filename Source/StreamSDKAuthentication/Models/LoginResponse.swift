//
//  LoginResponse.swift
//  StreamSDKAuthentication
//
//  Created by Mike Hall on 19/02/2021.
//

import Foundation

public struct LoginResponse: Codable {
    public var status: Int?
    public var kSession: String?
    public var errorMessage: String?
    public var authenticationToken: String?
    public var utcNow: Int64?
    public var locationFromIp: LocationFromIp?
    public var currentCustomerSessionStatus: Int?
    public var currentCustomerSession: StreamAMGUserModel?
    //public var modelErrors: ModelErrors?
    
    enum CodingKeys: String, CodingKey {
      case status = "Status",
           kSession = "KSession",
           errorMessage = "ErrorMessage",
           authenticationToken = "AuthenticationToken",
           utcNow = "UtcNow",
           locationFromIp = "LocationFromIp",
           currentCustomerSessionStatus = "CurrentCustomerSessionStatus",
           currentCustomerSession = "CurrentCustomerSession"
          // modelErrors = "ModelErrors"
    }
    
    public func logResponse(){
        if let token = authenticationToken {
        print ("Auth token: \(token)")
        } else {
            print ("Auth token not received")
        }
    }
}

public struct ModelErrors: Codable {
    public var emailaddress: String?
    public var password: String?
    public var restriction: String?
    public var concurrency: String?
    
    enum CodingKeys: String, CodingKey {
      case emailaddress,
           password,
           restriction,
           concurrency = "Concurrency"
    }
}

public struct LocationFromIp: Codable {
    public var name: String?
    public var country: String?
    public var countryCode: String?
    public var state: String?
    public var city: String?
    
    
    enum CodingKeys: String, CodingKey {
      case name = "Name",
           country = "Country",
           countryCode = "CountryCode",
           state = "State",
           city = "City"
    }
}

public struct StreamAMGUserModel: Codable {
    public var id: String?
    public var customerId: String?
    public var customerDeleted: Bool?
    public var customerFirstName: String?
    public var customerLastName: String?
    public var customerEmailAddress: String?
    public var customerSubscriptionCount: Int?
    public var customerNonExpiringSubscriptionCount: Int?
    public var customerEntitlements: String?
    public var customerFullAccessUntil: String?
    public var customerPackages: String?
    public var customerBillingProfileProvider: String?
    public var customerBillingProfileReference: String?
    public var customerBillingProfileExpiresAt: Int64?
    public var customerBillingProfileCreatedAt: String?
    public var customerBillingProfileLastFailedAt: String?
    public var requiresCardAuthenticationCount: Int?
    
    enum CodingKeys: String, CodingKey {
      case id = "Id",
           customerId = "CustomerId",
           customerDeleted = "CustomerDeleted",
           customerFirstName = "CustomerFirstName",
           customerLastName = "CustomerLastName",
           customerEmailAddress = "CustomerEmailAddress",
           customerSubscriptionCount = "CustomerSubscriptionCount",
           customerNonExpiringSubscriptionCount = "CustomerNonExpiringSubscriptionCount",
           customerEntitlements = "CustomerEntitlements",
           customerFullAccessUntil = "CustomerFullAccessUntil",
           customerPackages = "CustomerPackages",
           customerBillingProfileProvider = "CustomerBillingProfileProvider",
           customerBillingProfileReference = "CustomerBillingProfileReference",
           customerBillingProfileExpiresAt = "Expiry",
           customerBillingProfileCreatedAt = "CustomerBillingProfileCreatedAt",
           customerBillingProfileLastFailedAt = "CustomerBillingProfileLastFailedAt",
           requiresCardAuthenticationCount = "RequiresCardAuthenticationCount"
    }
}
