# CARP Background Location Plugin

A background location plugin for Android and iOS which works even when the app is in the background.

The plugin will not necessarily work if the app has been terminated.

## Android setup

Add the following permissions to your manifest:

```xml
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

Afterwards, include the following entries within the application tag, as follows:

```xml
<application
       ...
        <!-- Don't delete the meta-data below.
         This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <receiver
                android:name="rekab.app.background_locator.LocatorBroadcastReceiver"
                android:enabled="true"
                android:exported="true"
        />

        <receiver android:name="rekab.app.background_locator.BootBroadcastReceiver"
                  android:enabled="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
            </intent-filter>
        </receiver>

        <service
                android:name="rekab.app.background_locator.LocatorService"
                android:permission="android.permission.BIND_JOB_SERVICE"
                android:exported="true"
        />
        <service
                android:name="rekab.app.background_locator.IsolateHolderService"
                android:permission="android.permission.FOREGROUND_SERVICE"
                android:exported="true"
        />
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
```

## iOS setup

Add the following entries to your Info.plist file

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to location when open and in the background.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location when in the background.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
<key>UIBackgroundModes</key>
<array>
	<string>location</string>
</array>
```

Next, overwrite your AppDelegate.swift in the XCode project with:

```swift
import UIKit
import Flutter

import background_locator

func registerPlugins(registry: FlutterPluginRegistry) -> () {
    if (!registry.hasPlugin("BackgroundLocatorPlugin")) {
        GeneratedPluginRegistrant.register(with: registry)
    }
}


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    BackgroundLocatorPlugin.setPluginRegistrantCallback(registerPlugins)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Usage

```dart
  LocationManager locationManager = LocationManager.instance;
  Stream<LocationDto> dtoStream;
  StreamSubscription<LocationDto> dtoSubscription;
 
  @override
  void initState() {
    super.initState();
    // Subscribe to stream in case it is already running
    locationManager.interval = 1;
    locationManager.distanceFilter = 0;
    locationManager.notificationTitle = 'CARP Location Example';
    locationManager.notificationMsg = 'CARP is tracking your location';
    dtoStream = locationManager.dtoStream;
    dtoSubscription = dtoStream.listen(onData);
  }

  void start() async {
    // Subscribe if it hasnt been done already
    if (dtoSubscription != null) {
      dtoSubscription.cancel();
    }
    dtoSubscription = dtoStream.listen(onData);
    await locationManager.start();
    setState(() {
      _status = LocationStatus.RUNNING;
    });
  }

  void stop() async {
    setState(() {
      _status = LocationStatus.STOPPED;
    });
    dtoSubscription.cancel();
    await locationManager.stop();
  }
```

See the example app on Github for a complete example of usage.

## Features and bugs

Please file feature requests and bug reports at the [issue tracker][tracker].

[tracker]: https://github.com/cph-cachet/flutter-plugins/issues

## License

This software is copyright (c) [Copenhagen Center for Health Technology (CACHET)](https://www.cachet.dk/) 
at the [Technical University of Denmark (DTU)](https://www.dtu.dk).
This software is available 'as-is' under a [MIT license](https://github.com/cph-cachet/flutter-plugins/blob/master/packages/carp_background_location/LICENSE).


