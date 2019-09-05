#import "FlutterHealthPlugin.h"
#import <flutter_health/flutter_health-Swift.h>

@implementation FlutterHealthPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterHealthPlugin registerWithRegistrar:registrar];
}
@end
