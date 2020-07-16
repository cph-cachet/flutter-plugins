//
//  Constants.h
//  background_locator
//
//  Created by Mehdi Sohrabi on 6/3/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Globals : NSObject

FOUNDATION_EXPORT NSString *const kCallbackDispatcherKey;
FOUNDATION_EXPORT NSString *const kCallbackKey;
FOUNDATION_EXPORT NSString *const kInitCallbackKey;
FOUNDATION_EXPORT NSString *const kInitDataCallbackKey;
FOUNDATION_EXPORT NSString *const kDisposeCallbackKey;
FOUNDATION_EXPORT NSString *const kDistanceFilterKey;

FOUNDATION_EXPORT NSString *const kChannelId;
FOUNDATION_EXPORT NSString *const kBackgroundChannelId;

FOUNDATION_EXPORT NSString *const kMethodServiceInitialized;
FOUNDATION_EXPORT NSString *const kMethodPluginInitializeService;
FOUNDATION_EXPORT NSString *const kMethodPluginRegisterLocationUpdate;
FOUNDATION_EXPORT NSString *const kMethodPluginUnRegisterLocationUpdate;
FOUNDATION_EXPORT NSString *const kMethodPluginIsRegisteredLocationUpdate;

FOUNDATION_EXPORT NSString *const kArgLatitude;
FOUNDATION_EXPORT NSString *const kArgLongitude;
FOUNDATION_EXPORT NSString *const kArgAccuracy;
FOUNDATION_EXPORT NSString *const kArgAltitude;
FOUNDATION_EXPORT NSString *const kArgSpeed;
FOUNDATION_EXPORT NSString *const kArgSpeedAccuracy;
FOUNDATION_EXPORT NSString *const kArgHeading;
FOUNDATION_EXPORT NSString *const kArgTime;
FOUNDATION_EXPORT NSString *const kArgCallback;
FOUNDATION_EXPORT NSString *const kArgInitCallback;
FOUNDATION_EXPORT NSString *const kArgInitDataCallback;
FOUNDATION_EXPORT NSString *const kArgDisposeCallback;
FOUNDATION_EXPORT NSString *const kArgLocation;
FOUNDATION_EXPORT NSString *const kArgSettings;
FOUNDATION_EXPORT NSString *const kArgCallbackDispatcher;
FOUNDATION_EXPORT NSString *const kArgInterval;
FOUNDATION_EXPORT NSString *const kArgDistanceFilter;

FOUNDATION_EXPORT NSString *const kBCMSendLocation;
FOUNDATION_EXPORT NSString *const kBCMInit;
FOUNDATION_EXPORT NSString *const kBCMDispose;

@end

NS_ASSUME_NONNULL_END
