#import "AudioStreamerPlugin.h"
#if __has_include(<audio_streamer/audio_streamer-Swift.h>)
#import <audio_streamer/audio_streamer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "audio_streamer-Swift.h"
#endif

@implementation AudioStreamerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAudioStreamerPlugin registerWithRegistrar:registrar];
}
@end
