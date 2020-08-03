## 2.0.0
* Re-implemented the plugin for both Android and iOS
* This should solve many build problems which persisted on Android
* Added Pedestrian Status events and the ability to stream these
* Added a class for the already-existing step count event

## 1.2.5
* Android 10 and above requires the Activity Recognition permission, this has been added to the docs.

## 1.2.0
* The plugin now returns the steps taken since last boot up.

## 1.1.0
* The Pedometer stream now returns the value since the plugin was started on both platforms. 
* Previously this was only the case on iOS, and Android returned the steps taken since last phone boot-up.