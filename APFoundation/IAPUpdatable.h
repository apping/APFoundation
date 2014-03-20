//
//  IAPUpdatable.h
//  APFoundation
//
//  Created by Lucas on 2014-03-20.
//  Copyright (c) 2014 Apping. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAPUpdatable <NSObject>

- (void)updateWithRemainingTime:(NSTimeInterval)remainingTime;

@end
