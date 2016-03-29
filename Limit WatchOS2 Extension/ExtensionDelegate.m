//
//  ExtensionDelegate.m
//  Limit WatchOS2 Extension
//
//  Created by Rix on 6/24/15.
//  Copyright © 2015 Rix. All rights reserved.
//

#import "ExtensionDelegate.h"

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    // Perform any final initialization of your application.
    
    if ([WCSession isSupported]) {
        [[WCSession defaultSession] setDelegate:self];
        [[WCSession defaultSession] activateSession];
    }
}

- (void)applicationDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

#pragma mark - WCSessionDelegate

-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DID_RECEIVE_MESSAGE" object:self userInfo:message];
}

@end
