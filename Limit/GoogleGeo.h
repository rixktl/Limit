//
//  GoogleGeo.h
//  Limit_beta
//
//  Created by Rix on 5/6/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import <Foundation/Foundation.h>
// Network check
#import "Reachability.h"
#import "Utility.h"

@interface GoogleGeo : NSObject <NSXMLParserDelegate>{
    id <NSXMLParserDelegate> delegate;
}

@property NSArray *roadName;

- (void)requestGeo:(double)latitude withLongitude:(double)longitude;

@end

