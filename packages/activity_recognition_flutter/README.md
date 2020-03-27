# activity_recognition_flutter

[![pub package](https://img.shields.io/pub/v/activity_recognition_flutter.svg)](https://pub.dartlang.org/packages/activity_recognition)

Activity recognition plugin for Android and iOS. Only working while App is running (= not terminated by the user or OS).

## Getting Started

Check out the `example` directory for a sample app using activity recognition.

### Android Permissions

Add permission to your Android Manifest:
```xml
<uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION" />
```

Add the plugin service inside the `<application>` tags:
```xml
<service android:name="com.example.activity_recognition_flutter.activity.ActivityRecognizedService" />
```

### iOS Permissions

An iOS app linked on or after iOS 10.0 must include usage description keys in its *Info.plist* file
for the types of data it needs. Failure to include these keys will cause the app to crash.
To access motion and fitness data specifically, it must include `NSMotionUsageDescription`.

### Flutter Usage

```Dart
import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
...
ActivityRecognition.activityUpdates()
```

## Data types
### iOS
| Label      	| Description                                                     	|
|------------	|-----------------------------------------------------------------	|
| stationary 	| A Boolean indicating whether the device is stationary.          	|
| walking    	| A Boolean indicating whether the device is on a walking person. 	|
| running    	| A Boolean indicating whether the device is on a running person. 	|
| automotive 	| A Boolean indicating whether the device is in an automobile.    	|
| cycling    	| A Boolean indicating whether the device is in a bicycle.        	|
| unknown    	| A Boolean indicating whether the type of motion is unknown.     	|

### Android
| Label      	| Description                                                 	|
|------------	|-------------------------------------------------------------	|
| IN_VEHICLE 	| The device is in a vehicle, such as a car.                  	|
| ON_BICYCLE 	| The device is on a bicycle.                                 	|
| ON_FOOT    	| The device is on a user who is walking or running.          	|
| RUNNING    	| The device is on a user who is running.                     	|
| STILL      	| The device is still (not moving).                           	|
| TILTING    	| The device angle relative to gravity changed significantly. 	|
| UNKNOWN    	| Unable to detect the current activity.                      	|
| WALKING    	| The device is on a user who is walking.                     	|