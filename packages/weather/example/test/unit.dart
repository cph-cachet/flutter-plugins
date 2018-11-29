import 'package:test/test.dart';
import 'package:weather/weather.dart';

const Map<String, dynamic> response = {
  "coord": {"lon": 12.58, "lat": 55.67},
  "weather": [
    {"id": 500, "main": "Rain", "description": "light rain", "icon": "10d"},
    {"id": 701, "main": "Mist", "description": "mist", "icon": "50d"}
  ],
  "base": "stations",
  "main": {
    "temp": 275.13,
    "pressure": 1017,
    "humidity": 99,
    "temp_min": 274.15,
    "temp_max": 276.15
  },
  "visibility": 10000,
  "wind": {"speed": 11.3, "deg": 170},
  "clouds": {"all": 90},
  "dt": 1543488600,
  "sys": {
    "type": 1,
    "id": 1575,
    "message": 0.0044,
    "country": "DK",
    "sunrise": 1543475502,
    "sunset": 1543502646
  },
  "id": 2618424,
  "name": "Københavns Kommune",
  "cod": 200
};

void main() {
  test('my first unit test', () {
    WeatherResult wr = new WeatherResult(response);
    print(wr.toString());

  });
}
