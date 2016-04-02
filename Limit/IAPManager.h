//
//  IAPManager.h
//  Limit
//
//  Created by Rix on 5/25/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "Utility.h"

@interface IAPManager
    : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property NSMutableArray *productID;

- (void)verifyProductID:(NSArray *)productID;
- (void)purchase:(int)index;
- (void)restore;

@end