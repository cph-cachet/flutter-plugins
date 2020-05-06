import 'package:weather/weather_library.dart';
import 'json_examples.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('Weather Tests', () {
    setUpAll(() {});
    setUp(() {});

    test('- Fetch weather via lat and lon', () async {
      double lat = 55.0111;
      double lon = 15.0569;
      String key = '856822fd8e22db5e1ba48c0e7d69844a';
      WeatherStation weatherStation = WeatherStation(key);
      Weather w = await weatherStation.currentWeather(lat, lon);
      print(w);
    });

    test('- Construct from From JSON', () {
      Weather w = new Weather(weatherJsonExample());
      print(w.toString());
    });
  });

}
