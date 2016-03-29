//
//  NotificationSettingView.m
//  Limit
//
//  Created by Rix Lai on 1/31/16.
//  Copyright © 2016 Rix. All rights reserved.
//

#import "NotificationSettingView.h"

@implementation NotificationSettingView

- (IBAction)openSettings:(id)sender {
    NSLog(@"%@", @"open setting-S");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}


-(void)switchToMainPage{
    UIViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"MainSpeed"];
    [self presentViewController:v animated:YES completion:nil];
    NSLog(@"%@", @"Switching to main page");
}


// Will be called when changing notification setting
- (void)receiveNotificationPermissionChange:(NSNotification *)notification{
    
    NSDictionary *info = notification.userInfo;
    
    NSLog(@"%lu",(unsigned long)[[info objectForKey:@"setting"] types]);
    
    if([[info objectForKey:@"setting"] types]){
        NSLog(@"%@", @"Succeed-S");
        [self switchToMainPage];
    }else{
        NSLog(@"%@", @"Fail-S");
    }
}


-(void)viewDidLoad{
    [super viewDidLoad];
    
    // DOESN'T WORK
    // Need to relaunch the app in order to make changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationPermissionChange:) name:@"DID_REGISTER_USER_NOTIFICATION" object:nil];

}

@end
