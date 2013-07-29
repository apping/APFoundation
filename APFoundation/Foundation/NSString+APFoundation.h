//
//  NSString+StripHTML.h
//  Golfarenan
//
//  Created by Mathias Amnell on 2013-07-02.
//  Copyright (c) 2013 Apping AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (APFoundation)

/*
 Strips everything that looks like a HTML tag
 */
- (NSString *)ap_stringByStrippingHTML;


- (NSUInteger)ap_integerValueFromHex;

@end
