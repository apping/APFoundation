//
//  UITableView+APLoading.m
//  APFoundation
//
//  Created by Lucas on 2013-10-08.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import "UITableView+APLoading.h"
#import "APDefaultTableViewLoadingView.h"
#import "APPresentationTimer.h"
#import <objc/runtime.h>

static const char UITableViewAPLoadingPresentationTimerKey;

@interface UITableView (APLoading_Private)

- (void)beginLoadWithHandler:(APTableViewLoadingHandler)handler minimumLoadingTime:(NSTimeInterval)minimumLoadingTime loadingView:(UIView<IAPTableViewLoadingView> *)loadingView;

- (APPresentationTimer *)presentationTimer;

@end

@implementation UITableView (APLoading)

- (void)loadWithHandler:(APTableViewLoadingHandler)handler {
    [self loadWithHandler:handler andMinimumLoadingTime:0.0];
}

- (void)loadWithHandler:(APTableViewLoadingHandler)handler andMinimumLoadingTime:(NSTimeInterval)minimumLoadingTime {
    [self loadWithHandler:handler minimumLoadingTime:minimumLoadingTime loadingView:[[APDefaultTableViewLoadingView alloc] init]];
}

- (void)loadWithHandler:(APTableViewLoadingHandler)handler minimumLoadingTime:(NSTimeInterval)minimumLoadingTime loadingView:(UIView<IAPTableViewLoadingView> *)loadingView {
    [self setScrollEnabled:NO];
    
    [loadingView setFrame:self.bounds];
    [loadingView stateChanged:APTableViewLoadingStateLoading];
    [loadingView setAlpha:0.0f];
    
    [self addSubview:loadingView];
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [loadingView setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [self beginLoadWithHandler:handler minimumLoadingTime:minimumLoadingTime loadingView:loadingView];
    }];
}

@end

@implementation UITableView (APLoading_Private)

- (void)beginLoadWithHandler:(APTableViewLoadingHandler)handler minimumLoadingTime:(NSTimeInterval)minimumLoadingTime loadingView:(UIView<IAPTableViewLoadingView> *)loadingView {
    APPresentationTimer *presentationTimer = [self presentationTimer];
    [presentationTimer setMinimumPresentationTime:minimumLoadingTime];
    [presentationTimer time];
    
    __weak UIView<IAPTableViewLoadingView> * _loadingView = loadingView;
    handler(APTableViewLoadingTypeInitial, ^(BOOL successful){
        [presentationTimer endWithCompletionHandler:^{
            if(successful){
                [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [loadingView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [loadingView stateChanged:APTableViewLoadingStateFinishedLoading];
                    [loadingView removeFromSuperview];
                    
                    [self setScrollEnabled:YES];
                }];
            }
            else{
                [loadingView setRetryCallback:^{
                    [_loadingView stateChanged:APTableViewLoadingStateLoading];
                    [self beginLoadWithHandler:handler minimumLoadingTime:minimumLoadingTime loadingView:_loadingView];
                }];
                
                [loadingView stateChanged:APTableViewLoadingStateError];
            }
        }];
    });
}

- (APPresentationTimer *)presentationTimer {
    APPresentationTimer *presentationTimer = nil;
    presentationTimer = objc_getAssociatedObject(self, &UITableViewAPLoadingPresentationTimerKey);
    if(!presentationTimer){
        presentationTimer = [[APPresentationTimer alloc] init];
        objc_setAssociatedObject(self, &UITableViewAPLoadingPresentationTimerKey, presentationTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return presentationTimer;
}

@end
