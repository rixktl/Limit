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

public class InAppPurchaseModel: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    override init() {
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    deinit {
        // Prevent from crash when deinit
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    /* Called when product request is responsed */
    public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
    }
    
    /* Called when restore is completed */
    public func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        
    }
    
    /* Called when transcation status changes */
    public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        // Loop for transcations
        for transaction in transactions {
            
            // Check transaction state
            switch (transaction.transactionState) {
                
                // Delay
                case SKPaymentTransactionState.Deferred:
                    break
                    
                // Purchasing
                case SKPaymentTransactionState.Purchasing:
                    break
                    
                // Purchased
                case SKPaymentTransactionState.Purchased:
                    // Finish transaction
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                    // Then save to local record
                
                // Restored
                case SKPaymentTransactionState.Restored:
                    // Finish transaction
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                    // Then save to local record
                
                // Failed
                case SKPaymentTransactionState.Failed:
                    // Finish transaction
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                    // Check if cancelled
                    if (transaction.error!.code == SKErrorCode.PaymentCancelled.rawValue) {
                        // TODO: error handling
                    } else {
                        // Other errors
                    }
                    
            }
        }

    }

}
