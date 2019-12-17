library air_quality;

/*
 * Copyright 2019 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';
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

/// A class for storing a weather-query response from OpenWeatherMap.
/// This includes various measures such as location,
/// temperature, wind, snow, rain and humidity.
class AirQualityData {
  String _airQualityIndex, _source, _place, _lat, _lon;
  AirQualityLevel _airQualityLevel;

  AirQualityData(Map<String, dynamic> airQualityJson) {
    _airQualityIndex = airQualityJson['data']['aqi'].toString();
    _place = airQualityJson['data']['city']['name'].toString();
    _source =
        airQualityJson['data']['attributions'][0]['name'].toString();
    _lat = airQualityJson['data']['city']['geo'][0].toString();
    _lon = airQualityJson['data']['city']['geo'][1].toString();
    _airQualityLevel = airQualityIndexToLevel(int.parse(_airQualityIndex));
  }

  String toString() {
    return '''
    Air Quality Level: ${_airQualityLevel.toString().split('.').last}
    AQI: $_airQualityIndex
    Place Name: $_place
    Source: $_source
    Location: ($_lat, $_lon)
    ''';
  }
}

/// Plugin for fetching weather data in JSON.
class AirQuality {
  String _apiKey;
  Location location;

  AirQuality(this._apiKey);

  /// Fetch current weather based on geographical coordinates
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/current
  Future<AirQualityData> currentAirQuality(String city) async {
    try {
      Map<String, dynamic> airQualityJson = await _requestOpenWeatherAPI(city);
      return AirQualityData(airQualityJson);
    } catch (exception) {
      print(exception);
    }
    return null;
  }

  /// Requests permission for the location
  Future<bool> manageLocationPermission() async {
    location = new Location();
    bool hasPermission = await location.hasPermission();
    if (hasPermission) {
      return true;
    } else {
      bool permissionWasGranted = await location.requestPermission();
      return permissionWasGranted;
    }
  }

  Future<Map<String, dynamic>> _requestOpenWeatherAPI(String city) async {
    /// Build HTTP get url by passing the required parameters
    String url =
        'https://api.waqi.info/feed/' + '$city' + '/?token=' + '$_apiKey';
    print(url);

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
}
