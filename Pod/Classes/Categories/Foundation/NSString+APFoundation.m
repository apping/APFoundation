//
//  NSString+StripHTML.m
//  Golfarenan
//
//  Created by Mathias Amnell on 2013-07-02.
//  Copyright (c) 2013 Apping AB. All rights reserved.
//

#import "NSString+APFoundation.h"

@implementation NSString (APFoundation)

- (NSString *)ap_stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    
    return s;
}

- (NSUInteger)ap_integerValueFromHex
{
	int result = 0;
	sscanf([self UTF8String], "%x", &result);
	return result;
}

+ (BOOL)ap_stringHasCharacters:(NSString *)string {
    if(!string)
        return NO;
    
    if([string length] == 0)
        return NO;
    
    return [string rangeOfCharacterFromSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet]].location != NSNotFound;
}

+ (NSString *)ap_generateUUID {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
	CFStringRef uuid_string = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    NSAssert(uuid_string, @"uuid_string was not generated properly!");
	NSString *uuidString = [NSString stringWithString:CFBridgingRelease(uuid_string)];
	
	CFRelease(uuid);
    
    NSAssert(uuidString, @"Failed to convert uuid_string to NSString!");
    
    return uuidString;
}

@end
