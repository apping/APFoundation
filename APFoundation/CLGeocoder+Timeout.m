//
//  CLGeocoder+Timeout.m
//  APFoundation
//
//  Created by Lucas on 2013-09-13.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import "CLGeocoder+Timeout.h"

@implementation CLGeocoder (Timeout)

- (void)geocodeAddressDictionary:(NSDictionary *)addressDictionary withTimeout:(NSTimeInterval)timeout completionHandler:(CLGeocodeCompletionHandler)completionHandler {
    if(timeout <= 0.0){
        [self geocodeAddressDictionary:addressDictionary completionHandler:completionHandler];
        return;
    }
    
    __block BOOL handled = NO;
    
    [self geocodeAddressDictionary:addressDictionary completionHandler:^(NSArray *placemarks, NSError *error) {
        if(handled)
            return;
        
        handled = YES;
        
        if(completionHandler)
            completionHandler(placemarks, error);
    }];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(handled)
            return;
        
        handled = YES;
        
        [self cancelGeocode];
        
        if(completionHandler)
            completionHandler(nil, [NSError errorWithDomain:kCLErrorDomain code:kCLErrorGeocodeFoundNoResult userInfo:nil]);
    });
}

@end
