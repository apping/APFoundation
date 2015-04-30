//
//  APUpdatableItemMetadata.m
//  APFoundation
//
//  Created by Lucas on 2014-03-20.
//  Copyright (c) 2014 Apping. All rights reserved.
//

#import "APUpdatableItemMetadata.h"

#define CRITICAL_MINUTES_THRESHOLD 10

#define RETURN_STATUS(MACRO_status) \
_lastKnownStatus = MACRO_status; \
return MACRO_status;

@implementation APUpdatableItemMetadata {
    APTimeUnit _timeUnit;
    NSUInteger _units;
    
    APUpdatableItemStatus _lastKnownStatus;
}

- (id)init {
    self = [super init];
    
    if(self){
        _lastKnownStatus = APUpdatableItemStatusNone;
    }
    
    return self;
}

- (BOOL)isUpdatable {
    return _timeUnit != APTimeUnitNone && _lastKnownStatus != APUpdatableItemStatusExpired;
}

- (APUpdatableItemStatus)statusWithRemainingTime:(NSTimeInterval)remainingTime {
    if(_timeUnit == APTimeUnitNone || remainingTime <= 0.0){
        RETURN_STATUS(APUpdatableItemStatusExpired)
    }
    
    NSUInteger currentUnits = [NSDate unitsForTimeInterval:remainingTime inTimeUnit:_timeUnit];
    if(_timeUnit == APTimeUnitSecond && currentUnits == 0){
        RETURN_STATUS(APUpdatableItemStatusExpired)
    }
    
    if(currentUnits != _units){
        RETURN_STATUS(APUpdatableItemStatusDirty)
    }
    
    RETURN_STATUS(APUpdatableItemStatusNoChange)
}

- (void)setRemainingTime:(NSTimeInterval)remainingTime {
    [self setRemainingTime:remainingTime withCurrentTime:CFAbsoluteTimeGetCurrent()];
}

- (void)setRemainingTime:(NSTimeInterval)remainingTime withCurrentTime:(CFAbsoluteTime)currentTime {
    if(_lastKnownStatus == APUpdatableItemStatusExpired && remainingTime > 0.0)
        _lastKnownStatus = APUpdatableItemStatusNone;
    
    _remainingTime = remainingTime;
    _lastUpdateTime = currentTime;
    
    _timeUnit = [NSDate biggestUnitForTimeInterval:remainingTime];
    if(_timeUnit == APTimeUnitNone){
        _updateIntervalTimeUnit = APTimeUnitNone;
        return;
    }
    
    if([NSDate isUnit:_timeUnit biggerThanUnit:APTimeUnitMinute])
        _timeUnit = [NSDate unitBelowUnit:_timeUnit];
    
    _units = [NSDate unitsForTimeInterval:remainingTime inTimeUnit:_timeUnit];
    
    if(_timeUnit == APTimeUnitMinute && _units <= CRITICAL_MINUTES_THRESHOLD){
        _timeUnit = APTimeUnitSecond;
        _units = [NSDate unitsForTimeInterval:remainingTime inTimeUnit:APTimeUnitSecond];
        _updateIntervalTimeUnit = APTimeUnitSecond;
    }
    else
        _updateIntervalTimeUnit = _timeUnit;
}

@end
