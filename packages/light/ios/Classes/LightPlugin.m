#import "LightPlugin.h"
#if __has_include(<light/light-Swift.h>)
#import <light/light-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "light-Swift.h"
#endif

@implementation LightPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLightPlugin registerWithRegistrar:registrar];
}
@end
