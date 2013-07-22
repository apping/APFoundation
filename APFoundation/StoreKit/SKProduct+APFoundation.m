//
//  SKProduct+LocalizedPrice.m
//  Golfarenan
//
//  Created by Martin Öhman on 2013-07-05.
//  Copyright (c) 2013 Apping AB. All rights reserved.
//

#import "SKProduct+APFoundation.h"

@implementation SKProduct (APFoundation)

- (NSString *)ap_localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    
    return formattedString;
}

@end
