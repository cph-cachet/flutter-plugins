# noise_meter


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
```dart
int frequency = 500; 
Noise noise = new Noise(frequency);
StreamSubscription<NoiseEvent> _noiseSubscription;
```

Where `frequency` is the update rate in milliseconds of type `int`, this means the lower the update rate, the more frequently events will come in.

### Start listening
```dart
_noiseSubscription = noise.noiseStream.listen(onData);
```

Where `onData()` handles the events from `StreamSubscription`. An example could be:

```dart
void onData(NoiseEvent event) {
  _noiseValues.add(event.decibel);
}
```

Each `NoiseEvent` coming in has an  integer field called `decibel`, containing the noise level of the reading.

### Stop listening
```dart
_noiseSubscription.cancel();
```
