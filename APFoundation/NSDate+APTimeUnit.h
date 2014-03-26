//
//  NSDate+APTimeUnit.h
//  APFoundation
//
//  Created by Lucas on 2014-03-20.
//  Copyright (c) 2014 Apping. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSUInteger HoursPerDay = 24;
static const NSUInteger MinutesPerHour = 60;
static const NSUInteger SecondsPerMinute = 60;

typedef NS_ENUM(NSUInteger, APTimeUnit) {
    APTimeUnitNone = 0,
    APTimeUnitSecond = 1,
    APTimeUnitMinute = SecondsPerMinute,
    APTimeUnitHour = MinutesPerHour * SecondsPerMinute,
    APTimeUnitDay = HoursPerDay * MinutesPerHour * SecondsPerMinute
};

@interface NSDate (APTimeUnit)

+ (NSUInteger)unitsForTimeInterval:(NSTimeInterval)timeInterval inTimeUnit:(APTimeUnit)timeUnit;
+ (NSUInteger)unitsForTimeInterval:(NSTimeInterval)timeInterval inTimeUnit:(APTimeUnit)timeUnit round:(BOOL)round;
+ (NSUInteger)overflowinglUnitsForTimeInterval:(NSTimeInterval)timeInterval inTimeUnit:(APTimeUnit)timeUnit;
+ (NSUInteger)overflowinglUnitsForTimeInterval:(NSTimeInterval)timeInterval inTimeUnit:(APTimeUnit)timeUnit units:(NSUInteger)units;
+ (NSTimeInterval)timeIntervalForUnits:(NSUInteger)units inTimeUnit:(APTimeUnit)timeUnit;

+ (APTimeUnit)unitAboveUnit:(APTimeUnit)unit;
+ (APTimeUnit)unitBelowUnit:(APTimeUnit)unit;

+ (BOOL)isUnit:(APTimeUnit)firstUnit biggerThanUnit:(APTimeUnit)secondUnit;
+ (BOOL)isUnit:(APTimeUnit)firstUnit smallerThanUnit:(APTimeUnit)secondUnit;

+ (APTimeUnit)biggestUnitForTimeInterval:(NSTimeInterval)timeInterval;

+ (NSString *)timeUnitString:(APTimeUnit)timeUnit;

@end
