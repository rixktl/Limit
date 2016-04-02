//
//  AppDelegate.h
//  Limit
//
//  Created by Rix on 5/3/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "Utility.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, WCSessionDelegate>
@property(strong, nonatomic) UIWindow *window;
@end