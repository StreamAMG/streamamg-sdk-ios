//
//  UserSummaryResponse.swift
//  StreamAMG
//
//  Created by Franco Driansetti on 19/01/2022.
//

import Foundation

// MARK: - UserSummaryResponse
public struct UserSummaryResponse: Codable {
    public let emailAddress, firstName, lastName: String?
    public let status, error, message: String?
    
    public let customFields: [CustomField]?
    public let billingDetails: BillingDetails?
    public let subscriptions: [Subscription]?
    public let entitlements : [String]?

    enum CodingKeys: String, CodingKey {
        case emailAddress = "EmailAddress"
        case firstName = "FirstName"
        case lastName = "LastName"
        case customFields = "CustomFields"
        case billingDetails = "BillingDetails"
        case subscriptions = "Subscriptions"
        case status = "status"
        case error = "error"
        case message = "message"
        case entitlements = "Entitlements"
    }
}

// MARK: - BillingDetails
public struct BillingDetails: Codable {
    public let addressCountry, addressCity, addressLine1, addressLine2: String
    public let addressState, addressZip: String
    public let cardDetails: CardDetails

    enum CodingKeys: String, CodingKey {
        case addressCountry = "AddressCountry"
        case addressCity = "AddressCity"
        case addressLine1 = "AddressLine1"
        case addressLine2 = "AddressLine2"
        case addressState = "AddressState"
        case addressZip = "AddressZip"
        case cardDetails = "CardDetails"
    }
}

// MARK: - CardDetails
public struct CardDetails: Codable {
    public let provider, reference, country: String
    public let expires: Date

    enum CodingKeys: String, CodingKey {
        case provider = "Provider"
        case reference = "Reference"
        case country = "Country"
        case expires = "Expires"
    }
}

// MARK: - CustomField
public struct CustomField: Codable {
    public let id, label: String
    public let customFieldRequired: Bool
    public let value: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case label = "Label"
        case customFieldRequired = "Required"
        case value = "Value"
    }
}

// MARK: - Subscription
public struct Subscription: Codable {
    public let id, status: String
    public let expiryDate: String?
    public let isIAP: Bool?
    public let package: Package?
    public let type, currencyCode: String?
    public let renewalDate: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case status = "Status"
        case expiryDate = "ExpiryDate"
        case isIAP = "IsIAP"
        case package = "Package"
        case type = "Type"
        case currencyCode = "CurrencyCode"
        case renewalDate = "RenewalDate"
    }
}

// MARK: - Package
public struct Package: Codable {
    public let id, name, title, packageDescription: String?
    public let type: String?
    public let amount: Double?
    public let currencyCode, interval, duration: String?
    public let trialDuration: String?
    public let hasFreeTrial : Bool?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case title = "Title"
        case packageDescription = "Description"
        case type = "Type"
        case amount = "Amount"
        case currencyCode = "CurrencyCode"
        case interval = "Interval"
        case duration = "Duration"
        case trialDuration = "TrialDuration"
        case hasFreeTrial = "HasFreeTrial"
    }
}




