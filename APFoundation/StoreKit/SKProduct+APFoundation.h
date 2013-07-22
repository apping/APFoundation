//
//  SKProduct+LocalizedPrice.h
//  Golfarenan
//
//  Created by Martin Öhman on 2013-07-05.
//  Copyright (c) 2013 Apping AB. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SKProduct (APFoundation)

/*
 Return the price as a localized string "$0.99" -> "7 kr"
 */
- (NSString *)ap_localizedPrice;

@end
