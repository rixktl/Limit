//
//  InterfaceController.m
//  Limit WatchOS2 Extension
//
//  Created by Rix on 6/24/15.
//  Copyright © 2015 Rix. All rights reserved.
//

#import "InterfaceController.h"

@interface InterfaceController() <WCSessionDelegate>

@property int limit;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *currentSpeedLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *unitLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *ringsGroup;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *screenButton;

@property int timeout;
@property bool activateTimer;
@property bool hapticLock;
@property int mode;
@end

@implementation InterfaceController

static NSString * const MPH = @"M P H";
static NSString * const KPH = @"K P H";

static const int HAPTIC_PERIOD = 3; // 3s between each haptic

static const int TIMEOUT_PERIOD = 10;

static const int START_MODE = 0;
static const int STOP_MODE = 1;
static const int NORMAL_MODE = 2;

- (id)init{
    self = [super init];
    
    // Initialize Ring object
    Ring = [[RingController alloc] init];
    
    _activateTimer = false;
    self.hapticLock = false;
    self.mode = START_MODE;
    // Empty labels
    self.currentSpeedLabel.text = @"ST";
    self.unitLabel.text = @"";
    // Replace background image
    //[self.ringsGroup setBackgroundImage:<#(nullable UIImage *)#>];
    
    return self;
}


- (IBAction)changeMode{
    
    if(self.mode == STOP_MODE){
        self.mode = START_MODE;
        [self startMode];
        
    }else if(self.mode == START_MODE){
        self.mode = NORMAL_MODE;
        // Async for communication
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startCommunicateToPhone];
        });
    }
}

- (void)startMode{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendMessage:@"mode" withData:@"start"];
        
        // Empty labels
        self.currentSpeedLabel.text = @"ST";
        self.unitLabel.text = @"";
        // Replace background image
        //[self.ringsGroup setBackgroundImage:<#(nullable UIImage *)#>];
    });
}


- (void)stopMode{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendMessage:@"mode" withData:@"stop"];
        
        // Empty labels
        self.currentSpeedLabel.text = @"SP";
        self.unitLabel.text = @"";
        // Replace background image
        //[self.ringsGroup setBackgroundImage:<#(nullable UIImage *)#>];

        
    });
}



- (void)addTimeout{
    _timeout += TIMEOUT_PERIOD;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, TIMEOUT_PERIOD * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self addTimeout];
    });
}



- (void)checkConnectionTimeout{
    if(_timeout > TIMEOUT_PERIOD * 2 && _mode != START_MODE){
        self.mode = START_MODE;
        // Empty labels
        self.currentSpeedLabel.text = @"ST";
        self.unitLabel.text = @"";
        // Replace background image
        //[self.ringsGroup setBackgroundImage:<#(nullable UIImage *)#>];
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, TIMEOUT_PERIOD * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self checkConnectionTimeout];
        });
    }
}



- (void)sendMessage:(NSString*)command withData:(NSString*)data{
    
    NSArray* objs = [[NSArray alloc] initWithObjects:data, nil];
    NSArray* keys = [[NSArray alloc] initWithObjects:command, nil];
    
    NSDictionary* dict = [[NSDictionary alloc] initWithObjects:objs forKeys:keys];
    
    if ([[WCSession defaultSession] isReachable]) {
    
    NSLog(@"Sending");
    
        [[WCSession defaultSession] sendMessage:dict
                                   replyHandler:^(NSDictionary *reply) {
                                       //handle reply from iPhone app here
                                       NSLog(@"%@", reply);
                                       NSLog(@"Sent!!!!!!!");
                                   }
                                   errorHandler:^(NSError *error) {
                                       //catch any errors here
                                       NSLog(@"Send Error:%@", error);
                                   }
         ];
        
    }else{
        NSLog(@"Unreachable");
    }
}


// Switch unit
- (IBAction)ChangeUnit {
    NSLog(@"Change unit");
    [self sendMessage:@"mode" withData:@"unit"];
}


- (void)startCommunicateToPhone{
    [self sendMessage:@"mode" withData:@"init"];
}


- (void)processMessage:(NSNotification *)notification{
    
    NSDictionary *message = notification.userInfo;
    
    NSLog(@"Received Signal from phone");

    if([message objectForKey:@"speed"] == nil ||
       [message objectForKey:@"limit"] == nil ||
       [message objectForKey:@"unit"] == nil){
        NSLog(@"Detected nil info");
        NSLog(@"MSG:%@", message);
        return;
    }
    
    if(self.mode == STOP_MODE && [[message objectForKey:@"speed"] intValue] > 0){
        self.mode = NORMAL_MODE;
    }
    
    
    if(self.mode != NORMAL_MODE)
        return;
    
    int speed = [[message objectForKey:@"speed"] intValue];
    int limit = [[message objectForKey:@"limit"] intValue];
    NSString* unit = [message objectForKey:@"unit"];
    
    if(speed == 0 && self.mode != STOP_MODE){
        self.mode = STOP_MODE;
        [self stopMode];
        
    }else if(self.mode == START_MODE){
        [self startMode];
        
    }else if(self.mode == NORMAL_MODE){
        self.currentSpeedLabel.text = [NSString stringWithFormat:@"%d", speed];
        [self setRing:speed withLimit:limit withUnit:unit];
    }
    
    
    _timeout = 0;
    if(!_activateTimer){
        _activateTimer = true;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, TIMEOUT_PERIOD * NSEC_PER_SEC),     dispatch_get_main_queue(), ^{
            [self addTimeout];
            [self checkConnectionTimeout];
        });
    
    }
}


- (void)setRing:(int)speed
      withLimit:(int)limit
       withUnit:(NSString*)unit{
    
    // Unit label
    self.unitLabel.text = unit;
    
    // Ring
    [Ring controlRing:speed withLimit:limit withBkgImage:self.ringsGroup];
    
    // Over speed
    if(speed > limit){
        if(!self.hapticLock){
            
            // Haptic engine
            
            self.hapticLock = true;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, HAPTIC_PERIOD * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                self.hapticLock = false;
            });
            

            NSLog(@"Haptic...");
            [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeNotification];
        }
    }
    
}


- (void)randomMovement{
    int speed = rand()%100+1;
    [self setRing:speed withLimit:70 withUnit:@"M P H"];
    self.currentSpeedLabel.text = [NSString stringWithFormat:@"%d", speed];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self randomMovement];
    });
}


- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
}


- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processMessage:) name:@"DID_RECEIVE_MESSAGE" object:nil];
 
    
    
    // Initialize ring background
    [self.ringsGroup setBackgroundImageNamed:@"single"];
    [self.ringsGroup startAnimatingWithImagesInRange:NSMakeRange(0, 1)
                                            duration:(1/50.0)
                                         repeatCount:1];
    // Default label
    self.unitLabel.text = @"";
    
}


- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


@end


