# flutter_foreground_service 

# Setup
## Step 1
Add the plugin to your pubspec.yaml file:

````yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_foreground_service: ^LATEST_VERSION_HERE
````

Replace the `LATEST_VERSION_HERE` the latest version number as stated on this page.

## Step 2
Import the package into your project

```dart
import 'package:flutter_foreground_service/foreground_service.dart';
```

# Usage
Check out the `example` tab here on pub.dev to view the plugin in action.

In essence, the following line of code will start the foreground service:

````dart
await ForegroundService().start();
````

To stop the service again, use the following line of code:

````dart
await ForegroundService().stop();
````
