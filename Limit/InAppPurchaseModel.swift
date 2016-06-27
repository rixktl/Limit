//
//  InAppPurchaseModel.swift
//  Limit
//
//  Created by Rix Lai on 6/25/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
import StoreKit

/*
 * A model that manager in-app purchase
 */

internal protocol InAppPurchaseModelDelegate {
    func updatePurchaseInfo(productIdentifier: String, code: Int)
}

public class InAppPurchaseModel: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    internal let TRANSACTION_DEFERRED: Int = 1
    internal let TRANSACTION_PURCHASING: Int = 2
    internal let TRANSACTION_PURCHASED: Int = 3
    internal let TRANSACTION_RESTORED: Int = 4
    
    internal let TRANSACTION_ERROR_CANCELLED: Int = 5
    internal let TRANSACTION_ERROR_INVALID: Int = 6
    internal let TRANSACTION_ERROR_NOT_ALLOWED: Int = 7
    
    // Harcoded products (product request will tell whether they are available or not)
    private let defaultProductIdentifiers: [String] = ["California", "Oregon", "Washington"]
    private var productDict: [String:SKProduct] = [String:SKProduct]()
    internal var delegate: InAppPurchaseModelDelegate!
    
    override init() {
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    deinit {
        // Prevent from crash when deinit
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    /* Convert product identifier to localized name */
    public func convertProductIdentifierToName(productIdentifier: String) -> String? {
        return productDict[productIdentifier]?.localizedTitle
    }
    
    /* Return all valid product identifiers */
    public func getProductIdentifiers() -> [String] {
        // Return sorted string (casting keys to array is possible: [String](x.keys) )
        return productDict.keys.sort()
    }
    
    /* Request to purchase a product with product identifier */
    public func purchase(productIdentifier: String) -> Bool {
        // Ensure product exist
        guard (productDict[productIdentifier] != nil) else {
            return false
        }
        
        // Set up payment
        let payment: SKPayment = SKPayment.init(product: productDict[productIdentifier]!)
        // Add payment
        SKPaymentQueue.defaultQueue().addPayment(payment)
        return true
    }
    
    /* Request a restore */
    public func restore() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    /* Called when restore is completed */
    public func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        
    }
    
    /* Check if product is available */
    public func checkProductAvailability() {
        let productsRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: Set<String>(defaultProductIdentifiers))
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    /* Called when product request is responsed */
    public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let products: [SKProduct] = response.products
        for product in products {
            // Update dictionary of product
            self.productDict[product.productIdentifier] = product
        }
    }
    
    /* Called when transcation status changes */
    public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        // Loop for transcations
        for transaction in transactions {
            
            let productIdentifier: String = transaction.payment.productIdentifier
            
            // Check transaction state
            switch (transaction.transactionState) {
                
                // Delay
                case SKPaymentTransactionState.Deferred:
                    print("Deferred")
                    self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_DEFERRED)
                
                // Purchasing
                case SKPaymentTransactionState.Purchasing:
                    print("Purchasing")
                    self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_PURCHASING)
                    
                // Purchased
                case SKPaymentTransactionState.Purchased:
                    // Finish transaction
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                    print("Purchased")
                    self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_PURCHASED)
                    // Then save to local record
                
                // Restored
                case SKPaymentTransactionState.Restored:
                    // Finish transaction
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                    print("Restored")
                    self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_RESTORED)
                    // Then save to local record
                
                // Failed
                case SKPaymentTransactionState.Failed:
                    // Finish transaction
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                    
                    // TODO: error handling
                    switch transaction.error!.code {
                        // Cancelled
                        case SKErrorCode.PaymentCancelled.rawValue:
                            self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_ERROR_CANCELLED)
                        
                        // Invalid
                        case SKErrorCode.PaymentInvalid.rawValue:
                            self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_ERROR_INVALID)
                        
                        // Not allowed
                        case SKErrorCode.PaymentNotAllowed.rawValue:
                            self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_ERROR_NOT_ALLOWED)
                        
                        default:
                            break
                    }
                
            }
        }

    }
    

}
