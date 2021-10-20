//
//  IAPDelegate.swift
//  StreamAMG
//
//  Created by Mike Hall on 05/10/2021.
//

import Foundation

internal protocol IAPDelegate {
    func updateIAPUI()
    func validatePurchase()
}
