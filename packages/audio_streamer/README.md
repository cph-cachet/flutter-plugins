# Audio Streamer

Streaming of PCM audio from Android and iOS with a customizable sampling rate.

## Permissions

On **Android** add the audio recording permission to `AndroidManifest.xml`.

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

On **iOS** enable the following:

- Capabilities > Background Modes > _Audio, AirPlay and Picture in Picture_
- In the Runner Xcode project edit the `Info.plist` file. Add an entry for _'Privacy - Microphone Usage Description'_

When editing the `Info.plist` file manually, the entries needed are:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>YOUR DESCRIPTION</string>
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

- Edit the `Podfile` to include the permission for the microphone:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    target.build_configurations.each do |config|
      # for more infomation: https://github.com/BaseflowIT/flutter-permission-handler/blob/master/permission_handler/ios/Classes/PermissionHandlerEnums.h
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_MICROPHONE=1',]
    end
  end
end
```

## Example

See the file `example/lib/main.dart` for a fully fledged example app using the plugin.
Note that on iOS the sample rate will not necessarily change, as there is only the option to set a preferred one.

```dart
  // Note that AudioStreamer works as a singleton.
  AudioStreamer streamer = AudioStreamer();
  bool _isRecording = false;
  List<double> _audio = [];

  void onAudio(List<double> buffer) async {
    _audio.addAll(buffer);
    var sampleRate = await streamer.actualSampleRate;
    double secondsRecorded = _audio.length.toDouble() / sampleRate;
    print('Max amp: ${buffer.reduce(max)}');
    print('Min amp: ${buffer.reduce(min)}');
    print('$secondsRecorded seconds recorded.');
    print('-' * 50);
  }

  void handleError(PlatformException error) {
    print(error);
  }

  void start() async {
    try {
      // start streaming using default sample rate of 44100 Hz
      streamer.start(onAudio, handleError);

      setState(() {
        _isRecording = true;
      });
    } catch (error) {
      print(error);
    }
  }

  void stop() async {
    bool stopped = await streamer.stop();
    setState(() {
      _isRecording = stopped;
    });
  }
```
