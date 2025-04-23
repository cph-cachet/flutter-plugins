# Light

[![pub package](https://img.shields.io/pub/v/light.svg)](https://pub.dartlang.org/packages/light)

A Flutter plugin for collecting ambient light data from the [Android Environment Sensors](https://developer.android.com/develop/sensors-and-location/sensors/sensors_environment).

## Install

Add `light` as a dependency in the `pubspec.yaml` file.

For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

## Usage

Use the singleton `Light()` to listen on the `lightSensorStream` stream.

```dart
  StreamSubscription<int>? _lightEvents;

  void startListening() {
    try {
      _lightEvents =
          Light().lightSensorStream.listen((luxValue) => setState(() {
                // Do something with the lux value
              }));
    } catch (exception) {
      print(exception);
    }
  }

  void stopListening() {
    _lightEvents?.cancel();
  }
```
