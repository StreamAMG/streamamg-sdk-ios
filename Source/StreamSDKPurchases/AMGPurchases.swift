//
//  AMGPurchases.swift
//  StreamAMG
//
//  Created by Mike Hall on 05/10/2021.
//

import Foundation
import StoreKit

public class AMGPurchases: IAPDelegate {
    public static let instance = AMGPurchases()
    
    private let auth = AuthenticationSDK.instance
    
    private let iapService = IAPService.shared
    
    private var apiURL = ""
    
    private var delegate: AMGPurchaseDelegate? = nil
    
    private var currentPurchase: AMGInAppPurchase? = nil
    
    private init() {
        iapService.delegate = self
    }
    
    public func setURL(url: String) {
        apiURL = url
    }
    
    public func setDelegate(_ purchaseDelegate: AMGPurchaseDelegate) {
        delegate = purchaseDelegate
    }
    
    public func startObserving() {
        iapService.startObserving()
    }
    
    
    public func stopObserving() {
        iapService.stopObserving()
    }
    
    /// With this API, you can validate purchases against CP using the JWT token from the last login response.
    /// - Parameter payment: Payment model
    public func validatePurchase(payment: ReceiptPaymentModel?) {
        self.validatePurchase(payment: payment, withJWTToken: auth.lastLoginResponse?.authenticationToken)
    }
    
    /// This API is intended for custom SSO integrations and enables the validation of purchases against CP.
    /// - Parameters:
    ///   - payment: Payment model
    ///   - withJWTToken: User JWT Token
    public func validatePurchase(payment: ReceiptPaymentModel?, withJWTToken: String?) {
        
        
        guard
            let receiptUrl = Bundle.main.appStoreReceiptURL,
            let receiptData = try? Data(contentsOf: receiptUrl)
        else {
            self.delegate?.purchaseSuccessfulWithoutValidation(payment: payment, error: StreamAMGError(message: "The purchase was made successfully with the App Store but the SDK was not able to validate the purchase with AMG Backend, Receipt URL or Receipt Data are invalid."))
            return
        }
        
        guard
            let apiKey = withJWTToken, apiKey.count > 0
        else {
            self.delegate?.purchaseSuccessfulWithoutValidation(payment: payment, error: StreamAMGError(message: "The purchase has been completed successfully through the AppStore. However, to validate the purchase with the AMG backend, you need to call the #validatePurchase  API using a custom JWT Token."))
            return
        }
        
        let receiptBase64 = receiptData.base64EncodedString(options: [])
        
        let request = ReceiptModel(base64EncodedReceipt: receiptBase64, payment: payment)
        do {
            let body = try JSONEncoder().encode(request)
            
            StreamAMGSDK.sendPostRequest("\(apiURL)iap/verify?apisessionid=\(apiKey)", body: body){ (result: Result<ReceiptVerificationModel, StreamAMGError>) in
                switch result {
                case .success(let data):
                    if data.isVerified {
                        if let currentPurchase = self.currentPurchase {
                            DispatchQueue.main.async {
                                self.delegate?.purchaseSuccessful(purchase: currentPurchase)
                            }
                        }
                    } else {
                        if let myPurchase = self.currentPurchase {
                            DispatchQueue.main.async {
                                self.delegate?.purchaseFailed(purchase: myPurchase, error: StreamAMGError(message: "Receipt verification failed"))
                            }
                        }
                    }
                    
                case .failure(let error):
                    if let currentPurchase = self.currentPurchase {
                        DispatchQueue.main.async {
                            self.delegate?.purchaseFailed(purchase: currentPurchase, error: error)
                        }
                    }
                }
            }
        } catch {
            if let currentPurchase = self.currentPurchase {
                DispatchQueue.main.async {
                    self.delegate?.purchaseFailed(purchase: currentPurchase, error: StreamAMGError(message: "Receipt Invalid"))
                }
            }
        }
    }
    
    public func canMakePayments() -> Bool {
        return iapService.canMakePayments()
    }
    
    
    public func availablePurchases() -> [AMGInAppPurchase] {
        return iapService.iapList
    }
    
    public func purchase(product: AMGInAppPurchase) {
        currentPurchase = product
        iapService.buy(product: product) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("Product purchased on the AppStore, validation in progress. - \(product.purchaseName)")
                case .failure(let error):
                    print("Product purchased! - \(product.purchaseName) - \(error)")
                    DispatchQueue.main.async {
                        self.delegate?.purchaseFailed(purchase: product, error: error)
                    }
                }
            }
        }
    }
    
    public func populateProductList(withProducts:[String]? = nil){
        if let products = withProducts, !products.isEmpty{
            fetchPackages(withProducts: products)
        } else {
            StreamAMGSDK.sendRequest("\(apiURL)api/v1/package?type=iap"){ (result: Result<PurchasePackagesResponse, StreamAMGError>) in
                switch result {
                case .success(let data):
                    self.fetchPackages(withProducts: data.packages())
                    
                    
                case .failure(let error):
                    self.delegate?.onFailedToRetrieveProducts(code: error.code, error: error.getAllMessages())
                }
            }
        }
    }
    
    func fetchPackages(withProducts:[String]){
        iapService.getProducts(fromList: withProducts){result in
            switch result {
            case .success(let amgProducts):
                DispatchQueue.main.async {
                    self.delegate?.purchasesAvailable(purchases: amgProducts)
                }
            case .failure(let error):
                self.delegate?.onFailedToRetrieveProducts(code: -1, error: [error.localizedDescription])
            }
        }
    }
    
    func updateIAPUI() {
        
    }
    
    
}
