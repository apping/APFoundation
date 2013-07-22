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

@end
