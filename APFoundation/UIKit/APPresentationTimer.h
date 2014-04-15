//
//  APPresentationTimer.h
//  APFoundation
//
//  Created by Lucas on 2013-09-11.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^APPresentationTimerCompletionHandler)();

@interface APPresentationTimer : NSObject {
    CFAbsoluteTime _presentationTime;
}

@property (atomic) NSTimeInterval presentationDelay;
@property (atomic) NSTimeInterval minimumPresentationTime;

- (void)time;
- (void)timeWithCompletionHandler:(APPresentationTimerCompletionHandler)completionHandler;
- (void)endWithCompletionHandler:(APPresentationTimerCompletionHandler)completionHandler;

- (void)invalidate;

@end
