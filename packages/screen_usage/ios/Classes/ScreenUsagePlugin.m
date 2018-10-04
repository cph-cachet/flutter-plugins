#import "ScreenUsagePlugin.h"
#import <screen_usage/screen_usage-Swift.h>

@implementation ScreenUsagePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftScreenUsagePlugin registerWithRegistrar:registrar];
}
@end
