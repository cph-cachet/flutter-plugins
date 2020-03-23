#import "EsensePlugin.h"
#import <esense/esense-Swift.h>

@implementation EsensePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEsensePlugin registerWithRegistrar:registrar];
}
@end
