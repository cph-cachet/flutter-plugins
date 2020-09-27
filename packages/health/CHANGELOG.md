## 2.0.6
* Fixed a Google sign-in issue. (https://github.com/cph-cachet/flutter-plugins/issues/172)

## 2.0.5
* Now uses 'device_info' rather than 'device_id' for getting device information

## 2.0.4+1
* Static analysis, formatting etc.

## 2.0.4
* Added Sleep data, Water, and Mindfulness.

## 2.0.3
* The method `requestAuthorization` is now public again.

## 2.0.2
* Updated the API to take a list of types rather than a single type, when requesting health data.


## 2.0.1+1
* Removed the need for try-catch on the programmer's end

## 2.0.1
* Removed UUID and instead introduced a comparison operator

## 2.0.0
* Changed the API substantially to allow for granular Data Type permissions

## 1.1.6
Added the following Health Types as per PR #147
* DISTANCE_WALKING_RUNNING
* FLIGHTS_CLIMBED         
* MOVE_MINUTES            
* DISTANCE_DELTA          

## 1.1.5
* Fixed an issue with google authorization
* See https://github.com/cph-cachet/flutter-plugins/issues/133

## 1.1.4
* Corrected table of units

## 1.1.3
* Updated table with units

## 1.1.2
* Now supports the data type `HEART_RATE_VARIABILITY_SDNN` on iOS

## 1.1.1
* Fixed issue #88 (https://github.com/cph-cachet/flutter-plugins/issues/88)

## 1.1.0
* Introduced UUID to the HealthDataPoint class
* Re-did the example application

## 1.0.6
* Fixed a null-check warning in the obj-c code (issue #87)

## 1.0.5
* Updated gradle-wrapper distribution url `gradle-5.4.1-all.zip` 
* Updated docs

## 1.0.2
* Updated documentation for Android and Google Fit.


## 1.0.1
* Streamlined DataType units in Flutter.
