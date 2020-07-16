//
//  MethodCallHelper.m
//  background_locator
//
//  Created by Mehdi Sohrabi on 6/28/20.
//

#import "MethodCallHelper.h"
#import "Globals.h"

@implementation MethodCallHelper

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result
                delegate:(id <MethodCallHelperDelegate>)delegate {
    NSDictionary *arguments = call.arguments;
    if ([kMethodPluginInitializeService isEqualToString:call.method]) {
        int64_t callbackDispatcher = [[arguments objectForKey:kArgCallbackDispatcher] longLongValue];
        [delegate startLocatorService:callbackDispatcher];
        result(@(YES));
    } else if ([kMethodServiceInitialized isEqualToString:call.method]) {
        [delegate setInitialized];
        result(nil);
    } else if ([kMethodPluginRegisterLocationUpdate isEqualToString:call.method]) {
        int64_t callbackHandle = [[arguments objectForKey:kArgCallback] longLongValue];
        int64_t initCallbackHandle = [[arguments objectForKey:kArgInitCallback] longLongValue];
        NSDictionary *initialDataDictionary = [arguments objectForKey:kArgInitDataCallback];
        int64_t disposeCallbackHandle = [[arguments objectForKey:kArgDisposeCallback] longLongValue];
        NSDictionary *settings = [arguments objectForKey:kArgSettings];

        [delegate registerLocator:callbackHandle initCallback:initCallbackHandle initialDataDictionary:initialDataDictionary disposeCallback:disposeCallbackHandle settings:settings];
        result(@(YES));
    } else if ([kMethodPluginUnRegisterLocationUpdate isEqualToString:call.method]) {
        [delegate removeLocator];
        result(@(YES));
    } else if ([kMethodPluginIsRegisteredLocationUpdate isEqualToString:call.method]) {
        BOOL val = [delegate isLocatorRegistered];
        result(@(val));
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
