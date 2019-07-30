# eSense

This plugin supports the [eSense](http://www.esense.io) earable computing platform.
At the time of writing, there is no support for eSense on __iOS__. 
Will be added to this plugin once released from Nokia Research.


[![pub package](https://img.shields.io/pub/v/esense.svg)](https://pub.dartlang.org/packages/esense)

## Install (Flutter)
Add ```esense``` as a dependency in  `pubspec.yaml`.
For help on adding as a dependency, view the [pubspec documenation](https://flutter.io/using-packages/).

## AndroidX support
**Only for Android API level 28**

Update the contents of the `android/gradle.properties` file with the following:
```
android.enableJetifier=true
android.useAndroidX=true
org.gradle.jvmargs=-Xmx1536M
```

Next, add the following dependencies to your `android/build.gradle` file:
```
dependencies {
  classpath 'com.android.tools.build:gradle:3.3.0'
  classpath 'com.google.gms:google-services:4.2.0'
} 
```

And finally, set the Android compile- and minimum SDK versions to `compileSdkVersion 28`, 
and `minSdkVersion 23` respectively, inside the `android/app/build.gradle` file.

## Permissions
The package uses your location and bluetooth to fetch data from the eSense ear plugs.
Therefore location tracking and bluetooth must be enabled.


### Android
Add the following entry to your `manifest.xml` file, in the Android project of your application:

```xml
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-feature android:name="android.hardware.bluetooth_le" android:required="true"/>
```

In addition, your __minimum SDK version__ should be __23__.


## Usage
First and foremost you need an API key from OpenWeatherMap, which can be acquired for free [here](https://openweathermap.org/price).

```dart
import 'package:weather/weather.dart';

...

WeatherStation weatherStation = new WeatherStation("YOUR_API_KEY");
```
### Query current weather
For specific documentation on the current weather API, see the [OpenWeatherMap weather API docs](https://openweathermap.org/current).

```dart
Weather weather = await weatherStation.currentWeather();
```
For a complete list of all the properties of the [Weather](https://pub.dartlang.org/documentation/weather/latest/weather/Weather-class.html) class, check the [documentation](https://pub.dartlang.org/documentation/weather/latest/weather/Weather-class.html)

#### Get temperature
The [Temperature](https://pub.dartlang.org/documentation/weather/latest/weather/Temperature-class.html) class holds a temperature and can output the temperature in Celsius, Fahrenheit, and Kelvin:
```dart
double celsius = weather.temperature.celsius;
double fahrenheit = weather.temperature.celsius;
double kelvin = weather.temperature.kelvin;
```

### Query 5 day forecast
For API documentation on the forecast API, see the [OpenWeatherMap forecast API docs](https://openweathermap.org/forecast5).

```dart
List<Weather> forecasts = await weatherStation.getFiveDayForecast();
```






## Getting Started with Flutter

For help getting started with Flutter, view the 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
