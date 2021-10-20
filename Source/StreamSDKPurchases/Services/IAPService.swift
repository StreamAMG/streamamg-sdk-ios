//
//  IAPService.swift
//  StreamAMG
//
//  Created by Mike Hall on 05/10/2021.
//

import Foundation
import StoreKit

public class IAPService: NSObject, SKPaymentTransactionObserver {
    
    var delegate: IAPDelegate? = nil
    
    var skuList: [SKProduct] = []
    var iapList: [AMGInAppPurchase] = []
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased:
                onBuyProductHandler?(.success(true))
                delegate?.validatePurchase()
                    SKPaymentQueue.default().finishTransaction(transaction)
                
            case .restored:
                break
            case .failed:
                if let error = transaction.error as? SKError {
                    if error.code != .paymentCancelled {
                        onBuyProductHandler?(.failure(StreamAMGError(message: error.localizedDescription)))
                    } else {
                        onBuyProductHandler?(.failure(StreamAMGError(message: "Payment was cancelled")))
                    }
                    print("IAP Error:", error.localizedDescription)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred, .purchasing: break
            @unknown default: break
            }
        }
    }
    

    internal enum IAPManagerError: Error {
        case noProductIDsFound
        case noProductsFound
        case paymentWasCancelled
        case productRequestFailed
    }
    
    internal static let shared = IAPService()
    var onReceiveProductsHandler: ((Result<[AMGInAppPurchase], IAPManagerError>) -> Void)?
    var onBuyProductHandler: ((Result<Bool, StreamAMGError>) -> Void)?
    private override init() {
        super.init()
    }
    
    
//    fileprivate func getProductIDs() -> [String]? {
//        guard let url = Bundle.main.url(forResource: "IAP_ProductIDs", withExtension: "plist") else { return nil }
//        do {
//            let data = try Data(contentsOf: url)
//            let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
//            return productIDs
//        } catch {
//            print(error.localizedDescription)
//            return nil
//        }
//    }
    
    func getProducts(fromList: [String], withHandler productsReceiveHandler: @escaping (_ result: Result<[AMGInAppPurchase], IAPManagerError>) -> Void) {
        // Keep the handler (closure) that will be called when requesting for
        // products on the App Store is finished
        
        iapList.removeAll()
        skuList.removeAll()
        
        onReceiveProductsHandler = productsReceiveHandler
    
     
        // Initialize a product request.
        let request = SKProductsRequest(productIdentifiers: Set(fromList))
     
        // Set self as the its delegate.
        request.delegate = self
     
        // Make the request.
        request.start()
    }
    
    func buy(product: AMGInAppPurchase, withHandler handler: @escaping ((_ result: Result<Bool, StreamAMGError>) -> Void)) {
        guard let iap = skuList.first(where: {$0.productIdentifier == product.purchaseID}) else {
            handler(.success(false))
            return
        }
        let payment = SKPayment(product: iap)
        SKPaymentQueue.default().add(payment)
        onBuyProductHandler = handler
    }
    
    func getPriceFormatted(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
    
    func startObserving() {
    SKPaymentQueue.default().add(self)
    }
     
     
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func createProductsList(products: [SKProduct]) {
        skuList.append(contentsOf: products)
        products.forEach{item in
            iapList.append(AMGInAppPurchase(purchaseID: item.productIdentifier, purchaseName: item.localizedTitle, purchasePriceFormatted: "\(item.price)", purchasePrice: Double(truncating: item.price), purchaseDescription: item.localizedDescription))
        }
    }

}

extension IAPService: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Get the available products contained in the response.
        let products = response.products
     
        createProductsList(products: products)
        // Check if there are any products available.
        if products.count > 0 {
            // Call the following handler passing the received products.
            onReceiveProductsHandler?(.success(iapList))
        } else {
            // No products were found.
            onReceiveProductsHandler?(.failure(.noProductsFound))
        }
    }
}


extension IAPService.IAPManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noProductIDsFound: return "No In-App Purchase product identifiers were found."
        case .noProductsFound: return "No In-App Purchases were found."
        case .productRequestFailed: return "Unable to fetch available In-App Purchase products at the moment."
        case .paymentWasCancelled: return "In-App Purchase process was cancelled."
        }
    }
}

