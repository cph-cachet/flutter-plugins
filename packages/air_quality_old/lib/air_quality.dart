library air_quality;

/*
 * Copyright 2019 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Custom Exception for the plugin,
/// Thrown whenever the API responds with an error and body could not be parsed.
class AirQualityAPIException implements Exception {
  String _cause;

  AirQualityAPIException(this._cause);

  String toString() => '${this.runtimeType} - $_cause';
}

enum AirQualityLevel {
  GOOD,
  MODERATE,
  UNHEALTHY_FOR_SENSITIVE_GROUPS,
  UNHEALTHY,
  VERY_UNHEALTHY,
  HAZARDOUS
}

AirQualityLevel airQualityIndexToLevel(int index) {
  if (index < 0)
    throw AirQualityAPIException('Index value cannot be negative!');
  else if (index <= 50)
    return AirQualityLevel.GOOD;
  else if (index <= 100)
    return AirQualityLevel.MODERATE;
  else if (index <= 150)
    return AirQualityLevel.UNHEALTHY_FOR_SENSITIVE_GROUPS;
  else if (index <= 200)
    return AirQualityLevel.UNHEALTHY;
  else if (index <= 300)
    return AirQualityLevel.VERY_UNHEALTHY;
  else
    return AirQualityLevel.HAZARDOUS;
}

/// A class for storing Air Quality JSON Data fetched from the API.
class AirQualityData {
  String _airQualityIndex, _source, _place, _latitude, _longitude;
  AirQualityLevel _airQualityLevel;

  AirQualityData(Map<String, dynamic> airQualityJson) {
    _airQualityIndex = airQualityJson['data']['aqi'].toString();
    _place = airQualityJson['data']['city']['name'].toString();
    _source = airQualityJson['data']['attributions'][0]['name'].toString();
    _latitude = airQualityJson['data']['city']['geo'][0].toString();
    _longitude = airQualityJson['data']['city']['geo'][1].toString();
    _airQualityLevel = airQualityIndexToLevel(int.parse(_airQualityIndex));
  }

  get airQualityIndex => _airQualityIndex;

  get place => _place;

  get source => _source;

  get latitude => _latitude;

  get longitude => _longitude;

  get airQualityLevel => _airQualityLevel;

  String toString() {
    return '''
    Air Quality Level: ${_airQualityLevel.toString().split('.').last}
    AQI: $_airQualityIndex
    Place Name: $_place
    Source: $_source
    Location: ($_latitude, $_longitude)
    ''';
  }
}

/// Plugin for fetching weather data in JSON.
class AirQuality {
  String _token;
  String _endpoint = 'https://api.waqi.info/feed/';

  AirQuality(this._token);

  /// Returns an [AirQualityData] object given a city name or a weather station ID
  Future<AirQualityData> feedFromCity(String city) async =>
      await _airQualityFromUrl(city);

  /// Returns an [AirQualityData] object given a city name or a weather station ID
  Future<AirQualityData> feedFromStationId(String stationId) async =>
      await _airQualityFromUrl('@$stationId');

  /// Returns an [AirQualityData] object given a latitude and longitude.
  Future<AirQualityData> feedFromGeoLocation(String lat, String lon) async =>
      await _airQualityFromUrl('geo:$lat;$lon');

  /// Returns an [AirQualityData] object given using the IP address.
  Future<AirQualityData> feedFromIP() async => await _airQualityFromUrl('here');

  /// Send API request given a URL
  Future<Map<String, dynamic>> _requestAirQualityFromURL(String keyword) async {
    /// Make url using the keyword
    String url = '$_endpoint/$keyword/?token=$_token';

    /// Send HTTP get response with the url
    http.Response response = await http.get(url);

    /// Perform error checking on response:
    /// Status code 200 means everything went well
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonBody = json.decode(response.body);
      return jsonBody;
    }
    throw AirQualityAPIException("OpenWeather API Exception: ${response.body}");
  }

  /// Fetch current weather based on geographical coordinates
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/current
  Future<AirQualityData> _airQualityFromUrl(String url) async {
    try {
      Map<String, dynamic> airQualityJson =
      await _requestAirQualityFromURL(url);
      return AirQualityData(airQualityJson);
    } catch (exception) {
      print(exception);
    }
    return null;
  }
}
