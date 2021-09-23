//
//  AMGAnalyticsConfig.swift
//  StreamAMG
//
//  Created by Mike Hall on 17/09/2021.
//

import Foundation

public class AMGAnalyticsConfig {
    var analyticsService: AMGAnalyticsService = .DISABLED
    var accountCode: String = ""
    var partnerID: Int = 0
    
    init() {
        
    }
    
    public init(youboraAccountCode: String) {
        analyticsService = .YOUBORA
        accountCode = youboraAccountCode
    }
    
    public init(amgAnalyticsPartnerID: Int){
        analyticsService = .AMGANALYTICS
        partnerID = amgAnalyticsPartnerID
    }
}
