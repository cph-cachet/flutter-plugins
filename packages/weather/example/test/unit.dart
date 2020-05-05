import 'package:weather/weather.dart';
import 'json_examples.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Simple Weather object test', () {
    Weather wr = new Weather(weatherJsonExample());
    print(wr.toString());
  });

  test('Custom location test', () async {
    double lat = 55.0111;
    double lon = 15.0569;
    WeatherStation weatherStation = WeatherStation('856822fd8e22db5e1ba48c0e7d69844a');
    Weather w = await weatherStation.currentWeather(lat: lat, lon: lon);
    print(w);
  });

}
