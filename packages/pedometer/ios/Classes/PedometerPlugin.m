#import "PedometerPlugin.h"
#import <pedometer/pedometer-Swift.h>

@implementation PedometerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPedometerPlugin registerWithRegistrar:registrar];
}
@end
