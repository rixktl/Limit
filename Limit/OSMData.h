//
//  OSMData.h
//  Limit_beta
//
//  Created by Rix on 5/19/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

@interface OSMData : NSObject

@property NSMutableDictionary *NodeDictionary;
@property NSMutableDictionary *WayDictionary;
@property NSMutableDictionary *WayName;
@property NSMutableDictionary *WayTypeDictionary;
@property NSMutableDictionary *WaySpeedDictionary;

- (id)init;
- (id)initWithArray:(NSArray *)array;

+ (bool)checkWayType:(NSString *)type;
- (int)getLimit:(NSArray *)roadName withLatitude:(double)lat withLongitude:(double)lon;

@end
