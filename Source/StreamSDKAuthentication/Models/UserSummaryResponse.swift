//
//  UserSummaryResponse.swift
//  StreamAMG
//
//  Created by Franco Driansetti on 19/01/2022.
//

import Foundation

// MARK: - UserSummaryResponse
public struct UserSummaryResponse: Codable {
    let emailAddress, firstName, lastName: String?
    let status, error, message: String?
    
    let customFields: [CustomField]?
    let billingDetails: BillingDetails?
    let subscriptions: [Subscription]?

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
    }
}

// MARK: - BillingDetails
public struct BillingDetails: Codable {
    let addressCountry, addressCity, addressLine1, addressLine2: String
    let addressState, addressZip: String
    let cardDetails: CardDetails

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
    let provider, reference, country: String
    let expires: Date

    enum CodingKeys: String, CodingKey {
        case provider = "Provider"
        case reference = "Reference"
        case country = "Country"
        case expires = "Expires"
    }
}

// MARK: - CustomField
public struct CustomField: Codable {
    let id, label: String
    let customFieldRequired: Bool
    let value: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case label = "Label"
        case customFieldRequired = "Required"
        case value = "Value"
    }
}

// MARK: - Subscription
public struct Subscription: Codable {
    let id, status: String
    let expiryDate: Date
    let isIAP: Bool
    let package: Package
    let type, currencyCode: String?
    let renewalDate: Date?

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
    let id, name, title, packageDescription: String
    let type: String
    let amount: Int
    let currencyCode, interval, duration: String
    let trialDuration: String?

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
    }
}




