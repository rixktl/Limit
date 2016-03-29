//
//  RingController.m
//  Limit
//
//  Created by Rix on 5/26/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import "RingController.h"

static const double RingFPS = 60.0;

@interface RingController()

@property bool IsMoving;
@property int lock;
@property int frame;

@end


@implementation RingController


- (id)init{
    self = [super init];
    
    self.IsMoving = false;
    
    // Zero at the beginning
    self.frame = 0;
    
    return self;
}



// Convert offset by unit
- (int)addConvertedOffset:(int)offset withLimit:(int)limit{
    limit += offset;
    
    if([[Utility loadData:@"Unit"] isEqualToString:@"KPH"])
        return [Utility limit2kph:limit];
    else
        return limit;
    
}



- (void)randomRing:(WKInterfaceGroup *)bkgImage{
    int speed = rand()%100+1;
    int limit = rand()%150+1;
    
    [self controlRing:speed withLimit:limit withBkgImage:bkgImage];
}





- (void)controlRing:(int)speed withLimit:(int)limit withBkgImage:(WKInterfaceGroup *)bkgImage{
    
    int destinationFrame = (int)( (double)speed / (double)limit * 100);
        
    // When ovespeeding, destinationFrame may more than 100
    if(destinationFrame > 100)
        destinationFrame = 100;
    else if(destinationFrame < 0)
        destinationFrame = 0;
    
    [Utility debugLog:[NSString stringWithFormat:@"From:%d To:%d", self.frame, destinationFrame] withBelong:@"RingController"];
    
    if(destinationFrame == self.frame)
        return;
    // Move from current frame to the destination
    [self moveRing:self.frame withDestination:destinationFrame
     // Set Background Image (Groups)
      withBkgImage:bkgImage
     // it will get bool for direction
     withDirection:(self.frame < destinationFrame)];
    
}





- (void)moveRing:(int)origin withDestination:(int)destination withBkgImage:(WKInterfaceGroup *)bkgImage
   withDirection:(bool)direction{
    
    // Jump out if locked
    if(self.IsMoving)
        return;

    
    // Lock for preventing double animation
    self.IsMoving = true;
    // Set current frame
    self.frame = destination;
    // Default to be forward movment
    int dir, first, second, distance;
    
    // Reverse Movement
    if(!direction){
        // Reverse animation can be performed by negative duration
        dir = -1;

        // Coordinates (0-100) for both
        first = destination;
        // Second is same as the length
        second = origin - destination + 1; // Greater number
        // Length is same as second
        distance = second;
        
        [Utility debugLog:@"Inverse" withBelong:@"RingController"];
        
    }else{
        // Forward, positive duration
        dir = 1;
        
        first = origin;
        // Second is now same as the length
        second = destination - origin + 1;
        // Length is same as second
        distance = second;
        
        [Utility debugLog:@"Forward" withBelong:@"RingController"];
    }
    
    
    [Utility debugLog:[NSString stringWithFormat:@"1:%d, 2:%d", first, second] withBelong:@"RingController"];
    
    // Set Image
    [bkgImage setBackgroundImageNamed:@"single"];
    // Perform animation
    [bkgImage startAnimatingWithImagesInRange:NSMakeRange(first, second)
                                     duration:(distance/RingFPS)*dir
                                  repeatCount:1];
    
    // Unlock after animation finished according to delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, distance/RingFPS * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.IsMoving = false;
    });
}



@end
