#import "AirQualityPlugin.h"
#import <air_quality/air_quality-Swift.h>

@implementation AirQualityPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAirQualityPlugin registerWithRegistrar:registrar];
}
@end
