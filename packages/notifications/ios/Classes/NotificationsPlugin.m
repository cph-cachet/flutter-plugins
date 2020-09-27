#import "NotificationsPlugin.h"
#if __has_include(<notifications/notifications-Swift.h>)
#import <notifications/notifications-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "notifications-Swift.h"
#endif

@implementation NotificationsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNotificationsPlugin registerWithRegistrar:registrar];
}
@end
