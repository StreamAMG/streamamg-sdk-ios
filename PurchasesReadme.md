
StreamSDK Purchases Module
=====================
The Purchases SDK allows CloudPay users a simple way to purchase Subscriptions and In App Purchases from the App Store and integrate them into CloudPay.

It depends on the Authentication module to provide an authenticated CloudPay user to tie the associated purchases to.

The module includes the ability to fetch the list of available purchases from the Apple AppStoreConnect backend and supply it either via a delegate or on demand (if available), as well as completing the purchase via the App Store and sending the receipt to CloudPay for validation and access to entitlements

The StoreKit package is not a required import in the app itself.

Quick Start Guide
======

Cocoapods implementation
=====

Currently, the only supported way of installing the StreamAMG SDK is via Cocoapods.

The Core module is automatically installed as a pod dependency for all pods that support it

If Cocoapods is not installed on your Mac, follow the instructions [here](https://guides.cocoapods.org/using/getting-started.html)

If Cocoapods is not initialted for your project, open a terminal window, navigate to the root directory of your project and enter the following command:

```
pod init
```

In the Podfile file that has been created, add the following line after the '# Pods for (your project) line:

```
pod 'StreamAMGSDK/Purchases'
```

Now, again from the rood directory of your project, in a terminal, enter the following command:

```
pod install (or... pod update to also refresh any pods you already have)
```

The pod will be installed and available to use when your project is opened using the newly created (projectname).xcworkspace file, this should always be used instead of the xcodeproj file in a pods project.

Please use the same version for all modules to prevent dependency errors.

API Overview
============

##Accesing the SDK

To access the SDK, you should import it in any swift file that requires it:

```
import StreamAMGSDK
```

##Setting up Purchases

The purchase SDK should be accessed via it's singleton instance

```
let iapModule = AMGPurchases.instance
```

##Add an observer for the purchases module

The module must be instructed to observe any calls from AppStoreConnect (via StoreKit), this includes listening for available packages and awaiting the results of a purchase attempt.

The following methods should be called when starting and stopping this process:
``` Swift
        iapModule.startObserving()
        iapModule.stopObserving()
```

It doesn't fully matter when these methods are called, but it is suggested that it is done either in the AppDelegate (pre Xcode 11 / iOS13 projects):
``` Swift
    func applicationDidBecomeActive(_ application: UIApplication) {
        AMGPurchases.instance.startObserving()    
    }

    func applicationWillResignActive(_ application: UIApplication) {
        AMGPurchases.instance.stopObserving()
    }    
```

or SceneDelegate (Xcode 11 / iOS13 projects onwards):
``` Swift
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        AMGPurchases.instance.startObserving()
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        AMGPurchases.instance.stopObserving()
    }    
```

##Setting a valid URL

It is required that a valid URL is passed to the SDK before it is usable:

```
iapModule.setURL("https:validURL.test.com/")
```
The URL should be followed by a trailing front slash

##The AMGPurchasesDelegate

To react to any product lists or purchases made with the Purchases module, a delegate is provided:

``` Swift
public protocol AMGPurchaseDelegate {
    func purchaseSuccessful(purchase: AMGInAppPurchase)
    func purchaseFailed(purchase: AMGInAppPurchase, error: StreamAMGError)
    func purchasesAvailable(purchases: [AMGInAppPurchase])
    func onFailedToRetrieveProducts(code: Int, error: [String])
}
```

This delegate is set using the following method:

``` Swift
    iapModule.setDelegate(delegate) //Where 'delegate' is a class that conforms to AMGPurchasesDelegate
```

Fetching Packages from Apple
========

To fetch available packages from Apple, a list of desired packages is required, these packages can either be passed to the purchases module as a String array, or collected by the SDK from the packages endpoint.

The following method is provided in the purchases singleton:

``` Swift
    public func populateProductList(withProducts:[String]? = nil)
```

To return the available packages from a list that you provide, use the following call:

``` Swift
        iapModule.populateProductList(withProducts: ["product1", "product2", "product3"])
```

This will only return the products specified if they exist in AppStoreConnect.

To return any products that are available in CloudPay (via the packages endpoint), then simply call:


``` Swift
        iapModule.populateProductList()
```

This calls the packages endpoint, creates the list of required packages and then retrieves all available packages in AppStoreConnect

For both of these calls, the available packages are delivered to the AMGPurchaseDelegate method:

``` Swift
    func purchasesAvailable(purchases: [AMGInAppPurchase])
```

which should then update the UI if required.






The AMGInAppPurchase model
=========

To simplify purchases, and to remove the necesity of importing StoreKit into any views which require it, all purchases available to the user are represented by the AMGInAppPurchase model:

``` Swift
    public let purchaseID: String //The SKU of the product
    public let purchaseName: String //The name of the product as retrieved from AppStoreConnect
    public let purchasePriceFormatted: String //The price as formatted by AppStoreConnect
    public let purchaseDescription: String //A description of the product as retrieved from AppStoreConnect
```

An array of these products are available from the Purchases module, once retrieved from AppStoreConnect, by calling the following method:

``` Swift
     iapModule.availablePurchases()
```

Making a purchase
=======================

To make a purchase with the purchase module, simply use the following call:

``` Swift
     purchase(product: item) // Where 'item' is a valid AMGInAppPurchase
```

This will start the purchase process for the user and, if successful will send the receipt to StreamAMG for processing, adding the required entitlements to the user's CloudPay account.

The following AMGPurchaseDelegate method :

``` Swift
    func purchaseSuccessful(purchase: AMGInAppPurchase)
```

Will listen for a success (Receipt validated and entitlement added).

A failed purchase or receipt validation issue will result in the following method being triggered:
``` Swift
    func purchaseFailed(purchase: AMGInAppPurchase, error: StreamAMGError)
```

Where 'error' is a standard StreamAMGError (see 'Core' module)

Validate a purchase
=======================

``` Swift
     validatePurchase(payment: ReceiptPaymentModel?)
     validatePurchase(payment: ReceiptPaymentModel?, withJWTToken: String?)
```
This method validates the purchase you just completed. This method also supports sending an optional custom JWT Token. You can make use of the custom JWT Token if you are not using the login functionality provided by the StreamAMG Authentication API.

If you are using custom token to validate the purchase, we recommend using the startSession() API provided by the StreamAMG Authentication API to log the user sessions and to get CloudPay, check the concurrency.

Change Log:
===========

All notable changes to this project will be documented in this section.
### 1.2.0 - Updated AMGPurchaseDelegate to include error listener when products retrieval fails

### 1.1.10 - Updated valdiatePurchase API to accept custom JWT Token

### 1.0 - Release

### Beta releases

### 0.10 - Purchases Module added to SDK

### 0.1 -> 0.9 - No Purchases Module
