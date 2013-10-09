//
//  UITableView+APLoading.h
//  APFoundation
//
//  Created by Lucas on 2013-10-08.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, APTableViewLoadingType) {
    APTableViewLoadingTypeInitial,
    APTableViewLoadingTypeRetry
};

typedef void (^APTableViewLoadingCallback)(BOOL successful);
typedef void (^APTableViewLoadingHandler)(APTableViewLoadingType type, APTableViewLoadingCallback callback);

@protocol IAPTableViewLoadingView;

@interface UITableView (APLoading)

- (void)loadWithHandler:(APTableViewLoadingHandler)handler;
- (void)loadWithHandler:(APTableViewLoadingHandler)handler andMinimumLoadingTime:(NSTimeInterval)minimumLoadingTime;
- (void)loadWithHandler:(APTableViewLoadingHandler)handler minimumLoadingTime:(NSTimeInterval)minimumLoadingTime loadingView:(UIView<IAPTableViewLoadingView> *)loadingView;

@end
