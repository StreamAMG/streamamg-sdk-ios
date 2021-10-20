//
//  AMGInAppPurchase.swift
//  StreamAMG
//
//  Created by Mike Hall on 05/10/2021.
//

import Foundation

public struct AMGInAppPurchase: Codable{
    public let purchaseID: String
    public let purchaseName: String
    public let purchasePriceFormatted: String
    public let purchasePrice: Double
    public let purchaseDescription: String
//    let purchaseType: AMGPurchaseType
}

enum AMGPurchaseType {
    case subscription, nonconsumable
}
