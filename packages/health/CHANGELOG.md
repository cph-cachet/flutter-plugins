## 3.3.1
* [PR #428](https://github.com/cph-cachet/flutter-plugins/pull/428) - DISTANCE_DELTA is for Android, not iOS
* [PR #454](https://github.com/cph-cachet/flutter-plugins/pull/454) - added missing READ_ACCESS

## 3.3.0
* [PR #430](https://github.com/cph-cachet/flutter-plugins/pull/430) - Write support on Google Fit and HealthKit

## 3.2.1
* Updated `device_info_plus` version dependency

## 3.2.0
* [PR #421](https://github.com/cph-cachet/flutter-plugins/pull/421) -  added simple `HKWorkout` and `ExerciseTime` support

## 3.1.1+1
* [PR #394](https://github.com/cph-cachet/flutter-plugins/pull/394) - added functions to request authorization

## 3.1.0
* [PR #372](https://github.com/cph-cachet/flutter-plugins/pull/372) - added sleep data to Android + fix of permissions and initialization
* [PR #388](https://github.com/cph-cachet/flutter-plugins/pull/388) - testability of HealthDataPoint
* update to using the `device_info_plus` plugin 

## 3.0.6
* [PR#281](https://github.com/cph-cachet/flutter-plugins/pull/281) Added two new fields to the `HealthDataPoint` - `SourceId` and `SourceName` and populate when data is read. This allows datapoints to be disambigous and in some cases allows us to get more accurate data. For example the number of steps can be reported from Apple Health and Watch and without source data they are aggregated into just "steps" producing an innacurate result.

## 3.0.5
* Null safety in Dart has been implemented
* The plugin supports the Android v2 embedding

## 3.0.4
* Upgrade to `device_info` version 2.0.0

## 3.0.3
* Merged various PRs, mostly smaller fixes

## 3.0.2
* Upgrade to `device_info` version 1.0.0

## 3.0.1+1
* Bugfix regarding BMI from https://github.com/cph-cachet/flutter-plugins/pull/258

## 3.0.0
* Changed the flow for requesting access and reading data
    * Access must be requested manually before reading
    * This simplifies the data flow and makes it easier to reason about when debugging
* Data read access is no longer checked for each individual type, but rather on the set of types specified.

## 2.0.9
* Now handles the case when asking for BMI on Android when no height data has been collected.

## 2.0.8
* Fixed a merge issue which had deleted the data types added in 2.0.4.

## 2.0.7
* Fixed a Google sign-in issue, and a type issue on Android (https://github.com/cph-cachet/flutter-plugins/issues/201)

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
