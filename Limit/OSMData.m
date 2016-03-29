//
//  OSMData.m
//  Limit_beta
//
//  Created by Rix on 5/19/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//
/*
 
*/

#import "OSMData.h"

static const int DefaultLimit = 70;

@implementation OSMData


// Initialize without parameters
- (id)init{
    self = [super init];
    self.NodeDictionary = [[NSMutableDictionary alloc] init];
    self.WayDictionary = [[NSMutableDictionary alloc] init];
    self.WayName = [[NSMutableDictionary alloc] init];
    self.WayTypeDictionary = [[NSMutableDictionary alloc] init];
    self.WaySpeedDictionary = [[NSMutableDictionary alloc] init];
    return self;
}



// Initialize with parameter
- (id)initWithArray:(NSArray *)array{
    self = [super init];
    
    if(self){
        
        if([array count] == 5){
            self.NodeDictionary = [array objectAtIndex:0];
            self.WayDictionary = [array objectAtIndex:1];
            self.WayName = [array objectAtIndex:2];
            self.WayTypeDictionary = [array objectAtIndex:3];
            self.WaySpeedDictionary = [array objectAtIndex:4];
        }
        
    }
    return self;
}





- (int)verifyLimit:(int)limit{
    if(limit <= 0){
        // No data
        [Utility debugLog:@"Using DefaultLimit(in OSMData.m)" withBelong:@"OSMData-verifyLimit"];
        return DefaultLimit;
    }else
        return limit;
    
}



// Check if the type is allowed
+ (bool)checkWayType:(NSString *)type{
    if([type isEqualToString: @"residential"] || [type isEqualToString: @"service"] ||
       [type isEqualToString: @"secondary"] || [type isEqualToString: @"tertiary"] ||
       [type isEqualToString: @"primary"] || [type isEqualToString: @"freeway"] ||
       [type isEqualToString: @"motorway"] || [type isEqualToString: @"trunk"]){
        return true;
    }else{
        return false;
    }
}



- (int)getLimitWithType:(NSString *)nodeID{
    
    NSString *type;
    
    if([[self.NodeDictionary objectForKey:nodeID] count] == 3){
        type = [[self.NodeDictionary objectForKey:nodeID] objectAtIndex:2];
        
        if([type  isEqual: @"residential"] || [type  isEqual: @"service"]){
            return 25;
        
        }else if([type  isEqual: @"secondary"] || [type  isEqual: @"tertiary"]){
            return 30;
        
        }else if([type  isEqual: @"primary"] || [type  isEqual: @"freeway"] ||
             [type  isEqual: @"motorway"] || [type  isEqual: @"trunk"]){
            return 60;
        
        }
    }
    
    // type not match or no type
    return 0;
}





// Match node id in way
- (NSString *)searchWayWithNode:(NSString *)node{
    
    for(id key in self.WayDictionary){
        
        for(id obj in  [self.WayDictionary objectForKey:key]){
            
            if(obj == node)
                // Return way ID
                return key;
        }
        
    }
    
    return nil;
}



// Search for Nearest Speed Limit
- (NSArray *)searchNodeWithLatitude:(double)lat withLongitude:(double)lon{
    
    // Initialize with larger number
    double searchedDifference = 1000;
    // Prevent from uninitialized
    NSString *searchedNodeID;
    double nodeLat, nodeLon, diff;
    
    // Loop through all nodes
    for(id key in self.NodeDictionary){
        if([[self.NodeDictionary objectForKey:key] count] == 2){
            
            nodeLat = [[[self.NodeDictionary objectForKey:key] objectAtIndex:0] doubleValue];
            nodeLon = [[[self.NodeDictionary objectForKey:key] objectAtIndex:1] doubleValue];
            diff = [Utility getDifference:nodeLat withSecond:lat];
            diff += [Utility getDifference:nodeLon withSecond:lon];
            
            // Get the nearest(less differences) coordinate
            if(diff < searchedDifference){
                searchedDifference = diff;
                searchedNodeID = key;
            }
        }
    }
    
    return [NSArray arrayWithObjects:searchedNodeID,
            [NSNumber numberWithDouble:searchedDifference],
            nil];
}





- (int)getLimit:(NSArray *)roadName withLatitude:(double)lat withLongitude:(double)lon{
    
    int limit = 0;
    
    NSString *wayName, *nodeID, *wayID;
    /*
     Maybe it is better to
     match wayName and roadName
     at the beginning
    */
    
    if(self.WayDictionary){
    
        for(id key in self.WayDictionary){
            if([self.WayName objectForKey:key] && !(roadName == nil || [roadName count] == 0)){
                
                if([Utility compareStringSimilarity:[self.WayName objectForKey:key]
                                         withSecond:[roadName objectAtIndex:0]]         ||
                   [Utility compareStringSimilarity:[self.WayName objectForKey:key]
                                         withSecond:[roadName objectAtIndex:1]]){
                       
                    wayName = [self.WayName objectForKey:key];
                       
                    if([self.WaySpeedDictionary objectForKey:key]){
                        //NSLog(@"%@", @"wayName-waySpeed");
                        // Jump out if found limit
                        return [self verifyLimit:[[self.WaySpeedDictionary objectForKey:key] intValue] ];
                    }
                       
                       
                }
            }
        }
        
        [Utility debugLog:[NSString stringWithFormat:@"WayName:%@", wayName] withBelong:@"GetLimit"];
    
    }
    
    
    
    // Has NodeDict
    if(self.NodeDictionary){
        NSArray *nodeInfo = [self searchNodeWithLatitude:lat withLongitude:lon];
        // NodeInfo is filled
        if([nodeInfo count] == 2){
            nodeID = [nodeInfo objectAtIndex:0];
            [Utility debugLog:[NSString stringWithFormat:@"Diff:%@", [nodeInfo objectAtIndex:1]] withBelong:@"GetLimit"];
        }
    }
    
    
    
    // Has WayDict and nodeID
    if(self.WayDictionary && nodeID){
        
        wayID = [self searchWayWithNode:nodeID];
        
        
        // Found wayID
        if(wayID){
            // Found limit
            if([self.WaySpeedDictionary objectForKey:wayID]){
                //NSLog(@"%@", @"WaySpeed-wayID");
                // Return limit from WaySpeed (int)
                return [self verifyLimit:[[self.WaySpeedDictionary objectForKey:wayID] intValue]];
            }
            
            
            //NSLog(@"%@", @"type-wayID");
            
            // Get limit by wayID
            limit = [self getLimitWithType:wayID];
            return [self verifyLimit:limit];
        }
        
    }
    
    //NSLog(@"%@", @"type-nodeID");
    
    // Get limit by nodeID
    limit = [self getLimitWithType:nodeID];
    return [self verifyLimit:limit];

    
    
}



@end
