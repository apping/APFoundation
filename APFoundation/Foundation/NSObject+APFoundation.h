//
//  NSObject+APFoundation.h
//  APFoundation
//
//  Created by Mathias Amnell on 2013-07-22.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (APFoundation)

/*
 * NSLog the time taken to run a block of code.
 */
- (void)ap_logTimeTakenToRunBlock:(void (^)(void))block withPrefix:(NSString*)prefixString;

@end
