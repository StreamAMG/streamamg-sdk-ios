//
//  ReceiptModel.swift
//  StreamAMGSDKHub
//
//  Created by Mike Hall on 17/06/2021.
//

import Foundation

struct ReceiptModel: Codable {
    let receipt: ReceiptModelData
    let platform: String
    
    init(base64EncodedReceipt: String) {
        platform = "ios"
        receipt = ReceiptModelData(raw: base64EncodedReceipt)
    }
}

struct ReceiptModelData: Codable {
    var raw: String
}

struct ReceiptVerificationModel: Codable {
    let isVerified: Bool
}
