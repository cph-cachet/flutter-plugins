# Light

[![pub package](https://img.shields.io/pub/v/light.svg)](https://pub.dartlang.org/packages/light)

A Flutter plugin for collecting data from the [ambient light sensor on Android](https://developer.android.com/guide/topics/sensors/sensors_environment#java).

## Install

Add `light` as a dependency in the `pubspec.yaml` file.

For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

## Usage

Instantiate an instance of the `Light()` plugin and listen on the `lightSensorStream` stream.

```dart
  Light? _light;
  StreamSubscription? _subscription;

  void onData(int luxValue) async {
    print("Lux value: $luxValue");
  }


  void startListening() {
    _light = Light();
    try {
      _subscription = _light?.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      print(exception);
    }
  }

  void stopListening() {
    _subscription?.cancel();
  }
```
