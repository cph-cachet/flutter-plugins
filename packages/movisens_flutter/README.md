# movisens_flutter_plugin
[![pub package](https://img.shields.io/pub/v/movisens_flutter.svg)](https://pub.dartlang.org/packages/movisens_flutter)

## Install
Add ```movisens_flutter``` as a dependency in  `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

## Android permissions
Add the following to your manifest

```dart
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## Example Usage
```dart
int weight = 100, height = 180, age = 25;
address = '88:6B:0F:82:1D:33';
name = 'Sensor 02655';

UserData userData = new UserData(
    weight, 
    height, 
    Gender.male, 
    age, 
    SensorLocation.chest, 
    address, 
    name
);

movisens.startSensing(userData);
movisens.movisensStream.listen(onData);
```
![image](https://i.imgur.com/EZuiKm5.png)