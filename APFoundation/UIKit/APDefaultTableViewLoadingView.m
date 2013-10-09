//
//  APDefaultTableViewLoadingView.m
//  APFoundation
//
//  Created by Lucas on 2013-10-08.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import "APDefaultTableViewLoadingView.h"

@implementation APDefaultTableViewLoadingView

- (void)stateChanged:(APTableViewLoadingState)state {
    switch(state){
        case APTableViewLoadingStateLoading:
            break;
        case APTableViewLoadingStateFinishedLoading:
            break;
        case APTableViewLoadingStateError:
            break;
    }
}

- (void)setRetryCallback:(APTableViewLoadingViewRetryCallback)retryCallback {
    
}

@end
