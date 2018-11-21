# weather

[![pub package](https://img.shields.io/pub/v/weather.svg)](https://pub.dartlang.org/packages/weather)

## Install
Add ```weather``` as a dependency in  `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

## Usage
First and foremost you need an API key from OpenWeatherMap, which can be acquired for free [here](https://openweathermap.org/price).

```dart
String key = 'YOUR_API KEY';
Weather weather = new Weather(key);
```
### Query current weather
For api documentation on the current weather API, see the [documentation](https://openweathermap.org/current).

```dart
String forecastJSON = await weather.getFiveDayForecast();
```

### Query 5 day forecast
For api documentation on the forecast API, see the [documentation](https://openweathermap.org/forecast5).

```dart
String weatherJSON = await weather.getCurrentWeather();
```