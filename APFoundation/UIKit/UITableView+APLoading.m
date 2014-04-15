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

- (BOOL)hasContent;

- (void)beginLoadWithHandler:(APTableViewLoadingHandler)handler type:(APTableViewLoadingType)type minimumLoadingTime:(NSTimeInterval)minimumLoadingTime loadingView:(UIView<IAPTableViewLoadingView> *)loadingView completionHandler:(APTableViewLoadingCompletionHandler)completionHandler;

- (APPresentationTimer *)presentationTimer;

@end

@implementation UITableView (APLoading)

- (void)loadWithHandler:(APTableViewLoadingHandler)handler {
    [self loadWithHandler:handler andCompletionHandler:NULL];
}

- (void)loadWithHandler:(APTableViewLoadingHandler)handler andCompletionHandler:(APTableViewLoadingCompletionHandler)completionHandler {
    [self loadWithHandler:handler minimumLoadingTime:0.0 completionHandler:completionHandler];
}

- (void)loadWithHandler:(APTableViewLoadingHandler)handler minimumLoadingTime:(NSTimeInterval)minimumLoadingTime completionHandler:(APTableViewLoadingCompletionHandler)completionHandler {
    [self loadWithHandler:handler minimumLoadingTime:minimumLoadingTime loadingView:[[APDefaultTableViewLoadingView alloc] init] completionHandler:completionHandler];
}

- (void)loadWithHandler:(APTableViewLoadingHandler)handler minimumLoadingTime:(NSTimeInterval)minimumLoadingTime loadingView:(UIView<IAPTableViewLoadingView> *)loadingView completionHandler:(APTableViewLoadingCompletionHandler)completionHandler {
    [self setScrollEnabled:NO];
    
    [loadingView setFrame:self.bounds];
    [loadingView stateChanged:APTableViewLoadingStateLoading];
    [loadingView.layer setZPosition:CGFLOAT_MAX];
    
    BOOL animate = [self hasContent];
    [loadingView setAlpha:animate ? 0.0f : 1.0f];
    
    [self addSubview:loadingView];
    
    if(animate){
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [loadingView setAlpha:1.0f];
        } completion:^(BOOL finished) {
            [self beginLoadWithHandler:handler type:APTableViewLoadingTypeInitial minimumLoadingTime:minimumLoadingTime loadingView:loadingView completionHandler:completionHandler];
        }];
    }
    else
        [self beginLoadWithHandler:handler type:APTableViewLoadingTypeInitial minimumLoadingTime:minimumLoadingTime loadingView:loadingView completionHandler:completionHandler];
}

@end

@implementation UITableView (APLoading_Private)

- (BOOL)hasContent {
    return [self.visibleCells count] > 0;
}

- (void)beginLoadWithHandler:(APTableViewLoadingHandler)handler type:(APTableViewLoadingType)type minimumLoadingTime:(NSTimeInterval)minimumLoadingTime loadingView:(UIView<IAPTableViewLoadingView> *)loadingView completionHandler:(APTableViewLoadingCompletionHandler)completionHandler {
    APPresentationTimer *presentationTimer = [self presentationTimer];
    [presentationTimer invalidate];
    [presentationTimer setMinimumPresentationTime:minimumLoadingTime];
    [presentationTimer time];
    
    __weak UIView<IAPTableViewLoadingView> * _loadingView = loadingView;
    handler(type, ^(BOOL successful){
        [presentationTimer endWithCompletionHandler:^{
            if(successful){
                if(completionHandler)
                    completionHandler(APTableViewLoadingCompletionTypeLoadCompleted);
                
                [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [loadingView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [loadingView stateChanged:APTableViewLoadingStateFinishedLoading];
                    [loadingView removeFromSuperview];
                    
                    [self setScrollEnabled:YES];
                    
                    if(completionHandler)
                        completionHandler(APTableViewLoadingCompletionTypeAnimationCompleted);
                }];
            }
            else{
                [loadingView setRetryCallback:^{
                    [_loadingView stateChanged:APTableViewLoadingStateLoading];
                    [self beginLoadWithHandler:handler type:APTableViewLoadingTypeRetry minimumLoadingTime:minimumLoadingTime loadingView:_loadingView completionHandler:completionHandler];
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
