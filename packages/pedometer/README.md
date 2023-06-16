# Pedometer

[![pub package](https://img.shields.io/pub/v/pedometer.svg)](https://pub.dartlang.org/packages/pedometer)

This plugin allows for continuous step counting and pedestrian status using the built-in pedometer sensor API of iOS and Android devices.

![](https://raw.githubusercontent.com/cph-cachet/flutter-plugins/master/packages/pedometer/imgs/screenshots.png)

## Permissions

For Android 10 and above add the following permission to the Android manifest:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

For iOS, add the following entries to your Info.plist file in the Runner xcode project:

```xml
<key>NSMotionUsageDescription</key>
<string>This application tracks your steps</string>
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

## Step Count

The step count represents the number of steps taken since the last system boot.
On Android, any steps taken before installing the application will not be counted.

## Pedestrian Status

The Pedestrian status is either `walking` or `stopped`. In the case that of an error,
the status will be `unknown`.

## Availability of Sensors

Both Step Count and Pedestrian Status may not be available on some phones:

* It was found that some Samsung phones do not support Step Count or Pedestrian Status
* Older iPhones do not support Pedestrian Status in particular

In the case that the step sensor is not available, an error will be thrown. The application needs to handle this error.

## Example Usage

See the [example app](https://github.com/cph-cachet/flutter-plugins/blob/master/packages/pedometer/example/lib/main.dart) for a fully-fledged example.

Below is shown a more generalized example. Remember to set the required permissions, as described above. This may require you to manually allow the permission in the "Settings" on the phone.

``` dart
  Stream<StepCount> _stepCountStream;
  Stream<PedestrianStatus> _pedestrianStatusStream;

  /// Handle step count changed
  void onStepCount(StepCount event) {
    int steps = event.steps;
    DateTime timeStamp = event.timeStamp;
  }

  /// Handle status changed
  void onPedestrianStatusChanged(PedestrianStatus event) {
    String status = event.status;
    DateTime timeStamp = event.timeStamp;
  }

    /// Handle the error
  void onPedestrianStatusError(error) {}

  /// Handle the error
  void onStepCountError(error) {}

  Future<void> initPlatformState() async {
    // Init streams
    _pedestrianStatusStream = await Pedometer.pedestrianStatusStream;
    _stepCountStream = await Pedometer.stepCountStream;

    // Listen to streams and handle errors
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    _pedestrianStatusStream
      .listen(onPedestrianStatusChanged)
      .onError(onPedestrianStatusError);
  }
```
