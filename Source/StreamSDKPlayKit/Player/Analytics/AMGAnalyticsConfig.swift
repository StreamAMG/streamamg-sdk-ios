//
//  AMGAnalyticsConfig.swift
//  StreamAMG
//
//  Created by Mike Hall on 17/09/2021.
//

import Foundation

public struct AMGAnalyticsConfig {
    var analyticsService: AMGAnalyticsService = .DISABLED
    var accountCode: String = ""
    var userName: String? = nil
    var partnerID: Int = 0
    var youboraParameters: [YouboraParameter] = []
    
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
    
    internal mutating func updateYouboraParameter(id: Int, value: String){
        
        if let param = youboraParameters.firstIndex(where: {$0.id == id}), param < youboraParameters.count {
            youboraParameters.remove(at: param)
            }
            youboraParameters.append(YouboraParameter(id: id, value: value))
    }
    
    public class YouboraService {
        var youboraParametersObject: [YouboraParameter] = []
        var accountCodeObject: String = ""
        var userNameObject: String? = nil
        
        public init(){
            
        }
        
        public func accountCode(_ code: String) -> YouboraService {
            accountCodeObject = code
            return self
        }
        
        public func userName(_ name: String) -> YouboraService {
            userNameObject = name
            return self
        }
        
        public func parameter(_ id: Int, value: String) -> YouboraService {
            if id > 0 && id < 21 {
                if youboraParametersObject.contains(where: {$0.id == id}){
                    print("ID \(id) already exists")
                } else {
                    youboraParametersObject.append(YouboraParameter(id: id, value: value))
                }
            } else {
                print("ID \(id) is out of range")
            }
            return self
        }
        
        public func build() -> AMGAnalyticsConfig {
            if accountCodeObject.count == 0 {
                print("Creating Youbora service with no account code")
            }
            var service = AMGAnalyticsConfig(youboraAccountCode: self.accountCodeObject)
            service.userName = userNameObject
            service.youboraParameters = youboraParametersObject
            return service
        }
    }
    
    public class AMGService {
        var partnerObject: Int = 0
        
        public init(){
            
        }
        
        public func partnerID(_ id: Int) -> AMGService {
            partnerObject = id
            return self
        }
        
        public func build() -> AMGAnalyticsConfig {
            if partnerObject == 0 {
                print("Creating AMG service with no PartnerID")
            }
            let service = AMGAnalyticsConfig(amgAnalyticsPartnerID: partnerObject)
            return service
        }
    }
}


