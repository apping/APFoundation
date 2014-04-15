//
//  APPresentationTimer.m
//  APFoundation
//
//  Created by Lucas on 2013-09-11.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import "APPresentationTimer.h"

@interface APPresentationTimer ()

- (void)presentWithCompletionHandler:(APPresentationTimerCompletionHandler)completionHandler;
- (void)doneWithCompletionHandler:(APPresentationTimerCompletionHandler)completionHandler;

- (void)notifyCompletionHandler:(APPresentationTimerCompletionHandler)completionHandler;

@end

@implementation APPresentationTimer

- (void)time {
    [self timeWithCompletionHandler:NULL];
}

- (void)timeWithCompletionHandler:(APPresentationTimerCompletionHandler)completionHandler {
    NSAssert(_presentationTime == 0.0, @"Cannot time two presentations simultaneously!");
    
    if(_presentationDelay != 0.0)
        [self presentWithCompletionHandler:completionHandler];
    else{
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_presentationDelay * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self presentWithCompletionHandler:completionHandler];
        });
    }
}

- (void)presentWithCompletionHandler:(APPresentationTimerCompletionHandler)completionHandler {
    _presentationTime = CFAbsoluteTimeGetCurrent();
    
    [self notifyCompletionHandler:completionHandler];
}

- (void)endWithCompletionHandler:(APPresentationTimerCompletionHandler)completionHandler {
    NSAssert(completionHandler, @"completionHandler cannot be NULL!");
//    NSAssert(_presentationTime != 0.0, @"endWithCompletionHandler: cannot be called before the timer has started!");
    
    if(_minimumPresentationTime != 0.0){
        CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
        NSTimeInterval remainingTime = _minimumPresentationTime - (now - _presentationTime);
        if(remainingTime > 0.0){
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(remainingTime * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self doneWithCompletionHandler:completionHandler];
            });
            
            return;
        }
    }
    
    [self doneWithCompletionHandler:completionHandler];
}

- (void)invalidate {
    _presentationTime = 0.0;
}

- (void)doneWithCompletionHandler:(APPresentationTimerCompletionHandler)completionHandler {
    _presentationTime = 0.0;
    [self notifyCompletionHandler:completionHandler];
}

- (void)notifyCompletionHandler:(APPresentationTimerCompletionHandler)completionHandler {
    if(!completionHandler)
        return;
    
    if([NSThread isMainThread])
        completionHandler();
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler();
        });
    }
}

@end
