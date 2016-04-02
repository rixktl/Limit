//
//  IAPManager.m
//  Limit
//
//  Created by Rix on 5/25/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import "IAPManager.h"

@interface IAPManager ()
@property NSArray *skProduct;
@end


@implementation IAPManager

- (id)init {
    self = [super init];

    // Initialize
    self.productID = [[NSMutableArray alloc] init];
    self.skProduct = [[NSArray alloc] init];

    // Start listening to transcation
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    return self;
}

- (void)dealloc {
    // Remove all transcations
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - Product id

// Request for checking product id
- (void)verifyProductID:(NSArray *)product {
    // Copy productID
    self.productID = [product mutableCopy];

    // Setup request
    NSSet *productIdentifiers = [NSSet setWithArray:product];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
        initWithProductIdentifiers:productIdentifiers];
    // Request with delegate to itself
    productsRequest.delegate = self;
    [productsRequest start];
    [Utility debugLog:@"Requested for productID check"
           withBelong:@"IAPManager"];
}

// Check response if products are available
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response {

    // Get products
    self.skProduct = response.products;

    // Loop for invalidProductID and remove it
    for (int i = 0; i < [response.invalidProductIdentifiers count]; i++) {
        // Check if product id is invalid
        if ([self.productID containsObject:[response.invalidProductIdentifiers
                                               objectAtIndex:i]])
            // Remove product id
            [self.productID removeObject:[response.invalidProductIdentifiers
                                             objectAtIndex:i]];
    }

    // So the verified SKProduct should be corresponding to productID, 1 to 1
}

#pragma mark - Restore

// Restore
- (void)restore {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

// Confirm response of restore
- (void)paymentQueueRestoreCompletedTransactionsFinished:
    (SKPaymentQueue *)queue {
    // Loop for transcations
    for (SKPaymentTransaction *transaction in queue.transactions) {
        // Check transaction state
        if (transaction.transactionState == SKPaymentTransactionStateRestored) {
            // Successfully restored, end transcation
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            // Save to local data for restored record
            [Utility saveBoolData:transaction.payment.productIdentifier
                        withValue:true];
            [Utility debugLog:@"Transaction:Restored" withBelong:@"IAPManager"];
            break;
        }
    }
}

#pragma mark - Purchase

// Purchase product by index
- (void)purchase:(int)index {
    // Set product and payment
    SKProduct *product = [self.skProduct objectAtIndex:index];
    SKPayment *payment = [SKPayment paymentWithProduct:product];

    // Issue payment to Queue
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

// Confirm response of purchase
- (void)paymentQueue:(SKPaymentQueue *)queue
    updatedTransactions:(NSArray *)transactions {
    // Loop for transcations
    for (SKPaymentTransaction *transaction in transactions) {

        // Check transaction state
        switch (transaction.transactionState) {

        // Waiting for answer
        case SKPaymentTransactionStateDeferred:
            break;
                
        // Purchasing
        case SKPaymentTransactionStatePurchasing:
            [Utility debugLog:@"Transaction:Purchasing"
                   withBelong:@"IAPManager"];
            break;

        // Purchased
        case SKPaymentTransactionStatePurchased:
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            // Save to local data for purchase record
            [Utility saveBoolData:transaction.payment.productIdentifier
                        withValue:true];
            [Utility debugLog:@"Transaction:Purchased"
                   withBelong:@"IAPManager"];
            break;

        // Restored
        case SKPaymentTransactionStateRestored:
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            // Save to local data for restored record
            [Utility saveBoolData:transaction.payment.productIdentifier
                        withValue:true];
            [Utility debugLog:@"Transaction:Restored" withBelong:@"IAPManager"];
            break;

        // Fail
        case SKPaymentTransactionStateFailed:
            // Check if cancelled
            if (transaction.error.code == SKErrorPaymentCancelled) {
                // Cancelled
                [Utility debugLog:@"Transaction:Cancelled"
                       withBelong:@"IAPManager"];
            }else{
                // Other errors
            }
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;

        }
    }
}

@end