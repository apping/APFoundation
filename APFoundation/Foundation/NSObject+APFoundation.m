//
//  NSObject+APFoundation.m
//  APFoundation
//
//  Created by Mathias Amnell on 2013-07-22.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import "NSObject+APFoundation.h"

@implementation NSObject (APFoundation)

- (void)ap_logTimeTakenToRunBlock:(void (^)(void)) block withPrefix:(NSString*) prefixString {
    
	double startTime = CFAbsoluteTimeGetCurrent();
	block();
	double endTime = CFAbsoluteTimeGetCurrent();
    
	unsigned int milliseconds = ((endTime-startTime) * 1000.0f); // convert from seconds to milliseconds
    
	NSLog(@"%@: %d ms", prefixString ? prefixString : @"Time taken", milliseconds);
}

@end
