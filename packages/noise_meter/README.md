# noise_meter

[![pub package](https://img.shields.io/pub/v/noise_meter.svg)](https://pub.dartlang.org/packages/noise_meter)

## Install
Add ```noise_meter``` as a dependency in  `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

On *Android* you need to add a permission to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

On *iOS* enable the following:
* Capabilities > Background Modes > _Audio, AirPlay and Picture in Picture_
* In the Runner Xcode project edit the _Info.plist_ file. Add an entry for _'Privacy - Microphone Usage Description'_


## Usage
### Initalization
Keep these three variables accessible:
```dart
bool _isRecording = false;
StreamSubscription<NoiseReading> _noiseSubscription;
NoiseMeter _noiseMeter;
```

### Start listening
The easiest thing to do is to create a new instance of the NoiseMeter every time a new recording is started.
```dart
void startRecorder() async {
  try {
    _noiseMeter = new NoiseMeter();
    _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
  } on NoiseMeterException catch (exception) {
    print(exception);
  }
}
```


### On data
When data comes in through the stream, it will be caught by the `onData` method, specified when the subscription was created.
The incoming data points are of type `NoiseReading` which have a single field with a getter, namely the `db` value of type `double`.
```dart
void onData(NoiseReading noiseReading) {
  this.setState(() {
    if (!this._isRecording) {
      this._isRecording = true;
    }
  });
  /// Do someting with the noiseReading object
  print(noiseReading.toString());
}
```

### Stop listening
To stop listening, the `.cancel()` method is called on the subscription object.
```dart
void stopRecorder() async {
  try {
    if (_noiseSubscription != null) {
      _noiseSubscription.cancel();
      _noiseSubscription = null;
    }
    this.setState(() {
      this._isRecording = false;
    });
  } catch (err) {
    print('stopRecorder error: $err');
  }
}
```
