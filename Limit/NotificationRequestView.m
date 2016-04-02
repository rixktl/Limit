//
//  NotificationSettingView.m
//  Limit
//
//  Created by Rix Lai on 1/18/16.
//  Copyright © 2016 Rix. All rights reserved.
//

#import "NotificationRequestView.h"

@implementation NotificationRequestView


- (IBAction)enableButton:(id)sender {
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    NSLog(@"%@", @"Enabling notification");
}


-(void)switchToSetting{
    UIViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle: nil]instantiateViewControllerWithIdentifier:@"NotificationSetting"];
    [self presentViewController:v animated:YES completion:nil];
}


-(void)switchToMainPage{
    UIViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"MainSpeed"];
    [self presentViewController:v animated:YES completion:nil];
}


// Will be called when changing notification setting
- (void)receiveNotificationPermissionChange:(NSNotification *)notification{
    
    NSDictionary *info = notification.userInfo;
    
    if([[info objectForKey:@"setting"] types]){
        NSLog(@"%@", @"Succeed");
        [self switchToMainPage];
    }else{
        NSLog(@"%@", @"Fail");
        [self switchToSetting];
    }
}


-(void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationPermissionChange:) name:@"DID_REGISTER_USER_NOTIFICATION" object:nil];
}

@end
