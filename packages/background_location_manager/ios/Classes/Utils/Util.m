//
//  Util.m
//  background_locator
//
//  Created by Mehdi Sohrabi on 6/28/20.
//

#import "Util.h"
#import "GLobals.h"

@implementation Util

+ (CLLocationAccuracy) getAccuracy:(long)key {
    switch (key) {
        case 0:
            return kCLLocationAccuracyKilometer;
        case 1:
            return kCLLocationAccuracyHundredMeters;
        case 2:
            return kCLLocationAccuracyNearestTenMeters;
        case 3:
            return kCLLocationAccuracyBest;
        case 4:
            return kCLLocationAccuracyBestForNavigation;
        default:
            return kCLLocationAccuracyBestForNavigation;
    }
}

+ (NSDictionary<NSString *,NSNumber *> *)getLocationMap:(CLLocation *)location {
    NSTimeInterval timeInSeconds = [location.timestamp timeIntervalSince1970];
    return @{
            kArgLatitude: @(location.coordinate.latitude),
            kArgLongitude: @(location.coordinate.longitude),
            kArgAccuracy: @(location.horizontalAccuracy),
            kArgAltitude: @(location.altitude),
            kArgSpeed: @(location.speed),
            kArgSpeedAccuracy: @(0.0),
            kArgHeading: @(location.course),
            kArgTime: @(((double) timeInSeconds) * 1000.0)  // in milliseconds since the epoch
        };
}

@end
