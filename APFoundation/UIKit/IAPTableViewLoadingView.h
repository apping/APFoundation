//
//  IAPTableViewLoadingView.h
//  APFoundation
//
//  Created by Lucas on 2013-10-08.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, APTableViewLoadingState) {
    APTableViewLoadingStateLoading,
    APTableViewLoadingStateFinishedLoading,
    APTableViewLoadingStateError
};

typedef void (^APTableViewLoadingViewRetryCallback)();

@protocol IAPTableViewLoadingView <NSObject>

@required
- (void)stateChanged:(APTableViewLoadingState)state;
- (void)setRetryCallback:(APTableViewLoadingViewRetryCallback)retryCallback;

@end
