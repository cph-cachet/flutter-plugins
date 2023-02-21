# Movisens Flutter Plugin

[![pub package](https://img.shields.io/pub/v/movisens_flutter.svg)](https://pub.dartlang.org/packages/movisens_flutter)

A plugin for connecting and collecting data from a Movisens sensor. Works for both Android and iOS.

## Install

Add `movisens_flutter` as a dependency in `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

### Android

Add the following to your `android/app/src/main/AndroidManifest.xml` :

```dart
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

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

### iOS

Add the following to your `ios/Runner/Info.plist` :

```xml
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

## API

The `movisens_flutter` package is a Movisens-specific implementation of Bluetooth API.

At the top level you have a `MovisensDevice`. The device has a list of `MovisensService`s which split the data into categories of data.

As illustrated below, each service has a 1 or more `MovisensBluetoothCharacteristics`. Each characteristic is one data type. It can either be a stream of values such as `SensorTemperatureEvents` or a read/write such as `setDeleteData()`.

<img src="https://raw.githubusercontent.com/cph-cachet/flutter-plugins/master/packages/movisens_flutter/images/movisens-design.png" alt="movisens_flutter_design" width="776"/>

### Undocumented API

4 services and 9 characterisics are not documented in Movisens' documentation as they are part of the general Bluetooth GATT specifications but have been added to this plugin.
Below is a list of their names and UUIDs. The battery service, heart rate service and user data service have been added to the movisens specific implementations for simplicity of the plugin API.

- SERVICE: 0000180f-0000-1000-8000-00805f9b34fb // **_BATTERY SERVICE_** (added to the Battery Service)

  - 00002a19-0000-1000-8000-00805f9b34fb // Battery Level

- SERVICE: 0000180a-0000-1000-8000-00805f9b34fb // **_DEVICE INFORMATION SERVICE_**

  - 00002a26-0000-1000-8000-00805f9b34fb // Firmware Revision String
  - 00002a29-0000-1000-8000-00805f9b34fb // Manufacturer Name String
  - 00002a24-0000-1000-8000-00805f9b34fb // Model Number String
  - 00002a25-0000-1000-8000-00805f9b34fb // Serial Number String

- SERVICE 0000180d-0000-1000-8000-00805f9b34fb // **_HEART RATE SERVICE_** (added to the HRV Service)

  - 00002a37-0000-1000-8000-00805f9b34fb // Heart Rate Measurement

- SERVICE: 0000181c-0000-1000-8000-00805f9b34fb // **_USER DATA SERVICE_** (added to the User Data Service)
  - 00002a8c-0000-1000-8000-00805f9b34fb // gender
  - 00002a8e-0000-1000-8000-00805f9b34fb // height
  - 00002a98-0000-1000-8000-00805f9b34fb // weight

## Example Usage

### Initialization

To connect to a Movisens device, you must know its `name`.
Using the `name` you can create a `MovisensDevice` and connect.

> Why name and not MAC address?
>
> iOS does not provide MAC addresses of BLE devices - instead they use a generated UUID, which also differs for each phone.
> This means a single device will have different IDs on 2 separate iPhones and cannot be used to locate a specific device.

Connecting might take up to 10 seconds as the device has to both connect and load all its features.

```dart
// The name of your device
String deviceName = "MOVISENS Sensor 03348";

MovisensDevice device = MovisensDevice(name: deviceName);

// Connect to the device.
await device.connect();
```

### Start Listening to streams

To listen to a Movisens device, you must enable the device to notify you when it records data.
This is done using the `enableNotify()` which enables **all** characteristics (i.e. event types) in a service.

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
await device.deviceInformationService?.enableNotify();
```

Once the services are enabled, you can listen to the `events` stream of the service which contains **all** data emitted by all the characteristics in that particular service.

Alternatively, you can listen to each specific characteristic such as `skinTemperatureEvents` and only receive event from that type.

> Please read the [Timestamps](#timestamps) section for important information about the recorded data events.

### Using Read/Write Functions

Certain characteristics are not streamed and must be used with read/write actions.
E.g. deleting data from the device requires a write to the device.

```dart
await device.sensorControlService?.setDeleteData(true);
```

This will delete data on the device, given that no measurement is running.

### Disconnect

To stop listening and disconnect you simply call `disconnect()` on the device.

```dart
await device.disconnect();
```

## Example App

The example app showcases most of the features `movisens_flutter` has - just remember to set the name to your own device.

## Timestamps

On Movisens devices, the stream of data is **not** transmitted instantly over Bluetooth when measured on the device.

As shown in [this table](https://docs.movisens.com/BluetoothLowEnergy/#available-signals-per-sensor) on the Movisens documentation homepage, values can be delayed by 0 and up to 84 seconds depending on both the device and the data type.
For example, the `marker` (tapping the device) is instant with 0 seconds delay, whereas the `hr_live` (heart rate) is delayed by 70 seconds.
This delay **IS NOT HANDLED** by this package.
Each of the different data event streams delivers the data event as received via the Bluetooth channel.

Additionally, buffered values are not stored with a timestamp per event. Until Movisens provide more documentation on that behavior, this package will not attempt to interpret the timestamp of each event and will instead **timestamp the events with the local time** on the phone.

Furthermore, Movisens devices has an API to set the time with milliseconds since epoch (also supported by this package). This means the timestamp on the device can be different than the actual time, which is another reason this package uses the phone timestamp.

## Movisens documentation

Movisens offers documentation on _most_ of their devices functionalities.
`movisens_flutter` has copied most of this documentation - especially on each `MovisensEvent` type.
However, we recommend reading the Movisens documentation as well for a better understanding.

An overview of the services and characteristics can be found [here](https://docs.movisens.com/BluetoothLowEnergy/#services-and-characteristics).

A more detailed description of what each characteristic is and how it is calculated can be found [here](https://docs.movisens.com/Algorithms/) and under each subsection of the "Algorithms" section.
