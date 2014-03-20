//
//  APUpdatableItemMetadata.m
//  APFoundation
//
//  Created by Lucas on 2014-03-20.
//  Copyright (c) 2014 Apping. All rights reserved.
//

#import "APUpdatableItemMetadata.h"

@implementation APUpdatableItemMetadata

- (APUpdatableItemStatus)statusWithRemainingtime:(NSTimeInterval)remainingTime {
    return APUpdatableItemStatusNoChange;
}

- (void)setRemainingTime:(NSTimeInterval)remainingTime {
    [self setRemainingTime:remainingTime withCurrentTime:CFAbsoluteTimeGetCurrent()];
}

- (void)setRemainingTime:(NSTimeInterval)remainingTime withCurrentTime:(CFAbsoluteTime)currentTime {
    
}

@end
