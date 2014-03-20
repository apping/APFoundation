//
//  APUpdatableItemMetadata.h
//  APFoundation
//
//  Created by Lucas on 2014-03-20.
//  Copyright (c) 2014 Apping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+APTimeUnit.h"

typedef NS_ENUM(NSUInteger, APUpdatableItemStatus){
    APUpdatableItemStatusNoChange,
    APUpdatableItemStatusDirty,
    APUpdatableItemStatusExpired
};

#define APUpdatableItemStatusRequiresUpdate(MACRO_status) (MACRO_status != APUpdatableItemStatusNoChange)

@interface APUpdatableItemMetadata : NSObject

@property (nonatomic) NSTimeInterval remainingTime;
@property (nonatomic, readonly) APTimeUnit timeUnit;

- (APUpdatableItemStatus)statusWithRemainingtime:(NSTimeInterval)remainingTime;
- (void)setRemainingTime:(NSTimeInterval)remainingTime withCurrentTime:(CFAbsoluteTime)currentTime;

@end
