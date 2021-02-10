# app_usage

[![pub package](https://img.shields.io/pub/v/app_usage.svg)](https://pub.dartlang.org/packages/app_usage)

Application usage stats for Android only. Note that the stats are only precise down to a daily basis. This is a limitation from Google's implementation, unfortunately.
## Install
Add ```app_usage``` as a dependency in  `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

## Android
*NB: Requires API level 21 as a minimum!*

I.e. you need to set the min SDK version inside the `android/app/build.gradle`:

```xml
minSdkVersion 21
```

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
  void getUsageStats() async {
    try {
      DateTime startDate = DateTime(2018, 01, 01);
      DateTime endDate = new DateTime.now();
      List<AppUsageInfo> infos = await AppUsage.getAppUsage(startDate, endDate);
      setState(() {
        _infos = infos;
      });
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }
```

Each `AppUsageInfo` object has the following public fields:

```dart
  /// The name of the application
  String get appName;

  /// The name of the application package
  String get packageName;

  /// The amount of time the application has been used
  /// in the specified interval
  Duration get usage;

  /// The start of the interval
  DateTime get startDate;

  /// The end of the interval
  DateTime get endDate;
```


## Example screenshot
The first screen will ask for permission to view usage stats. Tap on your application.
![Screenshot](https://raw.githubusercontent.com/cph-cachet/flutter-plugins/master/packages/app_usage/images/app_usage_screenshot.png)