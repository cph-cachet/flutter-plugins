import 'package:weather/weather.dart';
import 'json_examples.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Simple Weather object test', () {
    Weather wr = new Weather(weatherJsonExample());
    print(wr.toString());
  });

}
