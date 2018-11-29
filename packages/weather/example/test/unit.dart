import 'package:test/test.dart';
import 'package:weather/weather.dart';

const Map<String, dynamic> response = {
  "coord": {"lon": -122.09, "lat": 37.39},
  "sys": {
    "type": 3,
    "id": 168940,
    "message": 0.0297,
    "country": "US",
    "sunrise": 1427723751,
    "sunset": 1427768967
  },
  "weather": [
    {"id": 800, "main": "Clear", "description": "Sky is Clear", "icon": "01n"}
  ],
  "base": "stations",
  "main": {
    "temp": 285.68,
    "humidity": 74,
    "pressure": 1016.8,
    "temp_min": 284.82,
    "temp_max": 286.48
  },
  "wind": {"speed": 0.96, "deg": 285.001},
  "clouds": {"all": 0},
  "dt": 1427700245,
  "id": 0,
  "name": "Mountain View",
  "cod": 200
};

const Map<String, dynamic> response2 = {
  "coord": {"lon": 12.58, "lat": 55.67},
  "weather": [
    {"id": 500, "main": "Rain", "description": "light rain", "icon": "10d"}
  ],
  "base": "stations",
  "main": {
    "temp": 275.14,
    "pressure": 1019,
    "humidity": 100,
    "temp_min": 274.15,
    "temp_max": 276.15
  },
  "visibility": 10000,
  "wind": {"speed": 11.3, "deg": 170, "gust": 16.5},
  "clouds": {"all": 90},
  "dt": 1543479600,
  "sys": {
    "type": 1,
    "id": 1575,
    "message": 0.2974,
    "country": "DK",
    "sunrise": 1543475494,
    "sunset": 1543502651
  },
  "id": 2618424,
  "name": "Københavns Kommune",
  "cod": 200
};

void main() {
  test('my first unit test', () {
    WeatherResult wr = new WeatherResult(response);
    WeatherResult wr2 = new WeatherResult(response2);

    print(wr.toString());
    print(wr2.toString());
  });
}
