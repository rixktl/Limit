//
//  GoogleGeo.m
//  Limit
//
//  Created by Rix on 5/6/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import "GoogleGeo.h"

@interface GoogleGeo ()

@property bool foundRoadName;
@property bool finished;
@property bool IsLock;
@property int counter;

@property NSXMLParser *Parser;

@property NSMutableArray *tempName;

@property double latitude;
@property double longitude;

@end


@implementation GoogleGeo

static const double COOR_DIFF = 0.00010; // ~10 meters

- (id)init {
    self = [super init];
    self.IsLock = false;

    return self;
}

// Check network status, No SystemConfiguration Framework on WatchOS2
- (bool)checkNetworkStatus {
    Reachability *reachability =
        [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];

    if (internetStatus == NotReachable)
        return false;
    else
        return true;
}

- (void)requestGeo:(double)latitude withLongitude:(double)longitude {

    // No network available
    if (![self checkNetworkStatus]) {
        [Utility debugLog:@"No Network Available" withBelong:@"GoogleGeo"];
        self.IsLock = false;
        return;
    }

    // Only work if not locked
    if (self.IsLock) {
        [Utility debugLog:@"Locked" withBelong:@"GoogleGeo"];
        return;
    }

    // Clean old data
    self.tempName = [[NSMutableArray alloc] init];
    self.counter = 0;

    // Invalid coordinate
    if (!latitude || !longitude) {
        [Utility debugLog:@"Invalid Coordinate" withBelong:@"GoogleGeo"];
        return;
    }

    // Check if out of range
    if ([self checkRange:latitude
             withLongitude:longitude
            withDifference:COOR_DIFF]) {
        // Lock parser
        self.IsLock = true;

        // Update coordinate
        self.latitude = latitude;
        self.longitude = longitude;

        NSString *path = [self getPath:latitude withLongitude:longitude];
        [Utility debugLog:path withBelong:@"GoogleGeo"];

        [self createQueue:path]; // it will call createRequest
    }
}

// Check range
- (bool)checkRange:(double)latitude
     withLongitude:(double)longitude
    withDifference:(double)different {

    // Within range
    if ([Utility coordinateAccuracy:self.latitude - different] <= latitude &&
        latitude <= [Utility coordinateAccuracy:self.latitude + different] &&
        [Utility coordinateAccuracy:self.longitude - different] <= longitude &&
        longitude <= [Utility coordinateAccuracy:self.longitude + different]) {

        [Utility debugLog:@"WithinRange" withBelong:@"GoogleGeo"];
        return false;

        // Out of range
    } else {
        return true;
    }

    return false;
}

- (NSString *)getPath:(double)latitude withLongitude:(double)longitude {
    // HTTPS
    return [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/"
                                      @"geocode/"
                                      @"xml?latlng=%.20f,%.20f&sensor=true",
                                      latitude, longitude];
}

// Create Queue for not freezing the screen when executing createRequest
- (void)createQueue:(NSString *)path {
    NSOperationQueue *queue = [NSOperationQueue new];

    NSInvocationOperation *operation = [[NSInvocationOperation alloc]

        initWithTarget:self

              selector:@selector(createRequest:)

                object:path];
    [queue addOperation:operation];
}

// Create request
- (void)createRequest:(NSString *)path {

    NSURL *Url = [NSURL URLWithString:path];

    self.Parser = [[NSXMLParser alloc] initWithContentsOfURL:Url];
    [self.Parser setDelegate:self];
    [self.Parser parse];

    /*
    NSString *u = [NSString stringWithFormat:@"%@",path];
    NSURLRequest* chRequest = [NSURLRequest requestWithURL:[NSURL
    URLWithString:u] cachePolicy: NSURLRequestReloadIgnoringCacheData
    timeoutInterval:10];
    NSError* theError;
    NSData* response = [NSURLConnection sendSynchronousRequest:chRequest
    returningResponse:nil error:&theError];
    self.Parser = [[NSXMLParser alloc] initWithData:response];
    [self.Parser setDelegate:self];
    [self.Parser parse];
     */
}

// Parser

// Beginning of element
- (void)parser:(NSXMLParser *)arser
    didStartElement:(NSString *)elementName
       namespaceURI:(NSString *)namespaceURI
      qualifiedName:(NSString *)qName
         attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"long_name"]) {
        self.counter++;
        self.foundRoadName = true;
    }
}

// Found characters
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (self.foundRoadName && self.counter <= 2) {
        [self.tempName addObject:string];
        [Utility debugLog:[NSString stringWithFormat:@"RoadName:%@", string]
               withBelong:@"GoogleGeo"];
        self.foundRoadName = false;
    }
}

// Ended Element
- (void)parser:(NSXMLParser *)parser
    didEndElement:(NSString *)elementName
     namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName {
    // Last element
    if ([elementName isEqual:@"GeocodeResponse"]) {
        // Unlock when everything is done
        self.IsLock = false;
        self.foundRoadName = false;
        self.roadName = [self.tempName copy];
        //[self.Parser abortParsing];
    }
}

@end