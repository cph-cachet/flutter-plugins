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

## Usage
### Initalization
Noise data will be streamed, and for this a few objects need to be initialized, such as a boolean representing the recording state, a stream and a NoiseMeter object.
```dart
bool _isRecording = false;
StreamSubscription<NoiseEvent> _noiseSubscription;
Noise _noise;
```

Furthermore, handling incoming events in a seperate method is also a good idea:
```dart
void onData(NoiseEvent e) {
    print("${e.decibel} dB");
}
```

Where `frequency` is the update rate in milliseconds of type `int`, this means the lower the update rate, the more frequently events will come in.

### Start listening
```dart
void startRecorder() async {
    try {
      _noise = new Noise(500); // New observation every 500 ms
      _noiseSubscription = _noise.noiseStream.listen(onData);
    } on NoiseMeterException catch (exception) {
      print(exception);
    }
}
```

Where `onData()` handles the events from `StreamSubscription`. An example could be:

```dart
void onData(NoiseEvent event) {
  print("noise level is ${event.decibel} decibel.");
}
```

Each incoming `NoiseEvent` has an integer field named `decibel` containing the noise level of the reading.

### Stop listening
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
