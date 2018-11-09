#import "NoiseLevelPlugin.h"
#import <noise_level/noise_level-Swift.h>

@implementation NoiseLevelPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNoiseLevelPlugin registerWithRegistrar:registrar];
}
@end
