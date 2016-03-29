//
//  InterfaceController.h
//  Limit WatchOS2 Extension
//
//  Created by Rix on 6/24/15.
//  Copyright © 2015 Rix. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

#import "Utility.h"
#import "RingController.h"

@interface InterfaceController : WKInterfaceController{
    RingController *Ring;
}


@end
