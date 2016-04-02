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


- (void)checkNotificationPermission{
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        NSLog(@"Succeed to get permission");
        [self switchToMainPage];
    }else{
        NSLog(@"Fail to get permission");
    }
}



-(void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNotificationPermission) name:@"DID_BECOME_ACTIVE" object:nil];
    
}

@end
