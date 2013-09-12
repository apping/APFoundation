//
//  APLocator.m
//  APFoundation
//
//  Created by Lucas on 2013-09-12.
//  Copyright (c) 2013 Apping. All rights reserved.
//

#import "APLocator.h"

@interface APLocator ()

- (void)timeout;
- (void)reset;

- (void)stopLocationUpdates;
- (void)stopReverseGeocoding;
- (void)returnResult:(CLPlacemark *)result;

@end

@implementation APLocator

- (BOOL)canFindLocation {
    switch([CLLocationManager authorizationStatus]){
        case kCLAuthorizationStatusAuthorized:
        case kCLAuthorizationStatusNotDetermined:
            return YES;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        default:
            return NO;
    }
}

- (BOOL)isFindingLocation {
    @synchronized(self){
        return _completionHandler != NULL;
    }
}

- (void)findLocationWithCompletionHandler:(APLocatorCompletionHandler)completionHandler {
    @synchronized(self){
        NSAssert(completionHandler, @"completionHandler cannot be nil!");
        
        if([self isFindingLocation]){
            NSAssert(NO, @"findLocationWithCompletionHandler: cannot be called twice before a result has been reached!");
            completionHandler(nil);
            return;
        }
        
        _completionHandler = completionHandler;
        
        if(![self canFindLocation]){
            [self returnResult:nil];
            return;
        }
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        _updatingLocations = YES;
        [_locationManager startUpdatingLocation];
        
        if(_timeoutThreshold > 0.0){
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_timeoutThreshold * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self timeout];
            });
        }
    }
}

- (void)timeout {
    @synchronized(self){
        [self reset];
    }
}

- (void)reset {
    [self stopLocationUpdates];
    [self stopReverseGeocoding];
    [self returnResult:nil];
}

- (void)stopLocationUpdates {
    if(!_updatingLocations)
        return;
    
    [_locationManager stopUpdatingLocation];
    _locationManager = nil;
    _updatingLocations = NO;
}

- (void)stopReverseGeocoding {
    if(!_reverseGeocoding)
        return;
    
    if(_geocoder.isGeocoding)
        [_geocoder cancelGeocode];
    
    _geocoder = nil;
    _reverseGeocoding = NO;
}

- (void)returnResult:(CLPlacemark *)result {
    if(!_completionHandler)
        return;
    
    _completionHandler(result);
    _completionHandler = NULL;
}

#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    @synchronized(self){
        CLLocation *location = [locations lastObject];
        
        [self stopLocationUpdates];
        
        _geocoder = [[CLGeocoder alloc] init];
        _reverseGeocoding = YES;
        [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            @synchronized(self){
                [self stopReverseGeocoding];
                
                if(error || !placemarks || [placemarks count] == 0){
                    [self returnResult:nil];
                    return;
                }
                
                CLPlacemark *location = [placemarks lastObject];
                [self returnResult:location];
            }
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    @synchronized(self){
        [self reset];
    }
}

@end
