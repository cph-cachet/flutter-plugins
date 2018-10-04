# pedometer

This plugin allows for conitnuous step count using the built-in pedometer sensor API's of iOS and Android devices.

## Usage

To use this plugin, add `flutter_pedometer` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Example

``` dart
import 'dart:async';
import 'package:flutter_pedometer/flutter_pedometer.dart';

class someClass {
    StreamSubscription<int> _subscription;
    FlutterPedometer pedometer;
    
    void someFunction() async {
        // ...
        pedometer = new FlutterPedometer();
        _subscription = pedometer.stepCountStream.listen(_onData,
            onError: _onError, onDone: _onDone, cancelOnError: true);
    }
    
    void _onData(int stepCountValue) async {
        // Do something with the stepCountValue
    }
    
    void _onDone() {
        // Do something when done collecting
    }
    
    void _onError(error) {
        // Handle the error
    }

}
        
```
## Configuring XCode for usage on iOS

It seems that users of this plug-in will have to manually open XCode and configure a few settings manually, mostly pertaining to privacy settings and permissions due to the application collecting the user's movement data.

For usage on Android it seems there are no problems with permissions.

## Flutter Errors
```shell
Could not build the precompiled application for the device.
    ** BUILD FAILED **
    
Xcode's output:
↳
    === BUILD TARGET Runner OF PROJECT Runner WITH CONFIGURATION Debug ===
    The use of Swift 3 @objc inference in Swift 4 mode is deprecated. Please address deprecated @objc inference warnings, test your code with “Use of deprecated Swift 3 @objc inference” logging enabled, and then disable inference by changing the "Swift 3 @objc Inference" build setting to "Default" for the "Runner" target.
    The use of Swift 3 @objc inference in Swift 4 mode is deprecated. Please address deprecated @objc inference warnings, test your code with “Use of deprecated Swift 3 @objc inference” logging enabled, and then disable inference by changing the "Swift 3 @objc Inference" build setting to "Default" for the "Runner" target.
    === BUILD TARGET Runner OF PROJECT Runner WITH CONFIGURATION Debug ===
    fatal error: lipo: -extract armv7 specified but fat file: /Users/thomasnilsson/Desktop/testingoutmyplugin/build/ios/Debug-iphoneos/Runner.app/Frameworks/location.framework/location does not contain that architecture
    Failed to extract armv7 for /Users/thomasnilsson/Desktop/testingoutmyplugin/build/ios/Debug-iphoneos/Runner.app/Frameworks/location.framework/location. Running lipo -info:
    Architectures in the fat file: /Users/thomasnilsson/Desktop/testingoutmyplugin/build/ios/Debug-iphoneos/Runner.app/Frameworks/location.framework/location are: arm64 

Error launching application on Thomas’s iPhone.
```

### Fix: Enable @objc inference
![7jcq5](https://user-images.githubusercontent.com/9467047/43827445-21326694-9afa-11e8-8e0c-60e829eb4c79.png)

## Errors only visible when running through XCode
![screen shot 2018-08-07 at 16 04 31](https://user-images.githubusercontent.com/9467047/43827142-6e0b8f00-9af9-11e8-80b6-f01b5db33713.png)

### Fix: Configure plist and capabilities
#### Step 1: Open XCode
Open the XCode project located at `<your_project>/iOS/Runner.xcodeproj`

#### Step 2: Set Capabilities
![screen shot 2018-08-08 at 10 09 11](https://user-images.githubusercontent.com/9467047/43827207-902101f6-9af9-11e8-8341-d399ece490f6.png)

#### Step 3: Configure your plist
![screen shot 2018-08-08 at 11 07 21](https://user-images.githubusercontent.com/9467047/43827874-3bd9a970-9afb-11e8-80bb-c9ec25b026c3.png)

