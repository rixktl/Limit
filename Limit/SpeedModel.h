//
//  SpeedModel.h
//  Limit
//
//  Created by Rix Lai on 1/17/16.
//  Copyright © 2016 Rix. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Utility.h"
#import "LocationManager.h"
#import "OSMXMLParser.h"
#import "GoogleGeo.h"

@protocol SpeedModelDelegate <NSObject>
@required
- (void)updateSpeed:(int)currentSpeed;
- (void)updateUnit:(NSString*)unit;
- (void)updateLimit:(int)limitSpeed;
@end



@interface SpeedModel : NSObject<LocationManagerDelegate>{
    LocationManager *Manager;
    OSMXMLParser *DB;
    GoogleGeo *Geo;
    id<SpeedModelDelegate> delegate;
}

@property id delegate;


- (void)startUpdate;
- (void)stopUpdate;
- (void)flipUnit;

@end

