#import "NoisePlugin.h"
#import <noise/noise-Swift.h>

@implementation NoisePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNoisePlugin registerWithRegistrar:registrar];
}
@end
