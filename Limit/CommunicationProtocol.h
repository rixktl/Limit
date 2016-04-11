//
//  CommunicationProtocol.h
//  Limit
//
//  Created by Rix Lai on 4/10/16.
//  Copyright © 2016 Rix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpeedModel.h"

@interface CommunicationProtocol : NSObject

- (void)setModel:(SpeedModel*)model;
- (void)didReceiveMessage:(NSDictionary *)message;

@end
