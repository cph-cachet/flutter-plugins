# activity_recognition_flutter

[![pub package](https://img.shields.io/pub/v/activity_recognition_flutter.svg)](https://pub.dartlang.org/packages/activity_recognition)

## Important
This package uses the Android Embedding API v2. In order to use this in pre-Flutter 1.12 projects, you need to follow this guide: https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects
Activity recognition plugin for Android and iOS. Only working while App is running (= not terminated by the user or OS).

## Getting Started

Check out the `example` directory for a sample app using activity recognition.

### Android Permissions

Add permission to your Android Manifest, for Android 10 (API 29 and later), use:
```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION permission" />
```

For Android 9 (API 28 and earlier), use:
```xml
<uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION" />
```

Next, add the plugin's service inside the `<application>` tags:
```xml
<service android:name="dk.cachet.activity_recognition_flutter.activity.ActivityRecognizedService" />
```

### iOS Permissions

An iOS app linked on or after iOS 10.0 must include usage description keys in its *Info.plist* file
for the types of data it needs. Failure to include these keys will cause the app to crash.
To access motion and fitness data specifically, it must include `NSMotionUsageDescription`.

### Flutter Usage

```Dart
import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
Stream<Activity> stream;

@override
void initState() {
    super.initState();
    
    /// Start the stream updates
    stream = ActivityRecognition.activityUpdates();
    stream.listen(onData);
}

void onData(Activity activity) {
    /// Do something with the activity
    ActivityType type = activity.type;
    int confidence = activity.confidence;
}
```

## Data types
### iOS
* `Stationary`
* `Walking`
* `Running`
* `Automotive`
* `Cycling`
* `Unknown`

### Android
* `IN_VEHICLE`
* `ON_BICYCLE`
* `ON_FOOT`
* `RUNNING`
* `STILL`
* `TILTING`
* `UNKNOWN`
* `WALKING`