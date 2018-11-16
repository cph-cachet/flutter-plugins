#import "AppUsagePlugin.h"
#import <app_usage/app_usage-Swift.h>

@implementation AppUsagePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppUsagePlugin registerWithRegistrar:registrar];
}
@end
