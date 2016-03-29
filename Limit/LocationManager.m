//
//  LocationManager.m
//  Limit_beta
//
//  Created by Rix on 5/3/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import "LocationManager.h"
#include <dispatch/dispatch.h>



@interface LocationManager()

@property NSString *Address;

@property bool isMPH;

@end



@implementation LocationManager

@synthesize delegate;



// Initalize CLLocationManager with accuracy
- (id)init{
    self = [super init];
    
    GPSManager = [[CLLocationManager alloc] init];
    [GPSManager setDelegate:self];
    
    // Accuracy for GPS
    [GPSManager setDistanceFilter:kCLDistanceFilterNone];
    [GPSManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    
    _isMPH = true;
    
    return self;
}





// Start and Stop

// Start Location Update
- (void)startLocation{
    [GPSManager requestAlwaysAuthorization];
    [GPSManager startUpdatingLocation];
    [Utility debugLog:@"Started" withBelong:@"startLocation"];

}


// Stop Location Update
- (void)stopLocation{
    [GPSManager stopUpdatingLocation];
    [Utility debugLog:@"Stopped" withBelong:@"stopLocation"];
}


// Set unit
- (void)setUnit:(bool)isMPH{
    _isMPH = isMPH;
}



// Update All data

// Update Speed, State and Coordinate
// It doesn't update as frequence when staying at the same place
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    //[Utility debugLog:@"Generating Data . . . " withBelong:@"LocationUpdate"];
    
    if([self.delegate conformsToProtocol:@protocol(LocationManagerDelegate)]) {
        
        [Utility debugLog:@"Generating Data . . . " withBelong:@"LocationUpdate"];
        
        
        CLLocation *newLocation = [locations lastObject];

        double speed = newLocation.speed;
        // Convert with unit
        speed = [Utility getPossibleValue:speed];
        if(_isMPH){
            speed = [Utility source2MPH:speed];
        }else{
            speed = [Utility source2KPH:speed];
        }
        
        NSArray *locationInfo = [NSArray arrayWithObjects:
                                 
                                 // Speed
                                 [NSNumber numberWithDouble:speed],
                                 
                                 // State
                                 [self locationToState:newLocation],
                                 //@"CA",
         
                                 // Latitude
                                  [NSNumber numberWithDouble:
                                   [Utility coordinateAccuracy:newLocation.coordinate.latitude]
                                   ],
         
                                 // Longitude
                                  [NSNumber numberWithDouble:
                                   [Utility coordinateAccuracy:newLocation.coordinate.longitude]
                                   ],
         
                                   nil];
        
        if([locationInfo count] == 4){
            [Utility debugLog:@"Updating Data . . . " withBelong:@"LocationUpdate"];
            [self.delegate LocationUpdate:locationInfo];
        }else{
            [Utility debugLog:@"LackOfInfo" withBelong:@"LocationUpdate"];
        }
    }
}





// Print Error
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [Utility errorLog:[NSString stringWithFormat:@"%@", error] withBelong:@"LocationManager"];
    
}






// Convert address

// Convert Location to State
- (NSString *)locationToState:(CLLocation *)location{
    NSString *address = [self locationToAddress:location];
    //[Utility debugLog:(NSString*)address withBelong:@"L2S"];
    return [self addressToState:address];
}



// Convert Location to Address(Long State)
- (NSString *)locationToAddress:(CLLocation *)location{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation: location completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         // Get nearby address
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         
         // Long State
         _Address = placemark.administrativeArea;
     }];
    
    // Will return null for first time
    // Second time of getting location update will be fine
    return _Address;
}



// Convert Address(Long State) to Short State
- (NSString *)addressToState:(NSString *)address{
    return [[self StateList] objectForKey:address];
}



// List of State Abbreviations
- (NSDictionary *)StateList {
    
    static NSDictionary *Abbreviations = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Abbreviations = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Alabama",@"AL",
                             @"Alaska",@"AK",
                             @"Arizona",@"AZ",
                             @"Arkansas",@"AR",
                             @"California",@"CA",
                             @"Colorado",@"CO",
                             @"Connecticut",@"CT",
                             @"Delaware",@"DE",
                             @"District of columbia",@"DC",
                             @"Florida",@"FL",
                             @"Georgia",@"GA",
                             @"Hawaii",@"HI",
                             @"Idaho",@"ID",
                             @"Illinois",@"IL",
                             @"Indiana",@"IN",
                             @"Iowa",@"IA",
                             @"Kansas",@"KS",
                             @"Kentucky",@"KY",
                             @"Louisiana",@"LA",
                             @"Maine",@"ME",
                             @"Maryland",@"MD",
                             @"Massachusetts",@"MA",
                             @"Michigan",@"MI",
                             @"Minnesota",@"MN",
                             @"Mississippi",@"MS",
                             @"Missouri",@"MO",
                             @"Montana",@"MT",
                             @"Nebraska",@"NE",
                             @"Nevada",@"NV",
                             @"New hampshire",@"NH",
                             @"New jersey",@"NJ",
                             @"New mexico",@"NM",
                             @"New york",@"NY",
                             @"North carolina",@"NC",
                             @"North dakota",@"ND",
                             @"Ohio",@"OH",
                             @"Oklahoma",@"OK",
                             @"Oregon",@"OR",
                             @"Pennsylvania",@"PA",
                             @"Rhode island",@"RI",
                             @"South carolina",@"SC",
                             @"South dakota",@"SD",
                             @"Tennessee",@"TN",
                             @"Texas",@"TX",
                             @"Utah",@"UT",
                             @"Vermont",@"VT",
                             @"Virginia",@"VA",
                             @"Washington",@"WA",
                             @"West virginia",@"WV",
                             @"Wisconsin",@"WI",
                             @"Wyoming",@"WY",
                             nil];
    });
    
    return Abbreviations;
}





@end
