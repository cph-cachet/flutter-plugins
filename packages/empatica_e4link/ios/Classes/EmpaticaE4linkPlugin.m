#import "EmpaticaE4linkPlugin.h"
#if __has_include(<empatica_e4link/empatica_e4link-Swift.h>)
#import <empatica_e4link/empatica_e4link-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "empatica_e4link-Swift.h"
#endif

@implementation EmpaticaE4linkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEmpaticaE4linkPlugin registerWithRegistrar:registrar];
}
@end
