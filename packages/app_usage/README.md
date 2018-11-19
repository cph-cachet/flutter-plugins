# app_usage

[![pub package](https://img.shields.io/pub/v/app_usage.svg)](https://pub.dartlang.org/packages/app_usage)

## Install
Add ```app_usage``` as a dependency in  `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

You need to add the following package to the manifest namespace in `AndroidManifest.xml`:
```xml
xmlns:tools="http://schemas.android.com/tools"
```

as well as the following permissions to the manifest:

```
    <uses-permission
        android:name="android.permission.PACKAGE_USAGE_STATS"
        tools:ignore="ProtectedPermissions" />
```

Below is an example of how the start of your manifest should look in the end
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="YOUR_PACKAGE_NAME_HERE"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission
        android:name="android.permission.PACKAGE_USAGE_STATS"
        tools:ignore="ProtectedPermissions"/>
```

## Usage
```dart
void function() async {
  // Initialization
  AppUsage appUsage = new AppUsage();
  
  // Define a time interval
  DateTime endDate = new DateTime.now();
  DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);
  
  // Fetch the usage stats
  Map<String, double> usage = await appUsage.getUsage(startDate, endDate);
}
```
## Example

The first screen will ask for permission to view usage stats. Tap on your application.
![Screen 1](https://raw.githubusercontent.com/cph-cachet/flutter-plugins/master/packages/app_usage/images/screen1.png)

Tap on the 'Permit usage access' switch.
![Screen 2](https://raw.githubusercontent.com/cph-cachet/flutter-plugins/master/packages/app_usage/images/screen2.png)

Your application is now running, if the manifest has been corectly set up you should be presented with the following screen after tapping the refresh button.
![Screen 3](https://raw.githubusercontent.com/cph-cachet/flutter-plugins/master/packages/app_usage/images/screen3.png)
