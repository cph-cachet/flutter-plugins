# pedometer

[![pub package](https://img.shields.io/pub/v/pedometer.svg)](https://pub.dartlang.org/packages/pedometer)

This plugin allows for continuous step counting using the built-in pedometer sensor API of iOS and Android devices.

The step count returned is the number of steps since the phone was last booted. 

## Permissions for Android
For Android 10 and above add the following permission to the Android manifest:

```dart
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

## Permissions for iOS
Users of this plug-in will have to manually open XCode and configure a few settings manually, mostly pertaining to privacy settings and permissions due to the application collecting the user's movement data.

### Step 0: 
Open the XCode project located at `<your_project>/iOS/Runner.xcodeproj`

### Step 1: Set Capabilities
![screen shot 2018-08-08 at 10 09 11](https://user-images.githubusercontent.com/9467047/43827207-902101f6-9af9-11e8-8341-d399ece490f6.png)

### Step 2: Configure your plist
![screen shot 2018-08-08 at 11 07 21](https://user-images.githubusercontent.com/9467047/43827874-3bd9a970-9afb-11e8-80bb-c9ec25b026c3.png)

## XCode Issue: Enabling @objc inference
![7jcq5](https://user-images.githubusercontent.com/9467047/43827445-21326694-9afa-11e8-8e0c-60e829eb4c79.png)

Any errors are only visible when running through XCode, unfortunately.
![screen shot 2018-08-07 at 16 04 31](https://user-images.githubusercontent.com/9467047/43827142-6e0b8f00-9af9-11e8-80b6-f01b5db33713.png)

To use this plugin, add `pedometer` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Example Usage

``` dart
Pedometer _pedometer;
StreamSubscription<int> _subscription;

...
void onData(int stepCountValue) {
    print(stepCountValue);
}

void startListening() {
    _pedometer = new Pedometer();
    _subscription = _pedometer.pedometerStream.listen(_onData,
        onError: _onError, onDone: _onDone, cancelOnError: true);
}

void stopListening() {
    _subscription.cancel();
}

void _onData(int stepCountValue) async {
    setState(() => _stepCountValue = "$stepCountValue");
}

void _onDone() => print("Finished pedometer tracking");

void _onError(error) => print("Flutter Pedometer Error: $error");
        
```

Consult the example-app for a concrete implementation.

