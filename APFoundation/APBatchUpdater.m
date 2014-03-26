//
//  APBatchUpdater.m
//  APFoundation
//
//  Created by Lucas on 2014-03-20.
//  Copyright (c) 2014 Apping. All rights reserved.
//

#import "APBatchUpdater.h"
#import "IAPUpdatable.h"
#import "APUpdatableItemMetadata.h"
#import "APFixedIntervalTimer.h"
#import <UIKit/UIApplication.h>
#import <objc/runtime.h>

static const char APUpdatableItemMetadataKey;

@interface APBatchUpdater () <APFixedIntervalTimerDelegate>

- (APUpdatableItemMetadata *)addItem:(id<IAPUpdatable>)item;
- (void)proposeUpdateStartForItem:(id<IAPUpdatable>)item withMetadata:(APUpdatableItemMetadata *)metadata;

- (void)startUpdating;
- (void)restartUpdatingWithInterval:(APTimeUnit)interval;
- (APTimeUnit)requiredUpdateIntervalTimeUnit;
- (void)fullUpdate;
- (void)update;
- (void)updateItem:(id<IAPUpdatable>)item withCurrentTime:(CFAbsoluteTime)currentTime;
- (void)stopUpdating;

- (BOOL)hasItems;
- (NSMutableSet *)items;

- (APUpdatableItemMetadata *)metadataForItem:(id<IAPUpdatable>)item;
- (void)attachMetadata:(APUpdatableItemMetadata *)metadata toItem:(id<IAPUpdatable>)item;

- (void)applicationDidBecomeActive:(NSNotification *)notification;
- (void)applicationDidEnterBackground:(NSNotification *)notification;

@end

@implementation APBatchUpdater {
    NSMutableSet *__items;
    
    APTimeUnit _updateIntervalTimeUnit;
    APFixedIntervalTimer *_intervalTimer;
}

- (id)init {
    self = [super init];
    
    if(self){
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    
    return self;
}

- (void)addItem:(id<IAPUpdatable>)item withRemainingTime:(NSTimeInterval)remainingTime {
    if(!item)
        return;
    
    APUpdatableItemMetadata *metadata = [self addItem:item];
    
    [metadata setRemainingTime:remainingTime];
    [item updateWithRemainingTime:remainingTime];
    
    [self proposeUpdateStartForItem:item withMetadata:metadata];
}

- (APUpdatableItemMetadata *)addItem:(id<IAPUpdatable>)item {
    if([self isUpdatingItem:item])
        return [self metadataForItem:item];
    
    APUpdatableItemMetadata *metadata = [[APUpdatableItemMetadata alloc] init];
    [self attachMetadata:metadata toItem:item];
    NSMutableSet *items = [self items];
    [items addObject:item];
    return metadata;
}

- (void)proposeUpdateStartForItem:(id<IAPUpdatable>)item withMetadata:(APUpdatableItemMetadata *)metadata {
    if([self isPaused])
        return;
    
    if(![self isUpdating]){
        [self startUpdating];
        return;
    }
    
    APTimeUnit itemTimeUnit = metadata.updateIntervalTimeUnit;
    if(itemTimeUnit != APTimeUnitNone && [NSDate isUnit:itemTimeUnit smallerThanUnit:_updateIntervalTimeUnit])
        [self restartUpdatingWithInterval:itemTimeUnit];
}

- (void)removeItem:(id<IAPUpdatable>)item {
    if(![self isUpdatingItem:item])
        return;
    
    NSMutableSet *items = [self items];
    [items removeObject:item];
    
    if(![self hasItems] && [self isUpdating])
        [self stopUpdating];
}

- (BOOL)isUpdatingItem:(id<IAPUpdatable>)item {
    return item != nil && [[self items] containsObject:item];
}

- (BOOL)hasItems {
    return [[self items] count] > 0;
}

- (NSMutableSet *)items {
    if(!__items)
        __items = [[NSMutableSet alloc] initWithCapacity:16];
    
    return __items;
}

#pragma mark -

- (APUpdatableItemMetadata *)metadataForItem:(id<IAPUpdatable>)item {
    return objc_getAssociatedObject(item, &APUpdatableItemMetadataKey);
}

- (void)attachMetadata:(APUpdatableItemMetadata *)metadata toItem:(id<IAPUpdatable>)item {
    objc_setAssociatedObject(item, &APUpdatableItemMetadataKey, metadata, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (BOOL)isUpdating {
    return _intervalTimer != nil;
}

- (void)startUpdating {
    if([self isUpdating])
        return;
    
    APTimeUnit interval = [self requiredUpdateIntervalTimeUnit];
    if(interval == APTimeUnitNone)
        return;
    
    _updateIntervalTimeUnit = interval;
    _intervalTimer = [[APFixedIntervalTimer alloc] initWithInterval:interval];
    [_intervalTimer setDelegate:self];
    [_intervalTimer start];
}

- (void)restartUpdatingWithInterval:(APTimeUnit)interval {
    if(![self isUpdating])
        return;
    
    _updateIntervalTimeUnit = interval;
    [_intervalTimer setInterval:interval];
}

- (APTimeUnit)requiredUpdateIntervalTimeUnit {
    APTimeUnit interval = APTimeUnitNone;
    for(id<IAPUpdatable> item in [self items]){
        APUpdatableItemMetadata *metadata = [self metadataForItem:item];
        APTimeUnit itemTimeUnit = metadata.updateIntervalTimeUnit;
        if(itemTimeUnit == APTimeUnitNone)
            continue;
        
        if(interval == APTimeUnitNone){
            interval = itemTimeUnit;
            continue;
        }
        
        if([NSDate isUnit:itemTimeUnit smallerThanUnit:interval])
            interval = itemTimeUnit;
    }
    
    return interval;
}

- (void)fixedIntervalTime:(APFixedIntervalTimer *)timer reachedInterval:(NSTimeInterval)interval {
    [self fullUpdate];
}

- (void)fullUpdate {
    [self update];
    
    APTimeUnit requiredUpdateIntervalTimeUnit = [self requiredUpdateIntervalTimeUnit];
    if(requiredUpdateIntervalTimeUnit == APTimeUnitNone){
        [self stopUpdating];
        return;
    }
    
    if(requiredUpdateIntervalTimeUnit != _updateIntervalTimeUnit)
        [self restartUpdatingWithInterval:requiredUpdateIntervalTimeUnit];
}

- (void)update {
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    for(id<IAPUpdatable> item in [self items]){
        [self updateItem:item withCurrentTime:currentTime];
    }
}

- (void)updateItem:(id<IAPUpdatable>)item withCurrentTime:(CFAbsoluteTime)currentTime {
    APUpdatableItemMetadata *metadata = [self metadataForItem:item];
    if(![metadata isUpdatable])
        return;
    
    NSTimeInterval elapsedTime = currentTime - metadata.lastUpdateTime;
    NSTimeInterval remainingTime = metadata.remainingTime - elapsedTime;
    APUpdatableItemStatus status = [metadata statusWithRemainingTime:remainingTime];
    if(!APUpdatableItemStatusRequiresUpdate(status))
        return;
    
    [metadata setRemainingTime:remainingTime withCurrentTime:currentTime];
    [item updateWithRemainingTime:remainingTime];
    
    if(status == APUpdatableItemStatusExpired){
        if([self.delegate respondsToSelector:@selector(batchUpdater:didFinishUpdatingItem:)])
            [self.delegate batchUpdater:self didFinishUpdatingItem:item];
    }
}

- (void)stopUpdating {
    if(![self isUpdating])
        return;
    
    [_intervalTimer setDelegate:nil];
    [_intervalTimer stop];
    _intervalTimer = nil;
}

- (void)pause {
    if([self isPaused])
        return;
    
    _paused = YES;
    
    [self stopUpdating];
}

- (void)resume {
    if(![self isPaused])
        return;
    
    _paused = NO;
    
    [self update];
    
    [self startUpdating];
}

#pragma mark -

- (void)reset {
    [self stopUpdating];
    
    NSMutableSet *items = [self items];
    [items removeAllObjects];
}

#pragma mark -

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self resume];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self pause];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
