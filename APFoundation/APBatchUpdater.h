//
//  APBatchUpdater.h
//  APFoundation
//
//  Created by Lucas on 2014-03-20.
//  Copyright (c) 2014 Apping. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APBatchUpdaterDelegate;

@protocol IAPUpdatable;

@interface APBatchUpdater : NSObject

@property (nonatomic, readonly, getter = isPaused) BOOL paused;

@property (nonatomic, weak) id<APBatchUpdaterDelegate> delegate;

- (void)addItem:(id<IAPUpdatable>)item withRemainingTime:(NSTimeInterval)remainingTime;
- (void)removeItem:(id<IAPUpdatable>)item;
- (BOOL)isUpdatingItem:(id<IAPUpdatable>)item;

- (BOOL)isUpdating;
- (void)pause;
- (void)resume;

- (void)reset;

@end

@protocol APBatchUpdaterDelegate <NSObject>

@optional
- (void)batchUpdater:(APBatchUpdater *)batchUpdater didFinishUpdatingItem:(id<IAPUpdatable>)item;

@end
