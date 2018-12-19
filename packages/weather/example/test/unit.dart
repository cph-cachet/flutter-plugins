import 'package:test/test.dart';
import 'package:weather/weather.dart';
import 'json_examples.dart';

void main() {
  test('Simple Weather object test', () {
    Weather wr = new Weather(weatherJsonExample());
    print(wr.toString());
  });

}
