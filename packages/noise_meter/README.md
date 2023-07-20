# Noise Meter

A noise meter package for iOS and Android.

## Install

Add `noise_meter` as a dependency in `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

On _Android_ you need to add a permission to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

On _iOS_ enable the following:

- Capabilities > Background Modes > _Audio, AirPlay and Picture in Picture_
- In the Runner Xcode project edit the _Info.plist_ file. Add an entry for _'Privacy - Microphone Usage Description'_
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

## Usage

See the full example app for how to use the plugin.

### Initialization

The example app uses these variables:

```dart
  bool _isRecording = false;
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;
```

### Start listening

You listen to noise readings via the `noise` stream on the `NoiseMeter` instance.

```dart
  void start() {
    try {
      _noiseSubscription = _noiseMeter?.noise.listen(onData);
    } catch (err) {
      print(err);
    }
  }
```

### On data

When data is streamed, it will be send to the `onData` method, specified when the subscription was created. The incoming data points are of type `NoiseReading` which holds the mean and maximum decibel reading.

```dart
  void onData(NoiseReading noiseReading) {
    this.setState(() {
      _latestReading = noiseReading;
      if (!this._isRecording) this._isRecording = true;
    });
  }
```

### On errors

Platform errors may occur when recording is interrupted. You must decide what happens if such an error occurs. The [onError] callback must be of type `void Function(Object error)` or `void Function(Object error, StackTrace trace)`.

```dart
  void onError(Object error) {
    print(error);
    _isRecording = false;
  }
```

### Stop listening

To stop listening, the `cancel` method is called on the subscription object.

```dart
  void stop() {
    try {
      _noiseSubscription?.cancel();
      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print(err);
    }
  }
```

## Technical documentation

### Sample rate

The sample rate for both Android and iOS implementations are 44,100.

### Microphone data

The native implementations record PCM data using the microphone of the device, and uses an audio buffer array to store the incoming data. When the buffer is filled, the contents are emitted to the Flutter side. The incoming floating point values are between -1 and 1 which is the PCM values divided by the max amplitude value which is 2^15.

### Conversion to Decibel

Computing the decibel of a PCM value is done as follows:

```python
db = 20 * log10(2**15 * pcmValue)
```
