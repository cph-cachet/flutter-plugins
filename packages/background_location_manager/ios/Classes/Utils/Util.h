//
//  Util.h
//  background_locator
//
//  Created by Mehdi Sohrabi on 6/28/20.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Util : NSObject

+ (CLLocationAccuracy) getAccuracy:(long)key;
+ (NSDictionary<NSString*,NSNumber*>*) getLocationMap:(CLLocation *)location;

@end

NS_ASSUME_NONNULL_END
