//
//  UIColor+APFoundation.h
//  APFoundation
//
//  Created by Mathias Amnell on 2013-07-29.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (APFoundation)

- (UIColor *)an_darken;
- (UIColor *)an_lighten;

+ (UIColor *)ap_colorWithHexString:(NSString *)hex;
+ (UIColor *)ap_colorWithHexString:(NSString *)hex alpha:(CGFloat)alpha;

@end
