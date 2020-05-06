part of weather_library;

/// Plugin for fetching weather data in JSON.
class WeatherStation {
  String _apiKey;
  static const String FIVE_DAY_FORECAST = 'forecast';
  static const String CURRENT_WEATHER = 'weather';
  static const int STATUS_OK = 200;

  WeatherStation(this._apiKey);

  /// Fetch current weather based on geographical coordinates
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/current
  Future<Weather> currentWeather(double latitude, double longitude) async {
    try {
      Map<String, dynamic> currentWeather =
      await _requestOpenWeatherAPI(CURRENT_WEATHER, latitude, longitude);
      return Weather(currentWeather);
    } catch (exception) {
      print(exception);
    }
    return null;
  }

  /// Fetch current weather based on geographical coordinates.
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/forecast5
  Future<List<Weather>> fiveDayForecast(double lat, double lon) async {
    List<Weather> forecasts = new List<Weather>();
    try {
      Map<String, dynamic> jsonForecasts =
      await _requestOpenWeatherAPI(FIVE_DAY_FORECAST, lat, lon);
      List<dynamic> forecastsJson = jsonForecasts['list'];
      forecasts = forecastsJson.map((w) => Weather(w)).toList();
    } catch (exception) {
      print(exception);
    }
    return forecasts;
  }

  Future<Map<String, dynamic>> _requestOpenWeatherAPI(
      String tag, double lat, double lon) async {
    /// Build HTTP get url by passing the required parameters
    String url = 'http://api.openweathermap.org/data/2.5/' +
        '$tag?' +
        'lat=$lat&' +
        'lon=$lon&' +
        'appid=$_apiKey';

    /// Send HTTP get response with the url
    http.Response response = await http.get(url);

    /// Perform error checking on response:
    /// Status code 200 means everything went well
    if (response.statusCode == STATUS_OK) {
      Map<String, dynamic> jsonBody = json.decode(response.body);
      return jsonBody;
    }

    /// The API key is invalid, the API may be down
    /// or some other unspecified error could occur.
    /// The concrete error should be clear from the HTTP response body.
    else {
      throw OpenWeatherAPIException(
          "The API threw an exception: ${response.body}");
    }
  }
}

