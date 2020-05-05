# audio_streamer

Streaming of PCM audio from Android and iOS with a sample rate of 44,100 Hz

## Permissions
On *Android* you need to add a permission to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

On *iOS* enable the following:
* Capabilities > Background Modes > _Audio, AirPlay and Picture in Picture_
* In the Runner Xcode project edit the _Info.plist_ file. Add an entry for _'Privacy - Microphone Usage Description'_

When editing the `Info.plist` file manually, the entries needed are:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>YOUR DESCRIPTION</string>
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

## Example Usage 
See the file `example/lib/main.dart` for a fully fledged example app using the plugin.

```dart
  AudioStreamer _streamer = AudioStreamer();
  bool _isRecording = false;
  List<double> _audio = [];
  
  void onAudio(List<double> buffer) {
    _audio.addAll(buffer);
    double secondsRecorded = _audio.length.toDouble() / _streamer.sampleRate.toDouble();
    print('$secondsRecorded seconds recorded.');
  }

  void start() async {
    try {
      _streamer.start(onAudio);
      setState(() {
        _isRecording = true;
      });
    } catch (error) {
      print(error);
    }
  }

  void stop() async {
    bool stopped = await _streamer.stop();
    setState(() {
      _isRecording = stopped;
    });
  }
```
