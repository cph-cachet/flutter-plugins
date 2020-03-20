#import "ActivityRecognitionFlutterPlugin.h"
#if __has_include(<activity_recognition_flutter/activity_recognition_flutter-Swift.h>)
#import <activity_recognition_flutter/activity_recognition_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "activity_recognition_flutter-Swift.h"
#endif

@implementation ActivityRecognitionFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftActivityRecognitionFlutterPlugin registerWithRegistrar:registrar];
}
@end
