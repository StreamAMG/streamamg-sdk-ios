//
//  AMGPurchaseDelegate.swift
//  StreamAMG
//
//  Created by Mike Hall on 05/10/2021.
//

import Foundation

public protocol AMGPurchaseDelegate {
    func purchaseSuccessful(purchase: AMGInAppPurchase)
    func purchaseFailed(purchase: AMGInAppPurchase, error: StreamAMGError)
    func purchasesAvailable(purchases: [AMGInAppPurchase])
}
