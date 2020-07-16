//
//  MethodCallHelper.h
//  background_locator
//
//  Created by Mehdi Sohrabi on 6/28/20.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@protocol MethodCallHelperDelegate <NSObject>
- (void) startLocatorService:(int64_t) callbackDispatcher;
- (void) setInitialized;
- (void)registerLocator:(int64_t)callback
           initCallback:(int64_t)initCallback
  initialDataDictionary:(NSDictionary *_Nullable)initialDataDictionary
        disposeCallback:(int64_t)disposeCallback
               settings:(NSDictionary *_Nonnull)settings;
- (void) removeLocator;
- (BOOL) isLocatorRegistered;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MethodCallHelper : NSObject

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result
                delegate:(id <MethodCallHelperDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
