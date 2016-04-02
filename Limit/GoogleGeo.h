//
//  GoogleGeo.h
//  Limit
//
//  Created by Rix on 5/6/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "Utility.h"

@interface GoogleGeo : NSObject <NSXMLParserDelegate>

@property(nonatomic) id<NSXMLParserDelegate> delegate;
@property NSArray *roadName;

- (void)requestGeo:(double)latitude withLongitude:(double)longitude;

@end