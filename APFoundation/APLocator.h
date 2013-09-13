//
//  APLocator.h
//  APFoundation
//
//  Created by Lucas on 2013-09-12.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^APLocatorCompletionHandler)(CLPlacemark *location);

///Has a simple interface for retrieving one and only one location (the current location).
@interface APLocator : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *_locationManager;
    BOOL _updatingLocations;
    CLGeocoder *_geocoder;
    BOOL _reverseGeocoding;
    
    APLocatorCompletionHandler _completionHandler;
}

@property (nonatomic) NSTimeInterval timeoutThreshold;

- (BOOL)canFindLocation;
- (BOOL)isFindingLocation;
- (void)findLocationWithCompletionHandler:(APLocatorCompletionHandler)completionHandler;

@end
