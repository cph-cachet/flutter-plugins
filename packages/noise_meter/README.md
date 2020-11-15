# noise_meter

A noise meter package for iOS and Android.

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
### Initialization
Keep these three variables accessible:
```dart
bool _isRecording = false;
StreamSubscription<NoiseReading> _noiseSubscription;
NoiseMeter _noiseMeter = new NoiseMeter(onError);
```

### Start listening
The easiest thing to do is to create a new instance of the NoiseMeter every time a new recording is started.
```dart
void start() async {
    try {
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

### On errors
Platform errors may occur when recording is interupted. You must decide what happens if such an error occurs.

````dart
void onError(PlatformException e) {
    print(e.toString());
    _isRecording = false;
}
````

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
## Technical documentation

### Sample rate
The sample rate for both native implementations is 44,100. 

### Microphone data
The native implementations record PCM data using the microphone of the device, and uses an audio buffer array to store the incoming data. When the buffer is filled, the contents are emitted to the Flutter side. The incoming floating point values are between -1 and 1 which is the PCM values divided by the max amplitude value which is 2^15.

### Conversion to Decibel

Computing the decibel of a PCM value is done as follows:
```python
db = 20 * log10(2**15 * pcmValue)
```
