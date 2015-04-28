//
//  NSTimer+APBlocks.m
//
//  Created by Mathias Amnell on 2011-11-18.
//  Copyright (c) 2011 Apping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (APFoundation)

/*
 * Block additions
 */
+ (instancetype)ap_timerWithTimeInterval:(NSTimeInterval)timeInterval block:(void (^)())block;
+ (instancetype)ap_timerRepeats:(BOOL)repeats withTimeInterval:(NSTimeInterval)timeInterval block:(void (^)())block;

+ (instancetype)ap_scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval block:(void (^)())block;
+ (instancetype)ap_scheduledTimerRepeats:(BOOL)repeats withTimeInterval:(NSTimeInterval)timeInterval block:(void (^)())block;


@end
