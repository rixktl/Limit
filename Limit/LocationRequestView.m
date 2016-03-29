//
//  LocationServiceController.m
//  Limit
//
//  Created by Rix Lai on 12/25/15.
//  Copyright © 2015 Rix. All rights reserved.
//

#import "LocationRequestView.h"

@interface LocationRequestView()

@property CLLocationManager *GPSManager;

@end

@implementation LocationRequestView

- (IBAction)enableButton:(id)sender {
    [self.GPSManager requestAlwaysAuthorization];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.GPSManager = [[CLLocationManager alloc] init];
    [self.GPSManager setDelegate:self];
}


-(void)switchToNextPage{
    
    UIViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle: nil]instantiateViewControllerWithIdentifier:@"NotificationRequest"];
    [self presentViewController:v animated:YES completion:nil];
}

-(void)switchToSettings{
    UIViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"LocationSetting"];
    [self presentViewController:v animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    // Log authorization status
    if(status == kCLAuthorizationStatusAuthorizedAlways){
        [self switchToNextPage];
        NSLog(@"Enabled");
    }else if(status == kCLAuthorizationStatusNotDetermined){
        NSLog(@"Unknown");
    }else{
        [self switchToSettings];
        NSLog(@"Not Enabled");
    }
}

@end
