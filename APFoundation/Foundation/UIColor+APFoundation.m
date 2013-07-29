//
//  UIColor+APFoundation.m
//  APFoundation
//
//  Created by Mathias Amnell on 2013-07-29.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import "UIColor+APFoundation.h"
#import "NSString+APFoundation.h"

@implementation UIColor (APFoundation)

+ (UIColor *)ap_colorWithHexString:(NSString *)hex
{
	return [UIColor ap_colorWithHexString:hex alpha:1.0];
}

+ (UIColor *)ap_colorWithHexString:(NSString *)hex alpha:(CGFloat)alpha
{
	if ([hex length]!=6 && [hex length]!=3)
	{
		return nil;
	}
	
	NSUInteger digits = [hex length]/3;
	CGFloat maxValue = (digits==1)?15.0:255.0;
	
	CGFloat red = [[hex substringWithRange:NSMakeRange(0, digits)] ap_integerValueFromHex]/maxValue;
	CGFloat green = [[hex substringWithRange:NSMakeRange(digits, digits)] ap_integerValueFromHex]/maxValue;
	CGFloat blue = [[hex substringWithRange:NSMakeRange(2*digits, digits)] ap_integerValueFromHex]/maxValue;
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
