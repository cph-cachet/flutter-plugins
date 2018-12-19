import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

/// A class for holding a temperature.
/// Can output temperature as Kelvin, Celsius or Fahrenheit.
/// All results are returned as [double].
class Temperature {
  double _kelvin;

  Temperature(this._kelvin);

  /// Convert temperature to Kelvin
  double get kelvin => _kelvin;

  /// Convert temperature to Celsius
  double get celsius => _kelvin - 273.15;

  /// Convert temperature to Fahrenheit
  double get fahrenheit => _kelvin * (9 / 5) - 459.67;

  @override
  String toString() {
    return '${celsius.toStringAsFixed(1)} Celsius';
  }
}

/// Safely unpack a double value from a [Map] object.
double _unpackDouble(Map<String, dynamic> M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      return M[k] + 0.0;
    }
  }
  return 0.0;
}

/// Safely unpack a string value from a [Map] object.
String _unpackString(Map<String, dynamic> M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      return M[k];
    }
  }
  return "";
}

/// Safely unpacks a unix timestamp from a [Map] object,
/// i.e. an integer value of milliseconds and converts this to a [DateTime] object.
DateTime _unpackDate(Map<String, dynamic> M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      int millis = M[k] * 1000;
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }
  return null;
}

/// Unpacks a [double] value from a [Map] object and converts this to
/// a [Temperature] object.
Temperature _unpackTemperature(Map<String, dynamic> M, String k) {
  double kelvin = _unpackDouble(M, k);
  return Temperature(kelvin);
}

/// A class for storing a weather-query response from OpenWeatherMap.
/// This includes various measures such as location,
/// temperature, wind, snow, rain and humidity.
class Weather {
  String _country, _areaName, _weatherMain, _weatherDescription, _weatherIcon;
  Temperature _temperature, _tempMin, _tempMax;
  DateTime _date, _sunrise, _sunset;
  double _latitude,
      _longitude,
      _pressure,
      _windSpeed,
      _windDegree,
      _humidity,
      _cloudiness,
      _rainLastHour,
      _rainLast3Hours,
      _snowLastHour,
      _snowLast3Hours;

  Weather(Map<String, dynamic> weatherData) {
    Map<String, dynamic> main = weatherData['main'];
    Map<String, dynamic> coord = weatherData['coord'];
    Map<String, dynamic> sys = weatherData['sys'];
    Map<String, dynamic> wind = weatherData['wind'];
    Map<String, dynamic> clouds = weatherData['clouds'];
    Map<String, dynamic> rain = weatherData['rain'];
    Map<String, dynamic> snow = weatherData['snow'];
    Map<String, dynamic> weather = weatherData['weather'][0];

    _latitude = _unpackDouble(coord, 'lat');
    _longitude = _unpackDouble(coord, 'lon');

    _country = _unpackString(sys, 'country');
    _sunrise = _unpackDate(sys, 'sunrise');
    _sunset = _unpackDate(sys, 'sunset');

    _weatherMain = _unpackString(weather, 'main');
    _weatherDescription = _unpackString(weather, 'description');
    _weatherIcon = _unpackString(weather, 'icon');

    _temperature = _unpackTemperature(main, 'temp');
    _tempMin = _unpackTemperature(main, 'temp_min');
    _tempMax = _unpackTemperature(main, 'temp_max');
    _humidity = _unpackDouble(main, 'humidity');
    _pressure = _unpackDouble(main, 'pressure');

    _windSpeed = _unpackDouble(wind, 'speed');
    _windDegree = _unpackDouble(wind, 'deg');

    _cloudiness = _unpackDouble(clouds, 'all');

    _rainLastHour = _unpackDouble(rain, '1h');
    _rainLast3Hours = _unpackDouble(rain, '3h');

    _snowLastHour = _unpackDouble(snow, '1h');
    _snowLast3Hours = _unpackDouble(snow, '3h');

    _areaName = _unpackString(weatherData, 'name');
    _date = _unpackDate(weatherData, 'dt');
  }

  String toString() {
    return '''
    Place Name: $_areaName ($_country)
    Date: $_date
    Weather: $_weatherMain, $_weatherDescription
    Temp: $_temperature, Temp (min): $_tempMin, Temp (max): $_tempMax
    Sunrise: $_sunrise, Sunset: $_sunset
    ''';
  }

  /// A long description of the weather
  String get weatherDescription => _weatherDescription;

  /// A brief description of the weather
  String get weatherMain => _weatherMain;

  /// A brief description of the weather
  String get weatherIcon => _weatherIcon;

  /// The level of cloudiness in Okta (0-9 scale)
  double get cloudiness => _cloudiness;

  /// Wind direction in degrees
  double get windDegree => _windDegree;

  /// Wind speed in m/s
  double get windSpeed => _windSpeed;

  /// Max [Temperature]. Available as Kelvin, Celsius and Fahrenheit.
  Temperature get tempMax => _tempMax;

  /// Min [Temperature]. Available as Kelvin, Celsius and Fahrenheit.
  Temperature get tempMin => _tempMin;

  /// Mean [Temperature]. Available as Kelvin, Celsius and Fahrenheit.
  Temperature get temperature => _temperature;

  /// Pressure in Pascal
  double get pressure => _pressure;

  /// Humidity in percent
  double get humidity => _humidity;

  /// Longitude of the weather observation
  double get longitude => _longitude;

  /// Latitude of the weather observation
  double get latitude => _latitude;

  /// Date of the weather observation
  DateTime get date => _date;

  /// Timestamp of sunset
  DateTime get sunset => _sunset;

  /// Timestamp of sunrise
  DateTime get sunrise => _sunrise;

  /// Name of the area, ex Mountain View, or Copenhagen Municipality
  String get areaName => _areaName;

  /// Country code, ex US or DK
  String get country => _country;

  /// Rain fall last hour measured in volume
  double get rainLastHour => _rainLastHour;

  /// Rain fall last 3 hours measured in volume
  double get rainLast3Hours => _rainLast3Hours;

  /// Rain fall last 3 hours measured in volume
  double get snowLastHour => _snowLastHour;

  /// Rain fall last 3 hours measured in volume
  double get snowLast3Hours => _snowLast3Hours;
}

/// Plugin for fetching weather data in JSON.
class WeatherStation {
  String _apiKey;
  http.Client client = new http.Client();
  static const String FORECAST = 'forecast';
  static const String WEATHER = 'weather';

  WeatherStation(this._apiKey);

  /// Fetch current weather based on geographical coordinates
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/current
  Future<Weather> currentWeather() async {
    String url = await _generateUrl(tag: WEATHER);
    http.Response response = await client.get(url);
    Map<String, dynamic> currentWeather = json.decode(response.body);
    return new Weather(currentWeather);
  }

  /// Fetch current weather based on geographical coordinates.
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/forecast5
  Future<List<Weather>> fiveDayForecast() async {
    String url = await _generateUrl(tag: FORECAST);
    http.Response response = await client.get(url);
    Map<String, dynamic> jsonForecasts = json.decode(response.body);
    List<dynamic> forecastsJson = jsonForecasts['list'];
    List<Weather> forecasts =
    forecastsJson.map((w) => new Weather(w)).toList();
    return forecasts;
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
