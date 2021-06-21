# Flutter Foreground Service 

## Setup

### Step 1
This plugin expects your application icon to be saved as `ic_launcher.png` which is the default name.

If you use the package `flutter_launcher_icons` to generate a new launcher icon, make sure to name the icon `ic_launcher.png`.

### Step 2
Add the plugin to your pubspec.yaml file:

````yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_foreground_service: ^LATEST_VERSION_HERE
````

Replace the `LATEST_VERSION_HERE` the latest version number as stated on this page.

### Step 3
Import the package into your project

```dart
import 'package:flutter_foreground_service/foreground_service.dart';
```

## Usage
Check out the `example` tab here on pub.dev to view the plugin in action.

In essence, the following line of code will start the foreground service:

````dart
await ForegroundService().start();
````

To stop the service again, use the following line of code:

````dart
await ForegroundService().stop();
````
