//
//  LocationManager.h
//  Limit_beta
//
//  Created by Rix on 5/3/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "Utility.h"


@protocol LocationManagerDelegate
@required

- (void)LocationUpdate:(NSArray *)array;

@end



@interface LocationManager : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *GPSManager;
    id <LocationManagerDelegate> delegate;
}

@property id delegate;

- (void)startLocation;
- (void)stopLocation;
- (void)setUnit:(bool)isMPH;

@end
