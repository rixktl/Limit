//
//  LocationDataBase.h
//  Limit_beta
//
//  Created by Rix on 5/3/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import <Foundation/Foundation.h>
// Network check
#import "Reachability.h"
#import "Utility.h"
#import "OSMData.h"


@interface OSMXMLParser : NSObject <NSXMLParserDelegate>{
    id <NSXMLParserDelegate> delegate;
}

@property OSMData *finalData;

- (void)requestLimit:(double)latitude withLongitude:(double)longitude;

@end

