//
//  UserSummaryRequest.swift
//  StreamAMG
//
//  Created by Franco Driansetti on 19/01/2022.
//

import Foundation

/// Body Request
struct UserSummaryRequest: Codable {
    var FirstName: String
    var LastName: String
    var CustomFields: CustomFields?
}

/// Optional Custom fields
struct CustomFields: Codable {
    /// A unique identifier of custom field
    var Id: String
    /// Language depends custom field label
    var Label: String
    var Required: String
    /// Represends a user free text or unique identifier of selected custom field option
    var Value: String
}
