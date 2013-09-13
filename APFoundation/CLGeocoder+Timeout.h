//
//  CLGeocoder+Timeout.h
//  APFoundation
//
//  Created by Lucas on 2013-09-13.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLGeocoder (Timeout)

- (void)geocodeAddressDictionary:(NSDictionary *)addressDictionary withTimeout:(NSTimeInterval)timeout completionHandler:(CLGeocodeCompletionHandler)completionHandler;

@end
