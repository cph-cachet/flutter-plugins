part of weather_library;

/// Plugin for fetching weather data in JSON.
class WeatherFactory {
  String _apiKey;
  late Language language;
  static const String FIVE_DAY_FORECAST = 'forecast';
  static const String CURRENT_WEATHER = 'weather';
  static const int STATUS_OK = 200;

  late http.Client _httpClient;

  WeatherFactory(this._apiKey, {this.language = Language.ENGLISH}) {
    _httpClient = http.Client();
  }

  /// Fetch current weather based on geographical coordinates
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/current
  Future<Weather> currentWeatherByLocation(double latitude, double longitude) async {
    Map<String, dynamic>? jsonResponse = await _sendRequest(CURRENT_WEATHER, lat: latitude, lon: longitude);
    return Weather(jsonResponse!);
  }

  /// Fetch current weather based on city name
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/current
  Future<Weather> currentWeatherByCityName(String cityName) async {
    Map<String, dynamic>? jsonResponse = await _sendRequest(CURRENT_WEATHER, cityName: cityName);
    return Weather(jsonResponse!);
  }

  /// Fetch current weather based on geographical coordinates.
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/forecast5
  Future<List<Weather>> fiveDayForecastByLocation(double latitude, double longitude) async {
    Map<String, dynamic>? jsonResponse = await _sendRequest(FIVE_DAY_FORECAST, lat: latitude, lon: longitude);
    List<Weather> forecast = _parseForecast(jsonResponse!);
    return forecast;
  }

  /// Fetch current weather based on geographical coordinates.
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/forecast5
  Future<List<Weather>> fiveDayForecastByCityName(String cityName) async {
    Map<String, dynamic>? jsonForecast = await _sendRequest(FIVE_DAY_FORECAST, cityName: cityName);
    List<Weather> forecasts = _parseForecast(jsonForecast!);
    return forecasts;
  }

  Future<Map<String, dynamic>?> _sendRequest(String tag, {double? lat, double? lon, String? cityName}) async {
    /// Build HTTP get url by passing the required parameters
    String url = _buildUrl(tag, cityName, lat, lon);

    /// Send HTTP get response with the url
    http.Response response = await _httpClient.get(Uri.parse(url));

    /// Perform error checking on response:
    /// Status code 200 means everything went well
    if (response.statusCode == STATUS_OK) {
      Map<String, dynamic>? jsonBody = json.decode(response.body);
      return jsonBody;
    }

    /// The API key is invalid, the API may be down
    /// or some other unspecified error could occur.
    /// The concrete error should be clear from the HTTP response body.
    else {
      throw OpenWeatherAPIException("The API threw an exception: ${response.body}");
    }
  }

  String _buildUrl(String tag, String? cityName, double? lat, double? lon) {
    String url = 'https://api.openweathermap.org/data/2.5/' + '$tag?';

    if (cityName != null) {
      url += 'q=$cityName&';
    } else {
      url += 'lat=$lat&lon=$lon&';
    }

    url += 'appid=$_apiKey&';
    url += 'lang=${_languageCode[language]}';
    return url;
  }
}
