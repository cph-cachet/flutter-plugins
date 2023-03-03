# App Usage

[![pub package](https://img.shields.io/pub/v/app_usage.svg)](https://pub.dartlang.org/packages/app_usage)

Application usage stats for Android only. Note that the stats are only precise down to a daily basis. This is a limitation from Google's implementation.

## Install

Add `app_usage` as a dependency in  `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

## Android

> **Note:** Requires API level 21 as a minimum.

I.e. you need to set the min SDK version inside the `android/app/build.gradle`:

```xml
minSdkVersion 21
```

You need to add the following package to the manifest namespace in `AndroidManifest.xml`:

```xml
xmlns:tools="http://schemas.android.com/tools"
```

as well as the following permissions to the manifest:

```xml
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

The `AppUsage` class works as a singleton and you get app usage statistics by calling:

```dart
AppUsage().getAppUsage(startDate, endDate)
````

A larger example (from the example app) could look like:

```dart
  void getUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(hours: 1));
      List<AppUsageInfo> infoList =
          await AppUsage().getAppUsage(startDate, endDate);
      setState(() => _infos = infoList);

      for (var info in infoList) {
        print(info.toString());
      }
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }
```

Each `AppUsageInfo` object has the following public fields:

```dart
  /// The name of the application
  String get appName => _appName;

  /// The name of the application package
  String get packageName => _packageName;

  /// The amount of time the application has been used
  /// in the specified interval
  Duration get usage => _usage;

  /// The start of the interval
  DateTime get startDate => _startDate;

  /// The end of the interval
  DateTime get endDate => _endDate;

  /// Last time app was in foreground
  DateTime get lastForeground => _lastForeground;

```

## Example app

The example app shows how to use the plugin.

The first screen will ask for permission to view usage stats. Tap on your application and allow it to access usage information. Then you can "download" app usage stats by pressing the arrow button.
