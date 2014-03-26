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
- (NSTimeInterval)updateIntervalForTimeUnit:(APTimeUnit)timeUnit;
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
    
    NSLog(@"Added item: %@ with remainingTime: %f", item, remainingTime);
    
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
    if([self isPaused]){
        NSLog(@"Was paused in propose update start!");
        return;
    }
    
    if(![self isUpdating]){
        NSLog(@"Wasn't updating in propose update start - starting update");
        [self startUpdating];
        return;
    }
    
    APTimeUnit itemTimeUnit = metadata.updateIntervalTimeUnit;
    if(itemTimeUnit != APTimeUnitNone && [NSDate isUnit:itemTimeUnit smallerThanUnit:_updateIntervalTimeUnit]){
        NSLog(@"itemTimeUnit: %@ is smaller than _updateIntervalTimeUnit: %@", [NSDate timeUnitString:itemTimeUnit], [NSDate timeUnitString:_updateIntervalTimeUnit]);
        [self restartUpdatingWithInterval:itemTimeUnit];
    }
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
    NSLog(@"Start updating!");
    
    if([self isUpdating]){
        NSLog(@"Was updating already - returning");
        return;
    }
    
    APTimeUnit timeUnit = [self requiredUpdateIntervalTimeUnit];
    NSLog(@"Requied uit: %@", [NSDate timeUnitString:timeUnit]);
    if(timeUnit == APTimeUnitNone)
        return;
    
    _updateIntervalTimeUnit = timeUnit;
    NSTimeInterval updateInterval = [self updateIntervalForTimeUnit:timeUnit];
    NSLog(@"Resulting in updateInterval: %f", updateInterval);
    _intervalTimer = [[APFixedIntervalTimer alloc] initWithInterval:updateInterval];
    [_intervalTimer setDelegate:self];
    [_intervalTimer start];
    
    NSLog(@"Started!");
}

- (void)restartUpdatingWithInterval:(APTimeUnit)interval {
    NSLog(@"Restarting updating with interval: %@", [NSDate timeUnitString:interval]);
    if(![self isUpdating]){
        NSLog(@"Was not updating when restarting - returning");
        return;
    }
    
    _updateIntervalTimeUnit = interval;
    NSTimeInterval newUpdateInterval = [self updateIntervalForTimeUnit:interval];
    NSLog(@"Resulting in new update interval: %f", newUpdateInterval);
    [_intervalTimer setInterval:newUpdateInterval];
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

- (NSTimeInterval)updateIntervalForTimeUnit:(APTimeUnit)timeUnit {
    if(timeUnit == APTimeUnitSecond)
        return timeUnit / 2.0;
    
    return timeUnit;
}

- (void)fixedIntervalTime:(APFixedIntervalTimer *)timer reachedInterval:(NSTimeInterval)interval {
    static int index = 0;
    
    if(index++ % 60 == 0)
        NSLog(@"Full update (%@, %f)", timer, interval);
    
    [self fullUpdate];
}

- (void)fullUpdate {
    [self update];
    
    APTimeUnit requiredUpdateIntervalTimeUnit = [self requiredUpdateIntervalTimeUnit];
    if(requiredUpdateIntervalTimeUnit == APTimeUnitNone){
        NSLog(@"Required update interval became none in fullUpdate!");
        [self stopUpdating];
        return;
    }
    
    if(requiredUpdateIntervalTimeUnit != _updateIntervalTimeUnit){
        NSLog(@"Required interval: %@ is not equal to _updateIntervalTimeUnit: %@ - in fullUpdate - restarting", [NSDate timeUnitString:requiredUpdateIntervalTimeUnit], [NSDate timeUnitString:_updateIntervalTimeUnit]);
        [self restartUpdatingWithInterval:requiredUpdateIntervalTimeUnit];
    }
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
    
    NSLog(@"Updating item: %@ - %f", item, remainingTime);
    
    [metadata setRemainingTime:remainingTime withCurrentTime:currentTime];
    [item updateWithRemainingTime:remainingTime];
    
    if(status == APUpdatableItemStatusExpired){
        NSLog(@"Item also expired!");
        
        if([self.delegate respondsToSelector:@selector(batchUpdater:didFinishUpdatingItem:)])
            [self.delegate batchUpdater:self didFinishUpdatingItem:item];
    }
}

- (void)stopUpdating {
    NSLog(@"Stop updating!");
    
    if(![self isUpdating]){
        NSLog(@"Was not updating when - returning");
        return;
    }
    
    NSLog(@"Stopping");
    [_intervalTimer setDelegate:nil];
    [_intervalTimer stop];
    _intervalTimer = nil;
    NSLog(@"Stopped");
}

- (void)pause {
    NSLog(@"pause");
    
    if([self isPaused]){
        NSLog(@"Was already paused - returning");
        return;
    }
    
    _paused = YES;
    
    NSLog(@"Calling stop updating");
    
    [self stopUpdating];
}

- (void)resume {
    NSLog(@"resume");
    
    if(![self isPaused]){
        NSLog(@"Was not paused - returning");
        return;
    }
    
    _paused = NO;
    
    NSLog(@"Performing manual update");
    
    [self update];
    
    NSLog(@"Calling start updating");
    
    [self startUpdating];
}

#pragma mark -

- (void)reset {
    NSLog(@"Reset");
    
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
