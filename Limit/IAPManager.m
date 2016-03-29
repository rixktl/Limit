//
//  IAPManager.m
//  Limit_beta
//
//  Created by Rix on 5/25/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import "IAPManager.h"

@interface IAPManager()

@property NSArray *skProduct;

@end



@implementation IAPManager


- (id)init{
    self = [super init];
    
    self.productID = [[NSMutableArray alloc] init];
    self.skProduct = [[NSArray alloc] init];
    
    // Start listening to transcation
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    return self;
}



- (void)dealloc {
    // Remove all transcation
    //otherwise, next time will crash
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}





// Request for checking productID
- (void)verifyProductID:(NSArray *)product{
    // Copy productID
    self.productID = [product mutableCopy];
    
    // Build a request
    NSSet *productIdentifiers = [NSSet setWithArray:product];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:productIdentifiers];
    // Request with delegate
    productsRequest.delegate = self;
    [productsRequest start];
    [Utility debugLog:@"Requested for productID check" withBelong:@"IAPManager"];
}



// Check response if products are available
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    // Verified SKProduct
    self.skProduct = response.products;
    
    // Loop for invalidProductID and remove it
    for(int i=0;i<[response.invalidProductIdentifiers count];i++){
        if([self.productID containsObject:[response.invalidProductIdentifiers objectAtIndex:i]])
            [self.productID removeObject:[response.invalidProductIdentifiers objectAtIndex:i]];
    }

    // So the verified SKProduct should be corresponding to productID, 1 to 1
}





// Restore
- (void)restore{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}



// Confirm response of restore
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    //NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            // Restored
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            // Save to local data for restored record
            [Utility saveBoolData:transaction.payment.productIdentifier withValue:true];
            [Utility debugLog:@"Transaction:Restored" withBelong:@"IAPManager"];
            break;
        }
    }
}





// Purchase product by index
- (void)purchase:(int)index{
    // Set product and build payment
    SKProduct *product = [self.skProduct objectAtIndex:index];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    // Issue payment to Queue
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}



// Confirm response of purchase
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    
    for(SKPaymentTransaction *transaction in transactions){
        
        switch(transaction.transactionState){
                
            case SKPaymentTransactionStatePurchasing:
                // Purchasing
                [Utility debugLog:@"Transaction:Purchasing" withBelong:@"IAPManager"];
                break;
                
            case SKPaymentTransactionStatePurchased:
                // Purchased
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // Save to local data for purchase record
                [Utility saveBoolData:transaction.payment.productIdentifier withValue:true];
                [Utility debugLog:@"Transaction:Purchased" withBelong:@"IAPManager"];
                break;
                
            case SKPaymentTransactionStateRestored:
                // Restored
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // Save to local data for restored record
                [Utility saveBoolData:transaction.payment.productIdentifier withValue:true];
                [Utility debugLog:@"Transaction:Restored" withBelong:@"IAPManager"];
                break;
                
            case SKPaymentTransactionStateFailed:
                // Tansaction not finishing
                if(transaction.error.code == SKErrorPaymentCancelled){
                    // Cancelled
                    [Utility debugLog:@"Transaction:Cancelled" withBelong:@"IAPManager"];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateDeferred:
                break;
        }
    }
}



@end
