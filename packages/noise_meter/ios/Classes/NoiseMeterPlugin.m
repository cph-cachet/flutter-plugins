#import "NoiseMeterPlugin.h"
#import <noise_meter/noise_meter-Swift.h>

@implementation NoiseMeterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNoiseMeterPlugin registerWithRegistrar:registrar];
}
@end
