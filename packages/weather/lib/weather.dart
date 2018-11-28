import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class WeatherResult {
  String _country, _placeName, _weatherMain, _weatherDescription;
  DateTime _sunrise, _sunset;
  double _latitude,
      _longitude,
      _temperature,
      _humidity,
      _pressure,
      _tempMin,
      _tempMax,
      _windSpeed,
      _windDegree;

  WeatherResult(Map<String, dynamic> weatherData) {
    _latitude = weatherData['coord']['lat'];
    _longitude = weatherData['coord']['lon'];

    _country = weatherData['country'];
    _placeName = weatherData[''];
    _weatherMain = weatherData[''];
    _weatherDescription = weatherData[''];
    _sunrise = weatherData['sunrise'];
    _sunset = weatherData['sunset'];
    _humidity = weatherData[''];
    _pressure = weatherData[''];
    _tempMin = weatherData[''];
    _tempMax = weatherData[''];
    _windSpeed = weatherData[''];
    _windDegree = weatherData[''];
  };
}

/// Plugin for fetching weather data in JSON.
class Weather {
  String _apiKey;
  http.Client client = new http.Client();
  static const String FORECAST = 'forecast';
  static const String WEATHER = 'weather';

  Weather(this._apiKey);

  /// Fetch current weather based on geographical coordinates
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/current
  Future<Map<String, dynamic>> getCurrentWeather() async {
    String url = await _generateUrl(tag: WEATHER);
    http.Response response = await client.get(url);
    Map<String, dynamic> currentWeather = json.decode(response.body);
    print(currentWeather);
    return currentWeather;
  }

  /// Fetch current weather based on geographical coordinates.
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/forecast5
  Future<Map<String, dynamic>> getFiveDayForecast() async {
    String url = await _generateUrl(tag: FORECAST);
    http.Response response = await client.get(url);
    Map<String, dynamic> weatherForecast = json.decode(response.body);
    print(weatherForecast);
    return weatherForecast;
  }

  /// Generate the URL for the API, containing the API key,
  /// as well as latitude and longitude.
  Future<String> _generateUrl({String tag}) async {
    Map<String, double> loc = await new Location().getLocation();
    double lat = loc['latitude'];
    double lon = loc['longitude'];
    return 'http://api.openweathermap.org/data/2.5/' +
        '$tag?lat=$lat&lon=$lon&appid=$_apiKey';
  }
}
