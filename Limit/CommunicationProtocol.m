//
//  CommunicationProtocol.m
//  Limit
//
//  Created by Rix Lai on 4/10/16.
//  Copyright © 2016 Rix. All rights reserved.
//

#import "CommunicationProtocol.h"


@interface CommunicationProtocol()
@property NSString* mode;
@property (nonatomic) SpeedModel* model;
@property int active;
@property bool queueCheck;
@end

static NSString *const START_MODE = @"start";
static NSString *const STOP_MODE = @"stop";
static NSString *const INIT_MODE = @"init";
static NSString *const UNIT_MODE = @"unit";
static NSString *const MODE = @"mode";
static int const DEFAULT_TIMEOUT = 180;

@implementation CommunicationProtocol

- (id)init{
    self = [super init];
    self.active = DEFAULT_TIMEOUT;
    self.queueCheck = false;
    return self;
}

- (void)setModel:(SpeedModel*)model{
    self.model = model;
}

- (void)didReceiveMessage:(NSDictionary *)message{
    self.mode = [message objectForKey:MODE];
    self.active = DEFAULT_TIMEOUT;
    [self checkTimeout];
    [self updateMode];
}

- (void)updateMode{
    
    if([self.mode isEqualToString:START_MODE]){
        // App on Watch shows "start"
        // App on Phone should be killed
        [self.model stopUpdate];
        exit(1);
    }
    
    else if([self.mode isEqualToString:STOP_MODE]){
        // App on Watch shows "stop"
        // App on Phone should still send information to Watch
        // Do nothing
    }
    
    else if([self.mode isEqualToString:INIT_MODE]){
        // App on Watch is pressed "start" button
        // App on Phone should now begin to send information to Watch
        [self.model startUpdate];
    }
    
    else if([self.mode isEqualToString:UNIT_MODE]){
        // App on Watch is pressed "change unit" button
        // App on Phone should now change its unit
        [self.model flipUnit];
    }
    
}

- (void)checkTimeout{
    
    if(self.active <= 0){
        exit(1);
    }
    
    if(!self.queueCheck){
        self.queueCheck = true;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.queueCheck = false;
            [self checkTimeout];
        });
    }
}


@end
