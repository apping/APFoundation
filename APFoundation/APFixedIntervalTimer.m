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
    NSLog(@"Trying to set interval!");
    
    @synchronized(self){
        if(__interval == interval)
            return;
        
        __interval = interval;
        
        NSLog(@"Changing interval to: %f", interval);
        
        if(![self isRunning]){
            NSLog(@"Wasn't running - returning");
            return;
        }
        
        NSLog(@"Was running !!! signaling");
        
        dispatch_semaphore_signal([self timerSemaphore]);
    }
}

- (void)start {
    NSLog(@"Trying to start interval timer!");
    
    @synchronized(self){
        NSLog(@"Start interval timer");
        
        if([self isRunning]){
            NSLog(@"Was allready running interval timer!!! returning");
            return;
        }
        
        NSThread *timerThread = [self timerThread];
        if([timerThread isExecuting]){
            NSLog(@"Was executing timerThread");
            return;
        }
        
        NSLog(@"Starting timer thread");
        
        [timerThread start];
    }
}

- (void)stop {
    NSLog(@"Trying to stop interval timer!");
    
    @synchronized(self){
        NSLog(@"Stopping interval timer");
        
        if(![self isRunning])
            return;
        
        [self setRunning:NO];
    }
}

#pragma mark -

- (void)run {
    NSLog(@"Run");
    
    [self setRunning:YES];
    
    _lastIntervalTime = CFAbsoluteTimeGetCurrent();
    
    NSLog(@"Running");
    
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
    if(![self isRunning]){
        NSLog(@"Wasn't running when reachedInterval: %f", interval);
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        @synchronized(self){
            if([self.delegate respondsToSelector:@selector(fixedIntervalTime:reachedInterval:)])
                [self.delegate fixedIntervalTime:self reachedInterval:interval];
        }
    });
}

#pragma mark -

- (BOOL)isRunning {
    @synchronized(self){
        return __running;
    }
}

- (void)setRunning:(BOOL)running {
    NSLog(@"Trying to set running: %i", running);
    
    @synchronized(self){
        if(__running == running)
            return;
        
        NSLog(@"Setting running: %i", running);
        
        __running = running;
        
        if(!running){
            NSLog(@"Was running --- signaling");
            
            dispatch_semaphore_signal([self timerSemaphore]);
        }
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
