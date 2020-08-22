#import "AppUsagePlugin.h"
#if __has_include(<app_usage/app_usage-Swift.h>)
#import <app_usage/app_usage-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "app_usage-Swift.h"
#endif

@implementation AppUsagePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppUsagePlugin registerWithRegistrar:registrar];
}
@end
