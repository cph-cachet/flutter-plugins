#import "MovisensFlutterPlugin.h"
#if __has_include(<movisens_flutter/movisens_flutter-Swift.h>)
#import <movisens_flutter/movisens_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "movisens_flutter-Swift.h"
#endif

@implementation MovisensFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMovisensFlutterPlugin registerWithRegistrar:registrar];
}
@end
