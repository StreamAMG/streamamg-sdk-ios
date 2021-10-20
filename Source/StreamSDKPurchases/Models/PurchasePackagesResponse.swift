//
//  PurchasePackagesResponse.swift
//  StreamAMG
//
//  Created by Mike Hall on 05/10/2021.
//

import Foundation

struct PurchasePackagesResponse: Codable
    
 {
    let plans: [IAPPlan]
    func packages() -> [String] {
        var data: [String] = []
        plans.forEach {plan in
            if let iOSData = plan.data?.first(where: {$0.platform.lowercased() == "apple"}) {
                data.append(iOSData.productID)
            }
        }
        return data
    }
    enum CodingKeys: String, CodingKey {
      case plans = "SubscriptionPlanOptions"
    }
}

struct IAPPlan: Codable{
    let data:[IAPData]?
    enum CodingKeys: String, CodingKey {
      case data = "IAPData"
    }
}

struct IAPData: Codable{
    let platform: String
    let productID: String

    enum CodingKeys: String, CodingKey {
      case platform = "Platform"
        case productID = "ProductID"
    }
}
