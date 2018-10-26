#import "AmbientSoundPlugin.h"
#import <ambient_sound/ambient_sound-Swift.h>

@implementation AmbientSoundPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAmbientSoundPlugin registerWithRegistrar:registrar];
}
@end
