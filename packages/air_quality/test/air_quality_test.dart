import 'package:flutter_test/flutter_test.dart';
import 'package:air_quality/air_quality.dart';

void main() {
  String key = '9e538456b2b85c92647d8b65090e29f957638c77';
  AirQuality airQuality = new AirQuality(key);

  group('Air Quality Tests', () {
    setUpAll(() {});
    setUp(() {});

    test('- via city name (Munich)', () async {
      AirQualityData feedFromCity = await airQuality.feedFromCity('munich');
      print(feedFromCity);
    });

    test('- via station ID (Gothenburg weather station)', () async {
      AirQualityData feedFromStationId = await airQuality.feedFromStationId('7867');
      print(feedFromStationId);
    });

    test('- via geo-location (Berlin)', () async {
      AirQualityData feedFromGeoLocation = await airQuality.feedFromGeoLocation('52.6794', '12.5346');
      print(feedFromGeoLocation);
    });

    test('- via  IP (depends on service provider)', () async {
      AirQualityData fromIP = await airQuality.feedFromIP();
      print(fromIP);
    });
  });
}
