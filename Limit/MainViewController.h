//
//  ViewController.h
//  Limit_beta
//
//  Created by Rix on 5/3/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

#import "Utility.h"
#import "SpeedModel.h"


@interface MainViewController : UIViewController <SpeedModelDelegate>{
    SpeedModel* model;
}

@end

