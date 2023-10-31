//
//  AMGPurchaseDelegate.swift
//  StreamAMG
//
//  Created by Mike Hall on 05/10/2021.
//

import Foundation

public protocol AMGPurchaseDelegate {
    /// The purchase was made successfully with the App Store but the SDK was not able to validate the purchase with AMG Backend
    func purchaseSuccessfulWithoutValidation(payment: ReceiptPaymentModel?, error: StreamAMGError)
    func purchaseSuccessful(purchase: AMGInAppPurchase)
    func purchaseFailed(purchase: AMGInAppPurchase, error: StreamAMGError)
    func purchasesAvailable(purchases: [AMGInAppPurchase])
    func onFailedToRetrieveProducts(code: Int, error: [String])
}
