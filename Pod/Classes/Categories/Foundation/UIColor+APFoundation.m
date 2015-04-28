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

- (UIColor *)an_lighten
{
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.2, 1.0)
                               green:MIN(g + 0.2, 1.0)
                                blue:MIN(b + 0.2, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)an_darken
{
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}

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
