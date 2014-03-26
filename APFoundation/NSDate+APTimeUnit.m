//
//  NSDate+APTimeUnit.m
//  APFoundation
//
//  Created by Lucas on 2014-03-20.
//  Copyright (c) 2014 Apping. All rights reserved.
//

#import "NSDate+APTimeUnit.h"

@implementation NSDate (APTimeUnit)

+ (NSUInteger)unitsForTimeInterval:(NSTimeInterval)timeInterval inTimeUnit:(APTimeUnit)timeUnit {
    return [NSDate unitsForTimeInterval:timeInterval inTimeUnit:timeUnit round:[NSDate isUnit:timeUnit biggerThanUnit:APTimeUnitSecond]];
}

+ (NSUInteger)unitsForTimeInterval:(NSTimeInterval)timeInterval inTimeUnit:(APTimeUnit)timeUnit round:(BOOL)round {
    if(timeUnit == APTimeUnitNone)
        return 0;
    
    NSTimeInterval units = timeInterval / timeUnit;
    return round ? ceil(units) : units;
}

+ (NSUInteger)overflowinglUnitsForTimeInterval:(NSTimeInterval)timeInterval inTimeUnit:(APTimeUnit)timeUnit {
    NSUInteger units = [NSDate unitsForTimeInterval:timeInterval inTimeUnit:timeUnit round:NO];
    return [NSDate overflowinglUnitsForTimeInterval:timeInterval inTimeUnit:timeUnit units:units];
}

+ (NSUInteger)overflowinglUnitsForTimeInterval:(NSTimeInterval)timeInterval inTimeUnit:(APTimeUnit)timeUnit units:(NSUInteger)units {
    APTimeUnit previousUnit = [NSDate unitBelowUnit:timeUnit];
    if(previousUnit == APTimeUnitNone)
        return 0;
    
    NSTimeInterval unitTimeInterval = [NSDate timeIntervalForUnits:units inTimeUnit:timeUnit];
    NSTimeInterval overflowingTimeInterval = timeInterval - unitTimeInterval;
    return [NSDate unitsForTimeInterval:overflowingTimeInterval inTimeUnit:previousUnit];
}

+ (NSTimeInterval)timeIntervalForUnits:(NSUInteger)units inTimeUnit:(APTimeUnit)timeUnit {
    if(timeUnit == APTimeUnitNone)
        return 0;
    
    return units * timeUnit;
}

+ (APTimeUnit)unitAboveUnit:(APTimeUnit)unit {
    switch(unit){
        case APTimeUnitHour: return APTimeUnitDay;
        case APTimeUnitMinute: return APTimeUnitHour;
        case APTimeUnitSecond: return APTimeUnitMinute;
        default: return APTimeUnitNone;
    }
}

+ (APTimeUnit)unitBelowUnit:(APTimeUnit)unit {
    switch(unit){
        case APTimeUnitDay: return APTimeUnitHour;
        case APTimeUnitHour: return APTimeUnitMinute;
        case APTimeUnitMinute: return APTimeUnitSecond;
        default: return APTimeUnitNone;
    }
}

+ (BOOL)isUnit:(APTimeUnit)firstUnit biggerThanUnit:(APTimeUnit)secondUnit {
    return firstUnit > secondUnit;
}

+ (BOOL)isUnit:(APTimeUnit)firstUnit smallerThanUnit:(APTimeUnit)secondUnit {
    return firstUnit < secondUnit;
}

+ (APTimeUnit)biggestUnitForTimeInterval:(NSTimeInterval)timeInterval {
    if(timeInterval >= APTimeUnitDay)
        return APTimeUnitDay;
    if(timeInterval >= APTimeUnitHour)
        return APTimeUnitHour;
    if(timeInterval >= APTimeUnitMinute)
        return APTimeUnitMinute;
    if(timeInterval >= APTimeUnitSecond)
        return APTimeUnitSecond;
    
    return APTimeUnitNone;
}

+ (NSString *)timeUnitString:(APTimeUnit)timeUnit {
    switch(timeUnit){
        case APTimeUnitSecond: return @"Second";
        case APTimeUnitMinute: return @"Minute";
        case APTimeUnitHour: return @"Hour";
        case APTimeUnitDay: return @"Day";
        default: return nil;
    }
}

@end
