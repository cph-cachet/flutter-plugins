#import "EsenseFlutterPlugin.h"
#import <esense_flutter/esense_flutter-Swift.h>

@implementation EsenseFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEsenseFlutterPlugin registerWithRegistrar:registrar];
}
@end
