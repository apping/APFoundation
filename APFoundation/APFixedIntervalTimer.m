//
//  APFixedIntervalTimer.m
//  APFoundation
//
//  Created by Lucas on 2014-03-20.
//  Copyright (c) 2014 Apping. All rights reserved.
//

#import "APFixedIntervalTimer.h"

@interface APFixedIntervalTimer ()

- (void)setRunning:(BOOL)running;
- (NSThread *)timerThread;
- (dispatch_semaphore_t)timerSemaphore;

- (void)run;
- (void)reachedInterval:(NSTimeInterval)interval;

@end

@implementation APFixedIntervalTimer {
    NSTimeInterval __interval;
    CFAbsoluteTime _lastIntervalTime;
    
    BOOL __running;
    NSThread *__timerThread;
    dispatch_semaphore_t __timerSemaphore;
}

- (id)initWithInterval:(NSTimeInterval)interval {
    self = [super init];
    
    if(self){
        __interval = interval;
    }
    
    return self;
}

- (NSTimeInterval)interval {
    @synchronized(self){
        return __interval;
    }
}

- (void)setInterval:(NSTimeInterval)interval {
    @synchronized(self){
        if(__interval == interval)
            return;
        
        __interval = interval;
        
        if(![self isRunning])
            return;
        
        dispatch_semaphore_signal([self timerSemaphore]);
    }
}

- (void)start {
    @synchronized(self){
        if([self isRunning])
            return;
        
        NSThread *timerThread = [self timerThread];
        if([timerThread isExecuting])
            return;
        
        [timerThread start];
    }
}

- (void)stop {
    @synchronized(self){
        if(![self isRunning])
            return;
        
        [self setRunning:NO];
    }
}

#pragma mark -

- (void)run {
    [self setRunning:YES];
    
    _lastIntervalTime = CFAbsoluteTimeGetCurrent();
    
    do{
        NSTimeInterval interval = [self interval];
        CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
        NSTimeInterval elapsedTime = currentTime - _lastIntervalTime;
        NSTimeInterval waitDuration = interval - elapsedTime;
        if(dispatch_semaphore_wait([self timerSemaphore], dispatch_time(DISPATCH_TIME_NOW, (int64_t) (waitDuration * NSEC_PER_SEC))) == 0)
            goto end;
        
        [self reachedInterval:interval];
        
    end:
        _lastIntervalTime = CFAbsoluteTimeGetCurrent();
    }while([self isRunning]);
}

- (void)reachedInterval:(NSTimeInterval)interval {
    @synchronized(self){
        if(![self isRunning])
            return;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(fixedIntervalTime:reachedInterval:)])
                [self.delegate fixedIntervalTime:self reachedInterval:interval];
        });
    }
}

#pragma mark -

- (BOOL)isRunning {
    @synchronized(self){
        return __running;
    }
}

- (void)setRunning:(BOOL)running {
    @synchronized(self){
        if(__running == running)
            return;
        
        __running = running;
        
        if(!running)
            dispatch_semaphore_signal([self timerSemaphore]);
    }
}

- (NSThread *)timerThread {
    if(!__timerThread){
        __timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
        [__timerThread setName:@"APFixedIntervalTimer timer thread"];
    }
    
    return __timerThread;
}

- (dispatch_semaphore_t)timerSemaphore {
    @synchronized(self){
        if(!__timerSemaphore)
            __timerSemaphore = dispatch_semaphore_create(0L);
        
        return __timerSemaphore;
    }
}

@end
