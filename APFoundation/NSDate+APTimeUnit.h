//
//  NSDate+APTimeUnit.h
//  APFoundation
//
//  Created by Lucas on 2014-03-20.
//  Copyright (c) 2014 Apping. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, APTimeUnit) {
    APTimeUnitNone = 0,
    APTimeUnitSecond = 1,
    APTimeUnitMinute = 60,
    APTimeUnitHour = 60 * 60,
    APTimeUnitDay = 60 * 60 * 24
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

@end
