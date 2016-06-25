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
    
    /* Called when product request is responsed */
    public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
    }
    
    /* Called when restore is completed */
    public func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        
    }
    
    /* Called when transcation status changes */
    public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
}
