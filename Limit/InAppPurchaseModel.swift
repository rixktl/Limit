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
    func updatePurchaseInfo(_ productIdentifier: String, code: Int)
}

open class InAppPurchaseModel: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    internal let TRANSACTION_DEFERRED: Int = 1
    internal let TRANSACTION_PURCHASING: Int = 2
    internal let TRANSACTION_PURCHASED: Int = 3
    internal let TRANSACTION_RESTORED: Int = 4
    
    internal let TRANSACTION_ERROR_CANCELLED: Int = 5
    internal let TRANSACTION_ERROR_INVALID: Int = 6
    internal let TRANSACTION_ERROR_NOT_ALLOWED: Int = 7
    
    // Harcoded products (product request will tell whether they are available or not)
    fileprivate let defaultProductIdentifiers: [String] = ["California", "Oregon", "Washington"]
    fileprivate var productDict: [String:SKProduct] = [String:SKProduct]()
    internal var delegate: InAppPurchaseModelDelegate!
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        // Prevent from crash when deinit
        SKPaymentQueue.default().remove(self)
    }
    
    /* Convert product identifier to localized name */
    open func convertProductIdentifierToName(_ productIdentifier: String) -> String? {
        return productDict[productIdentifier]?.localizedTitle
    }
    
    /* Return all valid product identifiers */
    open func getProductIdentifiers() -> [String] {
        // Return sorted string (casting keys to array is possible: [String](x.keys) )
        return productDict.keys.sorted()
    }
    
    /* Request to purchase a product with product identifier */
    open func purchase(_ productIdentifier: String) -> Bool {
        // Ensure product exist
        guard (productDict[productIdentifier] != nil) else {
            return false
        }
        
        // Set up payment
        let payment: SKPayment = SKPayment.init(product: productDict[productIdentifier]!)
        // Add payment
        SKPaymentQueue.default().add(payment)
        return true
    }
    
    /* Request a restore */
    open func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    /* Called when restore is completed */
    open func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
    }
    
    /* Check if product is available */
    open func checkProductAvailability() {
        let productsRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: Set<String>(defaultProductIdentifiers))
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    /* Called when product request is responsed */
    open func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products: [SKProduct] = response.products
        for product in products {
            // Update dictionary of product
            self.productDict[product.productIdentifier] = product
        }
    }
    
    /* Called when transcation status changes */
    open func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        // Loop for transcations
        for transaction in transactions {
            
            let productIdentifier: String = transaction.payment.productIdentifier
            
            // Check transaction state
            switch (transaction.transactionState) {
                
                // Delay
                case SKPaymentTransactionState.deferred:
                    print("Deferred")
                    self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_DEFERRED)
                
                // Purchasing
                case SKPaymentTransactionState.purchasing:
                    print("Purchasing")
                    self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_PURCHASING)
                    
                // Purchased
                case SKPaymentTransactionState.purchased:
                    // Finish transaction
                    SKPaymentQueue.default().finishTransaction(transaction)
                    print("Purchased")
                    self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_PURCHASED)
                    // Then save to local record
                
                // Restored
                case SKPaymentTransactionState.restored:
                    // Finish transaction
                    SKPaymentQueue.default().finishTransaction(transaction)
                    print("Restored")
                    self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_RESTORED)
                    // Then save to local record
                
                // Failed
                case SKPaymentTransactionState.failed:
                    // Finish transaction
                    SKPaymentQueue.default().finishTransaction(transaction)
                    
                    // TODO: error handling
                    switch transaction.error! {
                        // Cancelled
                        case SKError.paymentCancelled:
                            self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_ERROR_CANCELLED)
                        
                        // Invalid
                        case SKError.paymentInvalid:
                            self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_ERROR_INVALID)
                        
                        // Not allowed
                        case SKError.paymentNotAllowed:
                            self.delegate.updatePurchaseInfo(productIdentifier, code: TRANSACTION_ERROR_NOT_ALLOWED)
                        
                        default:
                            break
                    }
                
            }
        }

    }
    

}
