part of weather_library;

/// Plugin for fetching weather data in JSON.
class WeatherFactory {
  String _apiKey;
  static const String FIVE_DAY_FORECAST = 'forecast';
  static const String CURRENT_WEATHER = 'weather';
  static const int STATUS_OK = 200;

  WeatherFactory(this._apiKey);

  /// Fetch current weather based on geographical coordinates
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/current
  Future<Weather> currentWeatherByLocation(
      double latitude, double longitude) async {
    try {
      Map<String, dynamic> currentWeather =
          await _sendRequest(CURRENT_WEATHER, lat: latitude, lon: longitude);
      return Weather(currentWeather);
    } catch (exception) {
      print(exception);
    }
    return null;
  }

  /// Fetch current weather based on city name
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/current
  Future<Weather> currentWeatherByCityName(String cityName) async {
    try {
      Map<String, dynamic> currentWeather =
          await _sendRequest(CURRENT_WEATHER, cityName: cityName);
      return Weather(currentWeather);
    } catch (exception) {
      print(exception);
    }
    return null;
  }

  /// Fetch current weather based on geographical coordinates.
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/forecast5
  Future<List<Weather>> fiveDayForecastByLocation(
      double latitude, double longitude) async {
    List<Weather> forecast = new List<Weather>();
    try {
      Map<String, dynamic> jsonForecast =
          await _sendRequest(FIVE_DAY_FORECAST, lat: latitude, lon: longitude);
      forecast = _parseForecast(jsonForecast);
    } catch (exception) {
      print(exception);
    }
    return forecast;
  }

  /// Fetch current weather based on geographical coordinates.
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/forecast5
  Future<List<Weather>> fiveDayForecastByCityName(String cityName) async {
    List<Weather> forecasts = new List<Weather>();
    try {
      Map<String, dynamic> jsonForecast =
          await _sendRequest(FIVE_DAY_FORECAST, cityName: cityName);
      forecasts = _parseForecast(jsonForecast);
    } catch (exception) {
      print(exception);
    }
    return forecasts;
  }

  Future<Map<String, dynamic>> _sendRequest(String tag,
      {double lat, double lon, String cityName}) async {
    /// Build HTTP get url by passing the required parameters
    String url = _buildUrl(tag, cityName, lat, lon);

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

  String _buildUrl(String tag, String cityName, double lat, double lon) {
    String url = 'http://api.openweathermap.org/data/2.5/' + '$tag?';

    if (cityName != null) {
      url += 'q=$cityName&';
    } else {
      url += 'lat=$lat&lon=$lon&';
    }

    url += 'appid=$_apiKey';
    return url;
  }
}
