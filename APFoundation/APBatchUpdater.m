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
#import "NSDate+APTimeUnit.h"
#import <objc/runtime.h>

static const char APUpdatableItemMetadataKey;

@interface APBatchUpdater ()

- (APUpdatableItemMetadata *)addItem:(id<IAPUpdatable>)item;
- (void)proposeUpdateStartForItem:(id<IAPUpdatable>)item withMetadata:(APUpdatableItemMetadata *)metadata;

- (void)startUpdating;
- (void)restartUpdatingWithInterval:(APTimeUnit)interval;
- (void)stopUpdating;

- (BOOL)hasItems;
- (NSMutableSet *)items;

- (APUpdatableItemMetadata *)metadataForItem:(id<IAPUpdatable>)item;
- (void)attachMetadata:(APUpdatableItemMetadata *)metadata toItem:(id<IAPUpdatable>)item;

@end

@implementation APBatchUpdater {
    NSMutableSet *__items;
    
    APTimeUnit _updateInterval;
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
    
    APTimeUnit itemTimeUnit = [metadata timeUnit];
    if(itemTimeUnit != APTimeUnitNone && [NSDate isUnit:itemTimeUnit smallerThanUnit:_updateInterval])
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
    return NO;
}

- (void)startUpdating {
    if([self isUpdating])
        return;
}

- (void)restartUpdatingWithInterval:(APTimeUnit)interval {
    
}

- (void)stopUpdating {
    if(![self isUpdating])
        return;
}

- (BOOL)isPaused {
    return NO;
}

- (void)pause {
    
}

- (void)resume {
    
}

#pragma mark -

- (void)reset {
    
}

- (void)teardown {
    
}

@end
