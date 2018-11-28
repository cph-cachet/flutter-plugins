# weather

[![pub package](https://img.shields.io/pub/v/weather.svg)](https://pub.dartlang.org/packages/weather)

## Install
Add ```weather``` as a dependency in  `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).


## Permissions
The plugin uses your location to fetch weather data, therefore location tracking must be enabled.

### Android
Add the following entry to your `manifest.xml` file, in the Android project of your application:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

In addition, it is recommended to set your minimum SDK version to 21.

### iOS
1. Open the XCode project of your app, named `Runner.xcodeproj`
2. Locate the `info.plist` file in the `Runner` directory.
3. Right click `info.plist` and choose `Open as > Source Code`.
4. Add the following entries inside the `<dict></dict>` tags`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses location to forecast the weather.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app uses location to forecast the weather.</string>
```

## Usage
First and foremost you need an API key from OpenWeatherMap, which can be acquired for free [here](https://openweathermap.org/price).

```dart
String key = 'YOUR_API_KEY';
Weather weather = new Weather(key);
```
### Query current weather
For api documentation on the current weather API, see the [documentation](https://openweathermap.org/current).

```dart
Map<String, dynamic> weatherJSON = await weather.getCurrentWeather();
```

### Query 5 day forecast
For api documentation on the forecast API, see the [documentation](https://openweathermap.org/forecast5).

```dart
Map<String, dynamic> forecastJSON = await weather.getFiveDayForecast();
```