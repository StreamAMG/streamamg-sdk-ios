//
//  PlaykitError.swift
//  StreamAMG
//
//  Created by Zachariah Tom on 09/01/2023.
//

import Foundation

public struct PlaykitError: Codable {
    public let entryID: String?
    public let errorParameter: String? /// The parameter that triggered error or exception
    public let exception: String?
}
