## 1.2.2
* Added wind gust

## 1.2.1
* Added language to the API

## 1.2.0
* Renamed WeatherStation to WeatherFactory to reflect its purpose (it does not represent a physical weather station)
* Refactored parsing of forecasts
* Weather and Forecast can now also be queried using city name (previously only geolocation)
* Cleaned up the unit tests and documentation which was slightly wrong

## 1.1.6
* Added Temperature (Feels Like) to the Weather object. See https://github.com/cph-cachet/flutter-plugins/pull/58

## 1.1.5
* Added the Weather Condition Code (see https://github.com/cph-cachet/flutter-plugins/pull/73)


## 1.1.1
* Updated docs

## 1.1.0
* No longer relies on the Location package.
* Location can only be fetched by providing a latitude and longitude.

## 0.9.6
* upgrade to using location plugin v. 2.5.4


## 0.9.5
* better handling of requesting location permissions

## 0.9.4
* Updated the README

## 0.9.3
* Refactored how a http response is sent and parsed.
* Added exceptions for bad HTTP responses.
* Renamed existing exception classes to something more meaningful.

## 0.9.2
* Added support for Android X
* This version will not work for Android, unless instructions are followed carefully.

## 0.1.3
* Weather plugin works for Android and iOS
* Plugin now use objects to store weather information, rather than JSON


