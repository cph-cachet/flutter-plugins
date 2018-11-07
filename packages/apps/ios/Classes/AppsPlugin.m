#import "AppsPlugin.h"
#import <apps/apps-Swift.h>

@implementation AppsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppsPlugin registerWithRegistrar:registrar];
}
@end
