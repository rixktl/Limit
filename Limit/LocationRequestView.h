//
//  LocationServiceController.h
//  Limit
//
//  Created by Rix Lai on 12/25/15.
//  Copyright © 2015 Rix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationRequestView : UIViewController<CLLocationManagerDelegate>{
    id <CLLocationManagerDelegate> delegate;
}

@end
