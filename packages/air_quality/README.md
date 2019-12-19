# air_quality

Air quality index using the https://waqi.info/ endpoint.

# Permissions
No permissions needed.

# Usage
## Imports
The location package is also needed for the AirQuality package.
```dart
import 'package:air_quality/air_quality.dart';
```

## Initialization
An API key is needed in order to perform queries. An API key is obtained here: https://aqicn.org/api/

Example:
```dart
String key = 'XXX38456b2b85c92647d8b65090e29f957638c77';
AirQuality airQuality = new AirQuality(key);
```

## Getting Air Quality Feed
```dart
/// Via city name (Munich)
AirQualityData feedFromCity = await airQuality.feedFromCity('munich');

/// Via station ID (Gothenburg weather station)
AirQualityData feedFromStationId = await airQuality.feedFromStationId('7867');

/// Via Geo Location (Berlin)
AirQualityData feedFromGeoLocation = await airQuality.feedFromGeoLocation('52.6794', '12.5346');

/// Via IP (depends on service provider)
AirQualityData fromIP = await airQuality.feedFromIP();
```
