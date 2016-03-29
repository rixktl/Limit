//
//  RingController.h
//  Limit
//
//  Created by Rix on 5/26/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

#import "Utility.h"

@interface RingController : NSObject

- (id)init;
- (void)controlRing:(int)speed withLimit:(int)limit withBkgImage:(WKInterfaceGroup *)bkgImage;
- (void)randomRing:(WKInterfaceGroup *)bkgImage;
- (void)moveRing:(int)origin withDestination:(int)destination withBkgImage:(WKInterfaceGroup *)bkgImage
   withDirection:(bool)direction;

@end
