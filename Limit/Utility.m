//
//  Utility.m
//  Limit_beta
//
//  Created by Rix on 5/3/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import "Utility.h"

static const bool DEBUG_MODE = false;
static const bool ERROR_MODE = true;

static NSString * const GROUP_NAME = @"group.limitlabs.Limit";

@implementation Utility



// Convert units

// Convert meters/second to KPH
+ (double)source2KPH:(double)source{
    return (source*3.6);
}



// Convert meters/second to MPH
+ (double)source2MPH:(double)source{
    return (source*2.23694);
}


// Convert MPH to KPH
+ (int)limit2kph:(int)speed{
    return (int)(speed*1.60934);
}

// Speed is impossible to be negative
+ (double)getPossibleValue:(double)value{
    if(value < 0.0){
        return 0.0;
    }else{
        return value;
    }
}





// Setting accuracy for LocationManager, it could be so accurate
+ (double)coordinateAccuracy:(double)coordinate{
    return [[NSString stringWithFormat:@"%.10f",coordinate] doubleValue];
}



// Setting accuracy for LocationDataBase
// It is just 7 decimal place for both latitude and longitude
// It returns object for putting into array
// If it is less than 7 decimal place, just because of zero
// Doesn't affect accuracy
+ (NSNumber *)coordinateString:(NSString *)coordinate{
    return [NSNumber numberWithDouble:
             [  [NSString stringWithFormat:@"%.7f",[coordinate doubleValue] ]  doubleValue]];
}



// Get absolute differences between two number
+ (double)getDifference:(double)first withSecond:(double)second{
    return fabs( fabs(first) - fabs(second) );
}



// Check if roadname and wayname is similar
+ (bool)compareStringSimilarity:(NSString *)first withSecond:(NSString *)second{
    if(!(first || second))
        return false;
    NSString *firstConverted = [first stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *secondConverted = [second stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    if(([firstConverted containsString:secondConverted] ||
       [secondConverted containsString:firstConverted]) && firstConverted && secondConverted)
        // Similar string
        return true;
    else
        return false;
}





// Debug logging
+ (void)debugLog:(NSString *)log withBelong:(NSString *)belongs{
    if(DEBUG_MODE){
        NSLog(@"[DEBUG][%@] %@", belongs, log);
    }
}



// Error logging
+ (void)errorLog:(NSString *)log withBelong:(NSString *)belongs{
    if(ERROR_MODE){
        NSLog(@"[ERROR][%@] %@", belongs, log);
    }
}





// Object saver
+ (void)saveData:(NSString*)key withValue:(NSString*)value{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:GROUP_NAME];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}



// Object loader
+ (NSString*)loadData:(NSString*)key{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:GROUP_NAME];
    NSString *load = [defaults objectForKey:key];
    return load;
}



// bool saver
+ (void)saveBoolData:(NSString*)key withValue:(bool)value{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:GROUP_NAME];
    [defaults setBool:value forKey:key];
    [defaults synchronize];
}



// bool loader
+ (bool)loadBoolData:(NSString*)key{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:GROUP_NAME];
    return [defaults boolForKey:key];
}





@end
