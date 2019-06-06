# movisens_flutter_plugin
[![pub package](https://img.shields.io/pub/v/movisens_flutter.svg)](https://pub.dartlang.org/packages/movisens_flutter)
A plugin for connecting and collecting data from a Movisens sensor. **This plugin excelusively works for Android.**

## Install
Add ```movisens_flutter``` as a dependency in  `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

## Android permissions
Add the following to your manifest

```dart
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## Example Usage
A Movisens object is instantiated by providing a UserData object, which is, in essence a Map structure containing a list of required fields for the Movisens sensor.
These include: Weight, height, age, sensor address and sensor name.


### Intialization:
```dart
Movisens _movisens;
StreamSubscription<MovisensDataPoint> _subscription;
LogManager logManager = new LogManager();
List<MovisensDataPoint> movisensEvents = [];
String address = 'unknown', name = 'unknown';
int weight, height, age;
```


### Start Listening

Data from the sensor is streamed continuously, which is done by calling the `listen()` method on a `Movisens`
object. An exception will be thrown if the listen method is invoked on a platform other than Android.

```dart
void startListening() {
    address = '88:6B:0F:82:1D:33';
    name = 'Sensor 02655';
    weight = 100;
    height = 180;
    age = 25;
    
    UserData userData = new UserData(
        weight, height, Gender.male, age, SensorLocation.chest, address, name);
    
    _movisens = new Movisens(userData);
    
    try {
      _subscription = _movisens.movisensStream.listen(onData);
    } on MovisensException catch (exception) {
      print(exception);
    }
}
```

Additionally, it can be a good idea to have a separate method for handling incoming data, such as the `onData` method shown below:
```dart
void onData(MovisensDataPoint d) {
    setState(() {
      movisensEvents.add(d);
      logManager.writeLog('$d');
    });
}

```

### Stop Listening
The subscription can be cancelled again, by invoking the `cancel` method:

```dart
void stopListening() {
    _subscription.cancel(); 
}
```

![image](https://i.imgur.com/EZuiKm5.png)# movisens_plugin
