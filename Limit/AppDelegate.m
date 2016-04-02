//
//  AppDelegate.m
//  Limit
//
//  Created by Rix on 5/3/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

#pragma mark - ApplicationStatusDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Start WCSession for watch communication
    if ([WCSession isSupported]) {
        [[WCSession defaultSession] setDelegate:self];
        [[WCSession defaultSession] activateSession];
    }
    // No idle(screen off)
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    // Check if first time launching
    if (![Utility loadBoolData:@"Launched"]) {
        UIStoryboard *storyboard = self.window.rootViewController.storyboard;
        UIViewController *rootViewController = [storyboard
            instantiateViewControllerWithIdentifier:@"LocationRequest"];
        self.window.rootViewController = rootViewController;
        [self.window makeKeyAndVisible];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the
    // application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down
    // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive
    // state; here you can undo many of the changes made on entering the
    // background.
    // Register for notification center
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"WILL_ENTER_FOREGROUND"
                      object:self];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the
    // application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
    // Register for notification center
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"DID_BECOME_ACTIVE"
                      object:self];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Remove all local notifications
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - WCSessionDelegate

- (void)session:(nonnull WCSession *)session
    didReceiveApplicationContext:
        (nonnull NSDictionary<NSString *, id> *)applicationContext {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"DID_RECEIVE_APPLICATION_CONTEXT"
                      object:self
                    userInfo:applicationContext];
}

#pragma mark - didReceiveMessageDelegate

- (void)session:(WCSession *)session
    didReceiveMessage:(NSDictionary<NSString *, id> *)message {
    NSLog(@"receiving message");
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"DID_RECEIVE_MESSAGE"
                      object:self
                    userInfo:message];
}

#pragma mark - didRegisterUserNotificationSettings

- (void)application:(UIApplication *)application
    didRegisterUserNotificationSettings:
        (UIUserNotificationSettings *)notificationSettings {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"DID_REGISTER_USER_NOTIFICATION"
                      object:self
                    userInfo:[[NSDictionary alloc]
                                 initWithObjectsAndKeys:notificationSettings,
                                                        @"setting", nil]];
}

#pragma mark - didReceiveLocalNotification

- (void)application:(UIApplication *)application
    didReceiveLocalNotification:(UILocalNotification *)notification {
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

@end