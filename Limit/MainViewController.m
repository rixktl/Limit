//
//  ViewController.m
//  Limit_beta
//
//  Created by Rix on 5/3/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import "MainViewController.h"

// Convenient when using macro
#define GreenColor [UIColor colorWithRed:0.0/255.0 green:180.0/255.0 blue:81.0/255.0 alpha:1]
#define RedColor [UIColor colorWithRed:222.0/255.0 green:78.0/255.0 blue:90.0/255.0 alpha:1]
#define BlackColor [UIColor blackColor]

static const double AUDIO_OFFSET = 0.0;
//static const int TIMEOUT_WATCH = 30; // 30s

@interface MainViewController()

@property AVAudioPlayer *audioPlayer;
@property NSTimer *timer;
@property bool isPlaying;

@property bool DidLoad;

@property bool isBackground;

@property bool activeConnection;

@property int currentSpeed;
@property int limitSpeed;
@property NSString* unit;

@property (weak, nonatomic) IBOutlet UILabel *currentSpeedLabel;
@property (weak, nonatomic) IBOutlet UIButton *currentUnitLabel;

@property (weak, nonatomic) IBOutlet UIButton *SettingButton;

@property bool showingLoadingPage;

@property UIViewController *LoadingPageController;

@end


@implementation MainViewController

// Hide setting button when landscape
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
                               duration:(NSTimeInterval)duration{
    // Rotate the interface
    [super willRotateToInterfaceOrientation:orientation duration:duration];
    
    // Detect rotation type
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight)
        //Landscape
        self.SettingButton.hidden = true;
    
    else
        //Portrait
        self.SettingButton.hidden = false;
}


// White StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



// Go to setting page
- (IBAction)SettingButton:(id)sender {
    [model stopUpdate];
}



- (IBAction)UnitChange:(id)sender {
    [model flipUnit];
}


// Load sound by path
- (void)loadSound{
    NSString *path = [NSString stringWithFormat:@"%@/DoubleBeep.mp3",
                      [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    //ready for playing
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
}

// Request a audio play
- (void)requestAudioPlay{
    // Check if already playing
    if(self.isPlaying)
        return;
    
    // Lock it to prevent double playing
    self.isPlaying = true;
    
    // Never play sound when launched in background(by watch)
    if(self.isBackground == false){
        // Play it
        [self.audioPlayer play];
    }else{
        // Only when in background mode
        // Make notification
        [self notification:@"Test"];
    }
    
    // Timer for unlocking
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, ([self.audioPlayer duration] + AUDIO_OFFSET) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self finishAudioPlay];
    });
}



// Unlock audio player
- (void)finishAudioPlay{
    self.isPlaying = false;
}



- (void)notification:(NSString*)content{
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:0.1];
    localNotification.alertBody = content;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}



// Send message to watch
- (void)updateInfoForWatchOS:(int)limit
                      withSpeed:(int)speed
                       withUnit:(NSString*)unit{
    
    NSArray* objs = [[NSArray alloc] initWithObjects:
                     [[NSNumber alloc]initWithInt:limit],
                     [[NSNumber alloc ]initWithInt:speed],
                     unit,
                     nil];
    
    NSArray* keys = [[NSArray alloc] initWithObjects:@"limit", @"speed", @"unit", nil];
    NSDictionary* data = [[NSDictionary alloc] initWithObjects:objs forKeys:keys];
    
    if ([[WCSession defaultSession] isReachable]) {
        
        [[WCSession defaultSession] sendMessage:data
                                   replyHandler:^(NSDictionary *reply) {
                                       //handle reply from iPhone app here
                                   }
                                   errorHandler:^(NSError *error) {
                                       //catch any errors here
                                       NSLog(@"sending Error:%@", error);
        }];
        
        self.activeConnection = true;
        
        
        
    }else{
        
        // turn off manually on watch
        /*
        
        self.activeConnection = false;
        // Check connectivity a fixed time later
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, TIMEOUT_WATCH * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if(self.activeConnection == false){
                // Stop updating location
                [model stopUpdate];
                // Terminate app
                exit(1);
            }
        });
         
         */
    }
}



- (void)processMessage:(NSNotification *)notification{
    
    NSDictionary *message = notification.userInfo;
    
    NSLog(@"MSG:%@", message);
    
    NSString* mode = [message objectForKey:@"mode"];
    NSLog(@"%@", mode);
    
    if([mode isEqualToString:@"init"] && self.activeConnection == false){
        // Launch background mode
        UIApplication *application = [UIApplication sharedApplication];
    /*
        __block UIBackgroundTaskIdentifier identifier = UIBackgroundTaskInvalid;
        dispatch_block_t endBlock = ^ {
            if (identifier != UIBackgroundTaskInvalid) {
                [application endBackgroundTask:identifier];
            }
            identifier = UIBackgroundTaskInvalid;
        };
    
        identifier = [application beginBackgroundTaskWithExpirationHandler:endBlock];
    */
        self.activeConnection = true;
    
    }
    
    if([mode isEqualToString:@"start"]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            // Should start from stopped state
            [model stopUpdate];
            exit(1);
        });
    }else if([mode isEqualToString:@"stop"]){
        // Nothing to do
    }else if([mode isEqualToString:@"unit"]){
        [self UnitChange:nil];
    }
    
}



- (void)updateUnit:(NSString *)unit{
    [self.currentUnitLabel setTitle:unit forState:UIControlStateNormal];
    _unit = unit;
}

- (void)updateSpeed:(int)currentSpeed{
    _currentSpeed = currentSpeed;
    self.currentSpeedLabel.text = [NSString stringWithFormat:@"%d", _currentSpeed];
    [self updateView];
}


- (void)updateLimit:(int)limitSpeed{
    _limitSpeed = limitSpeed;
    [self updateView];
}



- (void)updateView{
    
    [self removeLoadingPage];
    
    [self updateInfoForWatchOS:_limitSpeed withSpeed:_currentSpeed withUnit:_unit];
    
    // Active speed
    if(_currentSpeed > 0 && _currentSpeed <= _limitSpeed)
        self.view.backgroundColor = GreenColor;
    
    else if(_currentSpeed > 0 && _currentSpeed > _limitSpeed){
        // Alert
        self.view.backgroundColor = RedColor;
        [self requestAudioPlay];
    
    }else
        self.view.backgroundColor = BlackColor;
}




-(void)showLoadingPage{
    if(!self.showingLoadingPage){
        self.showingLoadingPage = true;
        [[UIApplication sharedApplication].keyWindow addSubview:self.LoadingPageController.view];
    }
}


-(void)removeLoadingPage{
    if(self.showingLoadingPage){
        self.showingLoadingPage = false;
        [[UIApplication sharedApplication].keyWindow removeFromSuperview];
        [self.LoadingPageController.view removeFromSuperview];
    }
}


-(void)preLoading{
    
    [Utility saveBoolData:@"Launched" withValue:true];
    
    self.LoadingPageController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoadingPage"];
    
    // Check if running as background mode
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground){
        self.isBackground = true;
    }else{
        self.isBackground = false;
    }
    
    self.activeConnection = false;
    
    self.showingLoadingPage = false;
    
    [self showLoadingPage];
    
    self.DidLoad = true;
    
    [self loadSound];
    
    _limitSpeed = 0;
    _currentSpeed = 0;
    _unit = @"M P H";
    
    // Initalize
    model = [[SpeedModel alloc] init];
    
    // Set delegate for updating speed related info
    [model setDelegate:self];
    
    // Start updating
    [model startUpdate];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Disable for testing
    [self preLoading];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillDisappear:(BOOL)animated{
    [model stopUpdate];
    self.DidLoad = false;
}



// When returning from Setting view, viewDidLoad will not be triggered
// which will cause problem for unit, location and so on
// This will solve the problem
- (void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processMessage:) name:@"DID_RECEIVE_MESSAGE" object:nil];
    
    if(!self.DidLoad){
        // Restart all
        //[self viewDidLoad];
        NSLog(@"Restart");
    }
}

@end
