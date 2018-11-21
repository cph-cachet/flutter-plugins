import 'dart:async';
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
  Future<String> getCurrentWeather() async {
    String url = await generateUrl(tag: WEATHER);
    http.Response response = await client.get(url);
    return response.body;
  }

  /// Fetch current weather based on geographical coordinates.
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/forecast5
  Future<String> getFiveDayForecast() async {
    String url = await generateUrl(tag: FORECAST);
    http.Response response = await client.get(url);
    return response.body;
  }

  /// Generate the URL for the API, containing the API key,
  /// as well as latitude and longitude.
  Future<String> generateUrl({String tag}) async {
    Map<String, double> loc = await new Location().getLocation();
    double lat = loc['latitude'];
    double lon = loc['longitude'];
    return
        'http://api.openweathermap.org/data/2.5/' +
        '$tag?lat=$lat&lon=$lon&appid=$_apiKey';
  }
}
