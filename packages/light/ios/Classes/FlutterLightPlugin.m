#import "FlutterLightPlugin.h"
#import <flutter_light/flutter_light-Swift.h>

@implementation FlutterLightPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterLightPlugin registerWithRegistrar:registrar];
}
@end
