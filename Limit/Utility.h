//
//  Utility.h
//  Limit_beta
//
//  Created by Rix on 5/3/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface Utility : NSObject

+ (double)source2KPH:(double)source;

+ (double)source2MPH:(double)source;

+ (int)limit2kph:(int)speed;

+ (double)getPossibleValue:(double)value;


+ (double)coordinateAccuracy:(double)coordinate;

+ (NSString *)coordinateString:(NSString *)coordinate;


+ (double)getDifference:(double)first withSecond:(double)second;

+ (bool)compareStringSimilarity:(NSString *)first withSecond:(NSString *)second;


+ (void)debugLog:(NSString *)log withBelong:(NSString *)belongs;

+ (void)errorLog:(NSString *)log withBelong:(NSString *)belongs;


+ (void)saveData:(NSString*)key withValue:(NSString*)value;

+ (NSString*)loadData:(NSString*)key;


+ (void)saveBoolData:(NSString*)key withValue:(bool)value;

+ (bool)loadBoolData:(NSString*)key;


@end
