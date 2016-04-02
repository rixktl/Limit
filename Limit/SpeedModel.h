//
//  SpeedModel.h
//  Limit
//
//  Created by Rix Lai on 1/17/16.
//  Copyright © 2016 Rix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleGeo.h"
#import "LocationManager.h"
#import "OSMXMLParser.h"
#import "Utility.h"

#pragma mark - Protocol

@protocol SpeedModelDelegate <NSObject>

@required

- (void)updateSpeed:(int)currentSpeed;
- (void)updateUnit:(NSString *)unit;
- (void)updateLimit:(int)limitSpeed;

@end

#pragma mark - Interface

@interface SpeedModel : NSObject <LocationManagerDelegate>

@property(nonatomic) LocationManager *Manager;
@property(nonatomic) OSMXMLParser *DB;
@property(nonatomic) GoogleGeo *Geo;
@property(nonatomic) id<SpeedModelDelegate> delegate;

- (void)startUpdate;
- (void)stopUpdate;
- (void)flipUnit;

@end