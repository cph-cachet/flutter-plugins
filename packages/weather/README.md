# weather

[![pub package](https://img.shields.io/pub/v/weather.svg)](https://pub.dartlang.org/packages/weather)

## Install
Add ```weather``` as a dependency in  `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

## Usage
First and foremost you need an API key from OpenWeatherMap, which can be acquired for free [here](https://openweathermap.org/price).

### Query current weather
For api doucmentation on the current weather API, see the [documentation](https://openweathermap.org/current).
```dart
String key = 'YOUR_API KEY';
Weather w = new Weather(key);
String res = await w.getFiveDayForecast();
setState(() {
  _res = res;
});
```

### Query 5 day forecast
For api doucmentation on the forecast API, see the [documentation](https://openweathermap.org/forecast5).
```dart
String key = 'YOUR_API KEY';
Weather w = new Weather(key);
String res = await w.getCurrentWeather();
setState(() {
  _res = res;
});
```