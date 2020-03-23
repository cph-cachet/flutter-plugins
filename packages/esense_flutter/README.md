# eSense Flutter

This plugin supports the [eSense](http://www.esense.io) earable computing platform on both Android and iOS.


[![pub package](https://img.shields.io/pub/v/esense_flutter.svg)](https://pub.dartlang.org/packages/esense_flutter)

## Install (Flutter)
Add ```esense_flutter``` as a dependency in  `pubspec.yaml`.
For help on adding as a dependency, view the [pubspec documenation](https://flutter.io/using-packages/).

## AndroidX support
**Only for Android API level 28**

Update the contents of the `android/gradle.properties` file with the following:
```
android.enableJetifier=true
android.useAndroidX=true
org.gradle.jvmargs=-Xmx1536M
```

Next, add the following dependencies to your `android/build.gradle` file:
```
dependencies {
  classpath 'com.android.tools.build:gradle:3.3.0'
  classpath 'com.google.gms:google-services:4.2.0'
} 
```

And finally, set the Android compile- and minimum SDK versions to `compileSdkVersion 28`, 
and `minSdkVersion 23` respectively, inside the `android/app/build.gradle` file.

## Android Permissions
The package uses your location and bluetooth to fetch data from the eSense ear plugs.
Therefore location tracking and bluetooth must be enabled.

Add the following entry to your `manifest.xml` file, in the Android project of your application:

```xml
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-feature android:name="android.hardware.bluetooth_le" android:required="true"/>
```

In addition, your __minimum SDK version__ should be __23__.

## iOS

Requires iOS 10 or later. Hence, in your `Podfile` in the `ios` folder of your app, 
make sure that the platform is set to `10.0`.
 

```
platform :ios, '10.0'
```

Add this permission in the `Info.plist` file located in `ios/Runner`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Uses bluetooth to connect to the eSense device</string>
<key>UIBackgroundModes</key>
  <array>
  <string>audio</string>
  <string>external-accessory</string>
  <string>fetch</string>
</array>

```

## Usage

The eSense Flutter plugin has been designed to resemble the Android eSense API almost __1:1__. Hence, you should be able
to recognize the names of the different classes and class variables.  
For example, the methods on the [`ESenseManager`](https://pub.dev/documentation/esense/latest/esense/ESenseManager-class.html) class is mapped 1:1. 
See the [eSense Android documentation](http://www.esense.io/share/eSense-Android-Library.pdf) on how it all works.

However, one major design change has been done; this eSense Flutter plugin complies to the Dart/Flutter reactive programming 
architecture using [Stream](https://api.dartlang.org/stable/2.4.0/dart-async/Stream-class.html)s.
Hence, you do not 'add listerners' to an eSense device (as you do in Java) -- rather, you obtain a Dart stream and listen
to this stream (and exploit all the [other very nice stream operations](https://dart.dev/tutorials/language/streams) which are available in Dart).
Below, we shall describe how to use the eSense streams. 
But first -- let's see how to set up and connect to an eSense device in the first place.

Note that playing and recording audio are performed via the Bluetooth Classic interface and are not 
supported by the eSense library described here.



### Setting up and Connecting to an eSense Device

All operations on the eSense device happens via the [`ESenseManager`](https://pub.dev/documentation/esense/latest/esense/ESenseManager-class.html).
When connecting, specify the name of the device (typically on the form `eSense-xxxx`).

```dart
import 'package:esense/esense.dart';

...

// first listen to connection events before trying to connect
ESenseManager.connectionEvents.listen((event) {
  print('CONNECTION event: $event');
}

// try to connect to the eSense device with a given name
bool success = await ESenseManager.connect(eSenseName);
```

Everything with the eSense API happens asynchronously. Hence, the `connect` call merely initiates the connection
process. In order to know the status of the connection process (successful or not), you should listen to 
connection events ([`ConnectionEvent`](https://pub.dev/documentation/esense/latest/esense/ConnectionEvent-class.html)).
This is done via the [`connectionEvents`](https://pub.dev/documentation/esense/latest/esense/ESenseManager/connectionEvents.html) stream.
Note, that if you want to know if your connection to the device is successful, you should initiate listening
__before__ the connection is initiated, as shown above.

### Listen to Sensor Events

You can access a stream of [`SensorEvent`](https://pub.dev/documentation/esense/latest/esense/SensorEvent-class.html) 
events via the [`ESenseManager.sensorEvents`](https://pub.dev/documentation/esense/latest/esense/ESenseManager/sensorEvents.html) stream.
Sampling rate can be set when not listening.

`````dart
StreamSubscription subscription = ESenseManager.sensorEvents.listen((event) {
  print('SENSOR event: $event'
});

...

subscription.cancel();
ESenseManager.setSamplingRate(5);

... 

subscription = ESenseManager.sensorEvents.listen((event) {
  print('SENSOR event: $event');
});
`````

### Read eSense Device Events

Reading properties of the eSense device happens asynchronously. Hence, in order to obtain properties, you should 
do two things:

  1. listen to the [`ESenseManager.eSenseEvents`](https://pub.dev/documentation/esense/latest/esense/ESenseManager/eSenseEvents.html) stream
  2. invoke read operation on the `ESenseManager`
  
Invoking read operations will trigger [`ESenseEvent`](https://pub.dev/documentation/esense/latest/esense/ESenseEvent-class.html) events of various kinds.

`````dart
// set up a event listener
ESenseManager.eSenseEvents.listen((event) {
  print('ESENSE event: $event');
}

// now invoke read operations on the manager
ESenseManager.getDeviceName();
`````

When the button on the eSense device is pressed, the `eSenseEvents` stream will send an [`ButtonEventChanged`](https://pub.dev/documentation/esense/latest/esense/ButtonEventChanged-class.html) event.


### Change the Configuration of the eSense Device

The [`ESenseManager`](https://pub.dev/documentation/esense/latest/esense/ESenseManager-class.html) exposes methods 
to change the configuration of the eSense device. 
With the plugin, you can change the device name using [`setDeviceName()`](https://pub.dev/documentation/esense/latest/esense/ESenseManager/setDeviceName.html), 
change the advertising and connection interval using [`setAdvertisementAndConnectiontInterval()`](https://pub.dev/documentation/esense/latest/esense/ESenseManager/setAdvertisementAndConnectiontInterval.html), 
and change the IMU sensor configuration using [`setSensorConfig()`](https://pub.dev/documentation/esense/latest/esense/ESenseManager/setSensorConfig.html).

__Note:__ At the time of writing, the `setSensorConfig()` method is _not_ implemented.

### Limitations in the eSense BTLE interface

Note that there is a limitation to the eSense BTLE interface which implie that you __should not__ 
invoke methods on the ESenseManager in a fast pace after each other.
For example, the following code __will not work__:

`````dart
// set up a event listener
ESenseManager.eSenseEvents.listen((event) {
  print('ESENSE event: $event');
}

// now invoke read operations on the manager
// THIS WILL NOT WORK!
ESenseManager.getDeviceName();
ESenseManager.getAccelerometerOffset();
ESenseManager.getAdvertisementAndConnectionInterval();
`````

In this case, the first operation (listening to the Esense Events) will succeed - the rest will fail.
In the example app, this has been fixed by adding delays to method call, like;

```dart
// get the battery level every 10 secs
Timer.periodic(Duration(seconds: 10), (timer) async => await ESenseManager.getBatteryVoltage());

// wait 2, 3, 4, 5, ... secs before getting the name, offset, etc.
// it seems like the eSense BTLE interface does NOT like to get called
// several times in a row -- hence, delays are added in the following calls
Timer(Duration(seconds: 2), () async => await ESenseManager.getDeviceName());
Timer(Duration(seconds: 3), () async => await ESenseManager.getAccelerometerOffset());
Timer(Duration(seconds: 4), () async => await ESenseManager.getAdvertisementAndConnectionInterval());
Timer(Duration(seconds: 5), () async => await ESenseManager.getSensorConfig());
```

## Authors

 * [Jakob E. Bardram](http://www.bardram.net) Technical University of Denmark
 * The iOS implementation uses the [eSense iOS Library](https://github.com/tetujin/ESense).


## Getting Started with Flutter

For help getting started with Flutter, view the 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
