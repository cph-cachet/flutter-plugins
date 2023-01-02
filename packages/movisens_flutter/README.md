# Movisens Flutter Plugin

[![pub package](https://img.shields.io/pub/v/movisens_flutter.svg)](https://pub.dartlang.org/packages/movisens_flutter)

A plugin for connecting and collecting data from a Movisens sensor. Works for both Android and iOS.

# Install

Add `movisens_flutter` as a dependency in `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

## Android

### Permissions

Add the following to your `android/app/src/main/AndroidManifest.xml` :

```dart
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### AndroidManifest.xml

Update the `android/app/build.gradle` to `minSdkVersion` at least 19

```gradle
android {
  defaultConfig {
      ...
      minSdkVersion 19
      ...
  }
}
```

## iOS

Add the following to your `ios/Runner/Info.plist` :

```
<dict>
  <key>NSBluetoothAlwaysUsageDescription</key>
  <string>Need BLE permission</string>
  <key>NSBluetoothPeripheralUsageDescription</key>
  <string>Need BLE permission</string>
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>Need Location permission</string>
  <key>NSLocationAlwaysUsageDescription</key>
  <string>Need Location permission</string>
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Need Location permission</string>
```

# API

The `movisens_flutter` package is a Movisens-specific implementation of Bluetooth API.

At the top level you have a `MovisensDevice`. The device has a list of `MovisensService`s which split the data into categories of data.

Each service has a 1 or more `MovisensBluetoothCharacteristics`. Each characteristic is one data type. It can either be a stream of values such as `SensorTemperatureEvents` or a read/write such as `setDeleteData()`.

<img src="images/movisens-design.png" alt="drawing" width="800"/>

# Example Usage

## Initialization

To connect to a Movisens device, you must know its `name`.
Using the `name` you can build a `MovisensDevice` and connect.

> Why name and not MAC address?
>
> iOS does not provide MAC addresses of BLE devices - instead they use a generated UUID, which also differs for each phone.
> This means a single device will have different IDs on 2 seperate iPhones and cannot be used to locate a specific device.

Connecting might take a upwards of 10 seconds as the device has to both connect and load all its features.

```dart
// The MAC address of your device
String deviceName = "MOVISENS Sensor 03348";
// Your device
MovisensDevice device = MovisensDevice(name: deviceName);

// Connect to the device. This
await device.connect();
```

## Start Listening to streams

To listen to a movisens device, you must enable the device to notify you when it records data.
This is done using the `enableNotify()` which enables **ALL characteristics** in a service.

```dart
// Enable the device to emit all event for each service:
await device.ambientService?.enableNotify();
await device.edaService?.enableNotify();
await device.hrvService?.enableNotify();
await device.markerService?.enableNotify();
await device.batteryService?.enableNotify();
await device.physicalActivityService?.enableNotify();
await device.respirationService?.enableNotify();
await device.sensorControlService?.enableNotify();
await device.skinTemperatureService?.enableNotify();
```

Once the services are enabled, you can listen to the `events` stream of the service which contains **all** data emitted by all the characteristics in that perticular service.

Alternatively, you can listen to each specific characteristic such as `skinTemperatureEvents` and only receive event from that type.

> Please read the [Timestamps](#timestamps) section for important information about the recorded data events.

## Use read/write functions

Certain characteristics are not streamed and must be used with read/write actions.
E.g. deleting data from the device requires a write to the device.

```dart
// Deletion of data
await device.sensorControlService?.setDeleteData(true);
```

This will delete data on the device, given that no measurement is running.

## Disconnect

To stop listening and disconnect you simply use `disconnect()` on the device.

```dart
await device.disconnect();
```

# Example App

The example app showcases most of the features `movisens_flutter` has - just remember to set the name to your own device.

# Timestamps

On Movisens devices the stream of data sent through Bluetooth is **not instant** after it was measured on the device.

As can be seen in [this table](https://docs.movisens.com/BluetoothLowEnergy/#available-signals-per-sensor) in movisens documentation, values can be delayed by 0-84 seconds depending on both the device and the data type. E.g. the `Tap Marker` is instant with 0 seconds delay however the `hr_live` (heart rate) is delayed by 70 seconds. This **IS NOT HANDLED** by this package currently, to allow the developer customization based on their device type.

Additionally, buffered values are not stored with a timestamp per datum. Until Movisens provide more documentation on that behavior, this package will not attempt to interpret the timestamp of each datum and will instead **timestamp the datums with the current time** on the phone.

Furthermore, Movisens devices has the API to set the time with milliseconds since epoch (also supported by this package). This means the timestamp on the device can be different than the actual time, which is another reason this package use local timestamp.

# Movisens documentation

Movisens offers a documentation of _most_ of their devices functionalities.
`movisens_flutter` has tranfered most of the documentation - especially on each `MovisensEvent` type.
However, we recommend reading the movisens documentation as well for a better understanding.

An overview of the services and characteristics can be found [here](https://docs.movisens.com/BluetoothLowEnergy/#services-and-characteristics).

A more detailed description of what each characteristic is and how it is calculated can be found [here](https://docs.movisens.com/Algorithms/) and under each subsection of the "Algorithms" section.
