#import "LightPlugin.h"
#import <light/light-Swift.h>

@implementation LightPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLightPlugin registerWithRegistrar:registrar];
}
@end
