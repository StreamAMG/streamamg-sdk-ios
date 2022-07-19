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
    
    init(base64EncodedReceipt: String, payment : ReceiptPaymentModel?) {
        platform = "ios"
        receipt = ReceiptModelData(raw: base64EncodedReceipt, payment: payment)
    }
}

struct ReceiptModelData: Codable {
    var raw: String
    let payment : ReceiptPaymentModel?
}

struct ReceiptVerificationModel: Codable {
    let isVerified: Bool
}

public struct ReceiptPaymentModel: Codable {
    let countryCode: String?
    let currencyCode: String?
    let amount : Float?
    let discount : Float?
}
