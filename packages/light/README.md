# light

A light sensor plugin for Flutter, reads the intensity of light in lux, and reports this number back.
The API for getting the current light exposure is only available on Android devices, and the plugin will therefore not work for iOS devices.

## Install
Add ```light``` as a dependency in  `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

## Usage
Al incoming data points are streamed with a `StreamSubscription` which is set up by calling the `listen()` method on the `light.lightSensorStream` stream object.

Given a method `_onData(int lux)` the subscription can be set up as follows:
```dart
Light _light;
StreamSubscription _subscription;
...
void onData(int luxValue) async {
    print("Lux value from Light Sensor: $luxValue");
}

void startListening() {
    _light = new Light();
    try {
      _subscription = _light.lightSensorStream.listen(onData);
    }
    on LightException catch (exception) {
      print(exception);
    }
}
```

The stream can also be cancelled again by calling the `cancel()` method:

```dart
  void stopListening() {
    _subscription.cancel();
  }
```




