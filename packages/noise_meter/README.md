# Noise Meter

A noise meter plugin for iOS and Android.

## Install

Add `noise_meter` as a dependency in `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

On **Android** you need to add a permission to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

On **iOS** enable the following in XCode:

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

See the example app for how to use the plugin. This app also illustrated how to obtain permission to access the microphone.

Noise sampling happens by listening to the `noise` stream, like this:

```dart
NoiseMeter().noise.listen(
  (NoiseReading noiseReading) {
    print('Noise: ${noiseReading.meanDecibel} dB');
    print('Max amp: ${noiseReading.maxDecibel} dB');
  },
  onError: (Object error) {
    print(error);
  },
  cancelOnError: true,
);
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
