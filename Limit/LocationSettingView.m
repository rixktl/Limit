//
//  LocationSettingsView.m
//  Limit
//
//  Created by Rix Lai on 12/27/15.
//  Copyright © 2015 Rix. All rights reserved.
//

#import "LocationSettingView.h"

@interface LocationSettingView()

- (IBAction)openSettings:(id)sender;

@property CLLocationManager *GPSManager;

@end


@implementation LocationSettingView

- (IBAction)openSettings:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.GPSManager = [[CLLocationManager alloc] init];
    [self.GPSManager setDelegate:self];
}

-(void)switchToMainPage{
    UIViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle: nil]instantiateViewControllerWithIdentifier:@"MainSpeed"];
    [self presentViewController:v animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    // Log authorization status
    if(status == kCLAuthorizationStatusAuthorizedAlways){
        [self switchToMainPage];
        NSLog(@"Enabled");
    }else if(status == kCLAuthorizationStatusNotDetermined){
        NSLog(@"Unknown");
    }else{
        NSLog(@"Not Enabled");
    }
}

@end
