//
//  CloudMatrixSetup.swift
//  StreamSDK-CloudMatrix
//
//  Created by Mike Hall on 21/01/2021.
//

import Foundation

public struct CloudMatrixSetupModel {
    let userID: String
    let key: String
    let url: String
    let debugURL: String
    let version: String
    let language: String
    
    public init(userID: String, key: String, url: String, debugURL: String? = nil, version: String = "v1", language: String = "en"){
        self.userID = userID
        self.key = key
        self.url = url
        if let validDebugURL = debugURL {
            self.debugURL = validDebugURL
        } else {
            self.debugURL = url
        }
        self.version = version
        self.language = language
    }
}
