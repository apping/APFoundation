//
//  NSTimer+APBlocks.m
//
//  Created by Mathias Amnell on 2011-11-18.
//  Copyright (c) 2011 Apping. All rights reserved.
//

#import "NSTimer+APFoundation.h"

@implementation NSTimer (APFoundation)

#pragma mark -
#pragma mark Block additions

+ (void)ap_executeBlock:(NSTimer *)timer{
    if([timer userInfo]){
        void (^block)() = (void (^)())[timer userInfo];
        block();
    }
}

+ (instancetype)ap_timerWithTimeInterval:(NSTimeInterval)timeInterval block:(void (^)())block {
    return [self ap_timerRepeats:NO withTimeInterval:timeInterval block:block];
}

+ (instancetype)ap_timerRepeats:(BOOL)repeats withTimeInterval:(NSTimeInterval)timeInterval block:(void (^)())block {
    void (^_block)() = [block copy];
    id timer = [self timerWithTimeInterval:timeInterval
                                    target:self
                                  selector:@selector(ap_executeBlock:)
                                  userInfo:_block
                                   repeats:repeats];
    return timer;
}

+ (instancetype)ap_scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval block:(void (^)())block{
    return [self ap_scheduledTimerRepeats:NO withTimeInterval:timeInterval block:block];
}

+ (instancetype)ap_scheduledTimerRepeats:(BOOL)repeats withTimeInterval:(NSTimeInterval)timeInterval block:(void (^)())block {
    void (^_block)() = [block copy];
    id timer = [self scheduledTimerWithTimeInterval:timeInterval
                                             target:self
                                           selector:@selector(ap_executeBlock:)
                                           userInfo:_block
                                            repeats:repeats];
    return timer;
}


@end
