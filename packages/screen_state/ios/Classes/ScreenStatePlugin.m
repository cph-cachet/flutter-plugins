#import "ScreenStatePlugin.h"
#if __has_include(<screen_state/screen_state-Swift.h>)
#import <screen_state/screen_state-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "screen_state-Swift.h"
#endif

@implementation ScreenStatePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftScreenStatePlugin registerWithRegistrar:registrar];
}
@end
