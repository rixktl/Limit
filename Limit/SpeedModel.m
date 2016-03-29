//
//  SpeedModel.m
//  Limit
//
//  Created by Rix Lai on 1/17/16.
//  Copyright © 2016 Rix. All rights reserved.
//

#import "SpeedModel.h"


@interface SpeedModel()
@property int currentSpeed, limitSpeed;
@property double latitude, longitude;
@property NSString * state, * address;
@property bool isMPH, isPurchased, isReady, checkPurchase;
@end



@implementation SpeedModel
@synthesize delegate;

static NSString * const MPH = @"M P H";
static NSString * const KPH = @"K P H";

static const int LIMIT_OFFSET = 5; // Default as MPH
static const int DEFAULT_LIMIT = 70; // For non-purchased user only
                                    // For purchased user, go to OSMData.m and change DefaultLimit there

static const bool purchaseBypass = true; // DO NOT SET TRUE FOR RELEASE VERSION

- (id)init{
    self = [super init];
    
    // Initalize
    Manager = [[LocationManager alloc] init];
    DB = [[OSMXMLParser alloc] init];
    Geo = [[GoogleGeo alloc] init];
    
    _currentSpeed = 0;
    _limitSpeed = 0;
    _isPurchased = purchaseBypass;
    _checkPurchase = false;
    _isReady = false;
    
    _isMPH = true;
    if([Utility loadData:@"Unit"] != nil){
        _isMPH = [[Utility loadData:@"Unit"] isEqualToString:MPH];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setUnit:_isMPH];
    });
    
    // Set delegate for updating location
    [Manager setDelegate:self];
    // Set unit
    [Manager setUnit:_isMPH];
    
    return self;
}



- (void)startUpdate{
    // Start Location Service
    [Manager startLocation];
}



- (void)stopUpdate{
    [Manager stopLocation];
}



- (void)setUnit:(bool)isMPH{
    _isMPH = isMPH;
    [Manager setUnit:_isMPH];
    
    if(_isMPH){
        [Utility saveData:@"Unit" withValue:MPH];
        [self.delegate updateUnit:MPH];
    }else{
        [Utility saveData:@"Unit" withValue:KPH];
        [self.delegate updateUnit:KPH];
    }
}


- (void)flipUnit{
    if(_isMPH){
        [self setUnit:false];
    }else{
        [self setUnit:true];
    }
}


// Location data update called by LocationManager
- (void)LocationUpdate:(NSArray *)array{
    _isReady = false;
    
    _currentSpeed = round([[array objectAtIndex:0] intValue]);
    _state = [array objectAtIndex:1];
    _latitude= [[array objectAtIndex:2] doubleValue];
    _longitude = [[array objectAtIndex:3] doubleValue];
    
    [self.delegate updateSpeed:_currentSpeed];
    
    [self updateLimitSpeed];
}



- (void)updateLimitSpeed{
    
    // Update purchase status
    if(!_isPurchased && !_checkPurchase){
        _isPurchased = [Utility loadBoolData:_state];
        _checkPurchase = true;
    }
    
    int offset = LIMIT_OFFSET;// default as MPH
    
    // Check if NOT purchased
    if(!_isPurchased){
        
        // Convert unit
        if(_isMPH){
            _limitSpeed = DEFAULT_LIMIT;
        }else{
            offset = [Utility limit2kph:offset];
            _limitSpeed = [Utility limit2kph:DEFAULT_LIMIT];
        }
        
        
    }else{
        
        // Send to two parsers
        [DB requestLimit:_latitude withLongitude:_longitude];
        [Geo requestGeo:_latitude withLongitude:_longitude];
        
        // Get limit
        int limit = [DB.finalData getLimit:Geo.roadName
                              withLatitude:_latitude
                             withLongitude:_longitude];
                
        // Convert unit
        if(_isMPH){
            _limitSpeed = limit;
        }else{
            offset = [Utility limit2kph:offset];
            _limitSpeed = [Utility limit2kph:limit];
        }
        
    }
    
    // Add offset if NOT exact speed
    if([[Utility loadData:@"Exact"] isEqualToString:@"On"]){
        _limitSpeed = _limitSpeed + offset;
    }
    
    _isReady = true;
    [self.delegate updateLimit:_limitSpeed];
}





@end
