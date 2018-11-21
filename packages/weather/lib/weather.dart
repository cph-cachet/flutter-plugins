import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

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
    return
        'http://api.openweathermap.org/data/2.5/' +
        '$tag?lat=$lat&lon=$lon&appid=$_apiKey';
  }
}
