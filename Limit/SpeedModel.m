//
//  SpeedModel.m
//  Limit
//
//  Created by Rix Lai on 1/17/16.
//  Copyright © 2016 Rix. All rights reserved.
//

#import "SpeedModel.h"

@interface SpeedModel ()

@property int currentSpeed, limitSpeed;
@property double latitude, longitude;
@property NSString *state, *address;
@property bool isMPH, isPurchased, isReady, checkPurchase;

@end


@implementation SpeedModel

static NSString *const MPH = @"M P H";
static NSString *const KPH = @"K P H";
static const int LIMIT_OFFSET = 5;   // Default as MPH
static const int DEFAULT_LIMIT = 70; // For non-purchased user only

// For purchased user, go to OSMData.m and change DefaultLimit there
static const bool purchaseBypass = true; // DO NOT SET TRUE FOR RELEASE VERSION
// MAKE IT TRUE IF STATE CHECK IS NOT NEEDED

#pragma mark - Initialize

- (id)init {
    self = [super init];

    // Initalize
    self.Manager = [[LocationManager alloc] init];
    self.DB = [[OSMXMLParser alloc] init];
    self.Geo = [[GoogleGeo alloc] init];

    self.currentSpeed = 0;
    self.limitSpeed = 0;
    self.isPurchased = purchaseBypass;
    self.checkPurchase = false;
    self.isReady = false;

    self.isMPH = true;
    if ([Utility loadData:@"Unit"] != nil) {
        self.isMPH = [[Utility loadData:@"Unit"] isEqualToString:MPH];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      [self setUnit:self.isMPH];
    });

    // Set delegate for updating location
    [self.Manager setDelegate:self];
    // Set unit
    [self.Manager setUnit:self.isMPH];

    return self;
}

#pragma mark - Accessors

- (void)startUpdate {
    // Start Location Service
    [self.Manager startLocation];
}

- (void)stopUpdate {
    [self.Manager stopLocation];
}

- (void)setUnit:(bool)isMPH {
    self.isMPH = isMPH;
    [self.Manager setUnit:self.isMPH];

    if (self.isMPH) {
        [Utility saveData:@"Unit" withValue:MPH];
        [self.delegate updateUnit:MPH];
    } else {
        [Utility saveData:@"Unit" withValue:KPH];
        [self.delegate updateUnit:KPH];
    }
}

- (void)flipUnit {
    if (self.isMPH) {
        [self setUnit:false];
    } else {
        [self setUnit:true];
    }
}

#pragma mark - Delegate

// Location data update called by LocationManager
- (void)LocationUpdate:(NSArray *)array {
    self.isReady = false;

    self.currentSpeed = round([[array objectAtIndex:0] intValue]);
    self.state = [array objectAtIndex:1];
    self.latitude = [[array objectAtIndex:2] doubleValue];
    self.longitude = [[array objectAtIndex:3] doubleValue];

    // Update current speed to delegate
    [self.delegate updateSpeed:self.currentSpeed];

    // Update speed limit
    [self updateLimitSpeed];
    // Update to delegate
    [self.delegate updateLimit:self.limitSpeed];
}

#pragma mark - Update speed limit

// Re-calculate speed limit
- (void)updateLimitSpeed {

    // Update purchase status
    if (!self.isPurchased && !self.checkPurchase) {
        self.isPurchased = [Utility loadBoolData:self.state];
        self.checkPurchase = true;
    }

    int offset = LIMIT_OFFSET; // default as MPH

    // Check if NOT purchased
    if (!self.isPurchased) {

        // Convert unit
        if (self.isMPH) {
            self.limitSpeed = DEFAULT_LIMIT;
        } else {
            offset = [Utility limit2kph:offset];
            self.limitSpeed = [Utility limit2kph:DEFAULT_LIMIT];
        }

    } else {

        // Send coordinates to database parsers
        [self.DB requestLimit:self.latitude withLongitude:self.longitude];
        // Send coordinates to GoogleGeo parsers
        [self.Geo requestGeo:self.latitude withLongitude:self.longitude];

        // Request limit
        int limit = [self.DB.finalData getLimit:self.Geo.roadName
                                   withLatitude:self.latitude
                                  withLongitude:self.longitude];

        // Convert unit
        if (self.isMPH) {
            self.limitSpeed = limit;
        } else {
            offset = [Utility limit2kph:offset];
            self.limitSpeed = [Utility limit2kph:limit];
        }
    }

    // Add offset if NOT using exact speed
    if ([[Utility loadData:@"Exact"] isEqualToString:@"On"]) {
        self.limitSpeed = self.limitSpeed + offset;
    }

    self.isReady = true;
}

@end