#import "WeatherPlugin.h"
#import <weather/weather-Swift.h>

@implementation WeatherPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWeatherPlugin registerWithRegistrar:registrar];
}
@end
