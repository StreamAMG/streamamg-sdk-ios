//
//  LoginRequest.swift
//  StreamSDKAuthentication
//
//  Created by Mike Hall on 19/02/2021.
//

import Foundation

struct LoginRequest: Codable {
    var emailAddress: String
    var password: String
}
