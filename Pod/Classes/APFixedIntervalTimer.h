//
//  APFixedIntervalTimer.h
//  APFoundation
//
//  Created by Lucas on 2014-03-20.
//  Copyright (c) 2014 Apping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+APTimeUnit.h"

@protocol APFixedIntervalTimerDelegate;

@interface APFixedIntervalTimer : NSObject

@property (atomic, weak) id<APFixedIntervalTimerDelegate> delegate;

- (id)initWithInterval:(NSTimeInterval)interval;

- (NSTimeInterval)interval;
- (void)setInterval:(NSTimeInterval)interval;

- (BOOL)isRunning;
- (void)start;
- (void)stop;

@end

@protocol APFixedIntervalTimerDelegate <NSObject>

@optional
- (void)fixedIntervalTime:(APFixedIntervalTimer *)timer reachedInterval:(NSTimeInterval)interval;

@end
