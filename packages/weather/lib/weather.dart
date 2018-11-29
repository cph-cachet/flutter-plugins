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
      _pressure,
      _tempMin,
      _tempMax,
      _windSpeed,
      _windDegree,
      _humidity,
      _clouds;

  WeatherResult(Map<String, dynamic> weatherData) {
    _latitude = weatherData['coord']['lat'] as double;
    _longitude = weatherData['coord']['lon'] as double;

    _country = weatherData['sys']['country'];
    int sunriseMillis = weatherData['sys']['sunrise'] as int;
    int sunsetMillis = weatherData['sys']['sunset'] as int;
    _sunrise = DateTime.fromMillisecondsSinceEpoch(sunriseMillis);
    _sunset = DateTime.fromMillisecondsSinceEpoch(sunsetMillis);

    _weatherMain = weatherData['weather'][0]['main'];
    _weatherDescription = weatherData['weather'][0]['description'];

    _temperature = weatherData['main']['temp'] + 0.0;
    _tempMin = weatherData['main']['temp_min'] + 0.0;
    _tempMax = weatherData['main']['temp_max'] + 0.0;
    _humidity = weatherData['main']['humidity'] + 0.0;
    _pressure = weatherData['main']['pressure'] + 0.0;

    _windSpeed = weatherData['wind']['speed'] + 0.0;
    _windDegree = weatherData['wind']['deg'] + 0.0;

    _clouds = weatherData['clouds']['all'] + 0.0;

    _placeName = weatherData['name'];
  }

  String toString() {
    return '''
    $_temperature, $_tempMin, $_tempMax
    ''';
  }

  get clouds => _clouds;

  get windDegree => _windDegree;

  get windSpeed => _windSpeed;

  get tempMax => _tempMax;

  get tempMin => _tempMin;

  get pressure => _pressure;

  get humidity => _humidity;

  get temperature => _temperature;

  get longitude => _longitude;

  double get latitude => _latitude;

  get sunset => _sunset;

  DateTime get sunrise => _sunrise;

  get weatherDescription => _weatherDescription;

  get weatherMain => _weatherMain;

  get placeName => _placeName;

  String get country => _country;
}

/// Plugin for fetching weather data in JSON.
class Weather {
  String _apiKey;
  http.Client client = new http.Client();
  static const String FORECAST = 'forecast/daily';
  static const String WEATHER = 'weather';

  Weather(this._apiKey);

  /// Fetch current weather based on geographical coordinates
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/current
  Future<WeatherResult> getCurrentWeather() async {
    String url = await _generateUrl(tag: WEATHER);
    http.Response response = await client.get(url);
    Map<String, dynamic> currentWeather = json.decode(response.body);
    return new WeatherResult(currentWeather);
  }

  /// Fetch current weather based on geographical coordinates.
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/forecast5
  Future<Map<String, dynamic>> getFiveDayForecast() async {
    String url = await _generateUrl(tag: FORECAST);
    http.Response response = await client.get(url);
    Map<String, dynamic> weatherForecast = json.decode(response.body);
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
