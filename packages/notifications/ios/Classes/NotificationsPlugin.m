#import "NotificationsPlugin.h"
#import <notifications/notifications-Swift.h>

@implementation NotificationsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNotificationsPlugin registerWithRegistrar:registrar];
}
@end
