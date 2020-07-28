import 'package:weather/weather.dart';
import 'json_examples.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('Weather Tests', () {
    setUpAll(() {});
    setUp(() {});

    double lat = 55.0111;
    double lon = 15.0569;
    String key = '856822fd8e22db5e1ba48c0e7d69844a';
    String cityName = 'Kongens Lyngby';
    WeatherFactory wf = WeatherFactory(key);

    test('- Fetch weather via lat and lon', () async {
      Weather w = await wf.currentWeatherByLocation(lat, lon);
      print('Weather by Location:');
      print(w);
      print('-' * 50);
    });

    test('- Fetch weather via city name', () async {
      Weather w = await wf.currentWeatherByCityName(cityName);
      print('Weather by city name:');
      print(w);
      print('-' * 50);
    });

    test('- Fetch forecast via lat and lon', () async {
      print('Forecast by city name:');
      List<Weather> forecast = await wf.fiveDayForecastByLocation(lat, lon);
      for (var w in forecast) print(w);
      print('-' * 50);
    });

    test('- Fetch forecast via city name', () async {
      print('Forecast by city name:');
      List<Weather> forecast = await wf.fiveDayForecastByCityName(cityName);
      for (var w in forecast) print(w);
      print('-' * 50);
    });

    test('- Fetch forecast via city name, Danish', () async {
      print('Forecast by city name:');
      wf = WeatherFactory(key, language: Language.DANISH);
      List<Weather> forecast = await wf.fiveDayForecastByCityName(cityName);
      for (var w in forecast) print(w);
      print('-' * 50);
    });

    test('- Fetch current weather via location, Danish', () async {
      print('Forecast by city name:');
      wf = WeatherFactory(key, language: Language.DANISH);
      Weather weather = await wf.currentWeatherByLocation(lat, lon);
      print(weather);
      print('-' * 50);
    });
  });
}
