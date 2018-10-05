#import "ScreenStatePlugin.h"
#import <screen_state/screen_state-Swift.h>

@implementation ScreenStatePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftScreenStatePlugin registerWithRegistrar:registrar];
}
@end
