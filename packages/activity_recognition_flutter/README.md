# Activity Recognition

[![pub package](https://img.shields.io/pub/v/activity_recognition_flutter.svg)](https://pub.dartlang.org/packages/activity_recognition)

Activity recognition plugin for Android and iOS. Only working while App is running (= not terminated by the user or OS).


## Configuration

### Android 

Add the following entries inside the `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

Next, add the plugin's service inside the `<application>` tag:

```xml
<receiver android:name="dk.cachet.activity_recognition_flutter.ActivityRecognizedBroadcastReceiver"/>
<service
   android:name="dk.cachet.activity_recognition_flutter.ActivityRecognizedService"
   android:permission="android.permission.BIND_JOB_SERVICE"
   android:exported="true"/>
<service android:name="dk.cachet.activity_recognition_flutter.ForegroundService" />
```

#### Known Android quirks

If you update from Android SDK <=28 to >=29 remember to run `flutter clean`. See e.g. [this post](https://stackoverflow.com/questions/55407939/permission-requests-are-not-propagated-when-launching-with-flutter-but-are-when/57072913) on stack overflow.

This package uses the Android Embedding API v2. In order to use this in pre-Flutter 1.12 projects, you need to follow [this guide](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects).


### iOS 

An iOS app linked on or after iOS 10.0 must include usage description keys in its `Info.plist` file for the types of data it needs. Failure to include these keys will cause the app to crash.
To access motion and fitness data specifically, it must include `NSMotionUsageDescription`, like this:

```xml
<key>NSMotionUsageDescription</key>
<string>Detects human activity</string>
```

## Usage

To use this plugin, you need to also use the [permission_handler](https://pub.dev/packages/permission_handler) plugin, or some other way of requesting permission. See the example app. 

> **NOTE:** You should NOT use the permission handler plugin for requesting activity recognition on iOS, since it is not needed and will make your iOS app crash.

## Data types

Each detected activity will have an activity type, which is one of the following:

* IN_VEHICLE
* ON_BICYCLE
* ON_FOOT
* RUNNING
* STILL
* TILTING
* UNKNOWN
* WALKING
* INVALID (used for parsing errors)

As well as a confidence expressed in percentages (i.e. a value from 0-100).

