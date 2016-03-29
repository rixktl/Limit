//
//  LocationDataBase.m
//  Limit_beta
//
//  Created by Rix on 5/3/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import "OSMXMLParser.h"

static const double COOR_DIFF = 0.01;
// ~1.1km

@interface OSMXMLParser()


// Parser
@property NSXMLParser *Parser;

// Storage for XML parser
@property OSMData *tempData;


// This is temp for storing many nodes for one way
@property NSMutableArray *NodeInWayArray;

// Temporary id
@property NSString *NodeID;
@property NSString *WayID;

// Flag for XML parser
@property bool IsWay;
@property bool IsNode;
@property bool IsLock;


// Current Location Coordinate
@property double latitude;
// Current Location Coordinate
@property double longitude;

@end





@implementation OSMXMLParser


// Initalize NSXMLParser

- (id)init{
    self = [super init];
    self.IsLock = false;
    self.finalData = [[OSMData alloc] init];
    return self;
}



// Check network status
//No SystemConfiguration Framework on WatchOS2
- (bool)checkNetworkStatus{
   Reachability *reachability = [Reachability reachabilityForInternetConnection];
   NetworkStatus internetStatus = [reachability currentReachabilityStatus];
   
   if(internetStatus == NotReachable)
      return false;
   else
      return true;
}


// Request Limit by Location
- (void)requestLimit:(double)latitude withLongitude:(double)longitude{
   
   // No network available
   if(![self checkNetworkStatus]){
      [Utility debugLog:@"No Network Available" withBelong:@"Parser"];
      self.IsLock = false;
      return;
   }
   
   // Only work if not locked
   if(self.IsLock){
      [Utility debugLog:@"Request Locked" withBelong:@"Parser"];
      return;
   }
   
    // Clean old XML data
    self.tempData = [[OSMData alloc]init];
   
    // Invalid coordinate
    if(!latitude || !longitude){
       [Utility debugLog:@"Invalid Coordinate" withBelong:@"Parser"];
       return;
    }
   
    // Check if out of range
    if([self checkRange:latitude withLongitude:longitude withDifference:COOR_DIFF]){
       // Lock parser
       self.IsLock = true;
       
        // Update coordinate
        self.latitude = latitude;
        self.longitude = longitude;
        
        // Get path
        NSString *path = [self getPath:latitude withLongitude:longitude withDifference:COOR_DIFF];
       [Utility debugLog:path withBelong:@"Parser"];
        // it will call creqteRequest to initalize parser to parse
        [self createQueue:path];
    }
   
}



// Check range
- (bool)checkRange:(double)latitude withLongitude:(double)longitude withDifference:(double)different{
   
    // Within range
    if([Utility coordinateAccuracy:self.latitude-different] <= latitude &&
       latitude <= [Utility coordinateAccuracy:self.latitude+different] &&
       [Utility coordinateAccuracy:self.longitude-different] <= longitude &&
       longitude <= [Utility coordinateAccuracy:self.longitude+different]){
       
       [Utility debugLog:@"WithinRange" withBelong:@"Parser"];
        return false;
        
    // Out of range
    }else{
        return true;
    }
   
   return false;
}



// Get path according to coordinate
- (NSString *)getPath:(double)latitude withLongitude:(double)longitude withDifference:(double)different{
    // Make a chunk
    double max_latitude = [Utility coordinateAccuracy:latitude+different];
    double min_latitude = [Utility coordinateAccuracy:latitude-different];
    
    double max_longitude = [Utility coordinateAccuracy:longitude+different];
    double min_longitude = [Utility coordinateAccuracy:longitude-different];
    
    // Construct path for OpenStreetMap
    NSString *path = [NSString stringWithFormat:@"https://www.overpass-api.de/api/xapi?*[maxspeed=*][bbox=%.6f,%.6f,%.6f,%.6f]",min_longitude,min_latitude,max_longitude,max_latitude];
    
    return path;
}



// Create Queue for not freezing the screen when executing createRequest
- (void)createQueue:(NSString *)path{
    NSOperationQueue *queue = [NSOperationQueue new];
    
    NSInvocationOperation *operation= [[NSInvocationOperation alloc]
                                       
                                       initWithTarget: self
                                       
                                       selector: @selector(createRequest:)
                                       
                                       object: path];
    [queue addOperation:operation];
}



// Create request
- (void)createRequest:(NSString *)path{
    NSURL* Url = [NSURL URLWithString:path];
   
    self.Parser = [[NSXMLParser alloc] initWithContentsOfURL:Url];
    [self.Parser setDelegate:self];
    // Get the self from ViewController!!! Not done yet, Testing now
    //[Utility debugLog:@"Requesting" withBelong:@"Parser"];
    [self.Parser parse];
   
}





// Parser

// Beginning of element
-(void)parser:(NSXMLParser *)arser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    
    if([elementName isEqualToString:@"osm" ]){
    /*
     Start receiving OSM data
     */
       //[Utility debugLog:@"Parsing . . . " withBelong:@"Parser"];
        
    }else if([elementName isEqualToString:@"node"]){
        // Begin a node
        self.IsNode = true;
        // Save current Node ID
        self.NodeID = [attributeDict objectForKey:@"id"];
        

        // Just make the code shorter and readable
        NSString *lat = [attributeDict objectForKey:@"lat"];
        NSString *lon = [attributeDict objectForKey:@"lon"];
        
        // Add latitude and longitude to array after round up
        NSMutableArray *NodeRow = [[NSMutableArray alloc] init];
        [NodeRow addObject:[Utility coordinateString:lat]];
        [NodeRow addObject:[Utility coordinateString:lon]];
        
        // Add the array to dictionary
       [self.tempData.NodeDictionary setObject:NodeRow forKey:self.NodeID];
        
        
        
    }else if([elementName isEqualToString:@"way"]){
        // Begin a way
        self.IsWay = true;
        // Save current Way ID
        self.WayID = [attributeDict objectForKey:@"id"];
        self.NodeInWayArray = [[NSMutableArray alloc] init];
       
        
      // tag exists in both ndoe and way, it should has k attribute
    }else if([elementName isEqualToString:@"tag"] && [attributeDict objectForKey:@"k"] != nil){
       
        if(self.IsNode){
           // Inside node
           if([[attributeDict objectForKey:@"k"] isEqualToString:@"highway"]){
              // Check if type is allowed
              if([OSMData checkWayType:[attributeDict objectForKey:@"v"]]){
                 // Get the node array
                 NSMutableArray *NodeRow = [self.tempData.NodeDictionary objectForKey:self.NodeID];
                 // Add type to node array
                 [NodeRow addObject:[attributeDict objectForKey:@"v"]];
                 // Update Changes for node array
                 [self.tempData.NodeDictionary setObject:NodeRow forKey:self.NodeID];
              }
           }
           
           
        }else if (self.IsWay){
           // Inside way
           // Attribute type
           if([[attributeDict objectForKey:@"k"] isEqualToString:@"highway"]){
              // Check if type is allowed
              if([OSMData checkWayType:[attributeDict objectForKey:@"v"]]){
                 // Add the type to corresonding Way ID
                 [self.tempData.WayTypeDictionary setObject:[attributeDict objectForKey:@"v"] forKey:self.WayID];
              }
              
            // Speed limit
           }else if([[attributeDict objectForKey:@"k"] isEqualToString:@"maxspeed"]){
              // Add the speed limit to corresonding Way ID
              // filter to get the number(string)
              NSArray *filter = [[attributeDict objectForKey:@"v"] componentsSeparatedByString:@" "];
              // Add it to corresonding Way ID
              [self.tempData.WaySpeedDictionary setObject:[NSString stringWithFormat:@"%@",filter[0] ] forKey:self.WayID];
              
              
           }else if([[attributeDict objectForKey:@"k"] isEqualToString:@"name"]){
              [self.tempData.WayName setObject:[attributeDict objectForKey:@"v"] forKey:self.WayID];
              
           }
           
           
        }
       
       
       
    }else if([elementName isEqualToString:@"nd"]){
       // nd only exists inside way
       // Add multiple ref(node id) to temp (if this executed more than once)
       [self.NodeInWayArray addObject:[attributeDict objectForKey:@"ref"] ];
    }
    
}





// Found characters
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    // No characters useful in OSM
    // Leave it empty
}





// Ended Element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
   if([elementName isEqualToString:@"node"]){
      self.IsNode = false;
      
   }else if([elementName isEqualToString:@"way"]){
      self.IsWay = false;
      // Store the temp nodes id to Way Dictionary as array
      [self.tempData.WayDictionary setObject:self.NodeInWayArray forKey:self.WayID];
      
   }else if([elementName isEqualToString:@"osm"]){
      // Update Result
      self.finalData = self.tempData;
      // Unlock parser
      self.IsLock = false;
      //[Utility debugLog:@"Parse finished" withBelong:@"Parser"];
      /*
      [Utility debugLog:
                         [NSString stringWithFormat:@"TestElement:%@",
                          self.finalData.NodeDictionary[[ [self.finalData.NodeDictionary allKeys] objectAtIndex:0]]
                         ]
                        
             withBelong:@"Parser"];
       */
   }

}



- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
     // NSString *errorString = [NSString stringWithFormat:@"Error code %li", (long)[parseError code]];
     [Utility errorLog:[NSString stringWithFormat:@"%@", parseError] withBelong:@"Parser"];
}



@end

