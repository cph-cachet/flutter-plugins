## 11.1.0

* Fix of [#1043](https://github.com/cph-cachet/flutter-plugins/issues/1043)
* Type-safe JSON deserialization using carp_serializable v. 2.0

## 11.0.0

* **BREAKING** Remove Google Fit support in the Android code, as well as Google FIt related dependencies and references throughout the documentation
  * Remove `useHealthConnectIfAvailable` from the parameters of `Health().configure()`
  * Remove the `disconnect` method which was previously used to disconnect from Google Fit.
  * Remove the `flowRate` value from `writeBloodOxygen` as this is not supported by Health Connect.
  * Remove support for various `HealthWorkoutActivityType`s which were supported by Google Fit. Some of these do not have suitable alternatives in Google Health Connect (and are not supported on iOS). The list of removed types can be found in PR [#1014](https://github.com/cph-cachet/flutter-plugins/pull/1014)
* **BREAKING** introduce a new `RecordingMethod` enum
  * This can be used to filter records by automatic or manual entries when fetching data
  * You can also specify the recording method to write in the metadata
  * Remove `isManualEntry` from `HealthDataPoint` in favor of `recordingMethod`, of which the value is an enum `RecordingMethod`
  * Remove `includeManualEntry` (previously a boolean) from some of the querying methods in favor of `recordingMethodsToFilter`.
  * For complete details on relevant changes, see the description of PR [#1023](https://github.com/cph-cachet/flutter-plugins/pull/1023)
* Add support for all sleep stages across iOS and Android
  * Clean up relevant documentation
  * Remove undocumented sleep stages
  * **BREAKING** certain sleep stages were removed/combined into other related stages see PR [#1026](https://github.com/cph-cachet/flutter-plugins/pull/1026) for the complete list of changes and a discussion of the motivation in issue [#985](https://github.com/cph-cachet/flutter-plugins/issues/985)
* Android: Add support for `OTHER` workout type
* Cleaned up workout activity types for consistency across iOS and Android, see PR [#1020](https://github.com/cph-cachet/flutter-plugins/pull/1020) for a complete list of changes
* iOS: add support for menstruation flow, PR [#1008](https://github.com/cph-cachet/flutter-plugins/pull/1008)
* Android: Add support for heart rate variability, PR [#1009](https://github.com/cph-cachet/flutter-plugins/pull/1009)
* iOS: add support for atrial fibrillation burden, PR [#1031](https://github.com/cph-cachet/flutter-plugins/pull/1031)
* Add support for UUIDs in health records for both HealthKit and Health Connect, PR [#1019](https://github.com/cph-cachet/flutter-plugins/pull/1019)
* Fix an issue when querying workouts, the native code could respond with an activity that is not supported in the Health package, causing an error - this will fallback to `HealthWorkoutActivityType.other` - PR [#1016](https://github.com/cph-cachet/flutter-plugins/pull/1016)
* Remove deprecated Android v1 embeddings, PR [#1021](https://github.com/cph-cachet/flutter-plugins/pull/1021)

## 10.2.0

* Using named parameters in most methods for consistency.
* Added a `HealthPlatformType` to save which health platform the data originates from (Apple Health, Google Fit, or Google Health Connect).
* Android: Improved support for Google Health Connect
  * getHealthConnectSdkStatus, PR [#941](https://github.com/cph-cachet/flutter-plugins/pull/941)
  * installHealthConnect, PR [#943](https://github.com/cph-cachet/flutter-plugins/pull/943)
  * workout title, PR [#938](https://github.com/cph-cachet/flutter-plugins/pull/938)
* iOS: Add support for saving blood pressure as a correlation, PR [#919](https://github.com/cph-cachet/flutter-plugins/pull/919)

## 10.1.1

* Fix of error in `WorkoutSummary` JSON serialization.
* Fix of [#934](https://github.com/cph-cachet/flutter-plugins/issues/934)
* Empty value check for calories nutrition, PR [#926](https://github.com/cph-cachet/flutter-plugins/pull/926)
  
## 10.0.0

* **BREAKING** The plugin now works as a singleton using `Health()` to access it (instead of creating an instance of `HealthFactory`).
  * This entails that the plugin now need to be configured using the `configure()` method before use.
  * The example app has been update to demonstrate this new singleton model.
* Support for new data types:
  * body water mass, PR [#917](https://github.com/cph-cachet/flutter-plugins/pull/917)
  * caffeine, PR [#924](https://github.com/cph-cachet/flutter-plugins/pull/924)
  * workout summary, manual entry and new health data types, PR [#920](https://github.com/cph-cachet/flutter-plugins/pull/920)
* Fixed `SleepSessionRecord`, PR [#928](https://github.com/cph-cachet/flutter-plugins/pull/928)
* Update to API and README docs
* Upgrade to Dart 3.2 and Flutter 3.
* Added Dart linter and fixed a series of type casting issues.
* Using carp_serializable for consistent camel_case and type-safe generation of JSON serialization methods for polymorphic health data type classes.

## 9.0.0

* Updated HC to comply with Android 14, PR [#834](https://github.com/cph-cachet/flutter-plugins/pull/834) and [#882](https://github.com/cph-cachet/flutter-plugins/pull/882)
* Added checks for NullPointerException, closes issue [#878](https://github.com/cph-cachet/flutter-plugins/issues/878)
* Updated intl to ^0.19.0
* Upgrade to AGP 8, PR [#868](https://github.com/cph-cachet/flutter-plugins/pull/868)
* Added missing google fit workout types, PR [#836](https://github.com/cph-cachet/flutter-plugins/pull/836)
* Added pagination in HC, PR [#862](https://github.com/cph-cachet/flutter-plugins/pull/862)
* Fix of permission in example app + improvements to doc, PR [#875](https://github.com/cph-cachet/flutter-plugins/pull/875)

## 8.1.0

* Fixed sleep stages on iOS, Issue [#803](https://github.com/cph-cachet/flutter-plugins/issues/803)
* Added Nutrition data type, includes PR [#679](https://github.com/cph-cachet/flutter-plugins/pull/679)
* Lowered minSDK, Issue [#809](https://github.com/cph-cachet/flutter-plugins/issues/809)

## 8.0.0

* Fixed issue [#774](https://github.com/cph-cachet/flutter-plugins/issues/774), [#779](https://github.com/cph-cachet/flutter-plugins/issues/779)
* Merged PR [#579](https://github.com/cph-cachet/flutter-plugins/pull/579), [#717](https://github.com/cph-cachet/flutter-plugins/pull/717), [#770](https://github.com/cph-cachet/flutter-plugins/pull/770)
* Upgraded to mavenCentral, upgraded minSDK, compileSDK, targetSDK
* Updated health connect client to 1.1.0
* Added respiratory rate and peripheral perfusion index to HealthConnect
* Minor fixes to requestAuthorization, sleep stage filtering

## 7.0.1

* Updated dart doc

## 7.0.0

* Merged PR #722
* Added deep, light, REM, and out of bed sleep to iOS and Android HealthConnect

## 6.0.0

* Fixed issues #[694](https://github.com/cph-cachet/flutter-plugins/issues/694), #[696](https://github.com/cph-cachet/flutter-plugins/issues/696), #[697](https://github.com/cph-cachet/flutter-plugins/issues/697), #[698](https://github.com/cph-cachet/flutter-plugins/issues/698)
* added totalSteps for HealthConnect
* added supplemental oxygen flow rate for blood oxygen saturation on Android

## 5.0.0

* Added initial support for the new Health Connect API, as Google Fit is being deprecated.
  * Does not yet support `revokePermissions`, `getTotalStepsInInterval`.
* Changed Intl package version dependency to `^0.17.0` to work with flutter stable version.
* Updated the example app to handle more buttons.

## 4.6.0

* Added method for revoking permissions. On Android it uses `disableFit()` to remove access to Google Fit - `revokePermissions`. Documented lack of methods for iOS.

## 4.5.0

* Updated android sdk, gradle
* Updated `enumToString` to native `.name`
* Update and fixed JSON serialization of HealthDataPoints
* Removed auth request in `writeWorkoutData` to avoid bug when denying the auth.
* Merged pull requests [#653](https://github.com/cph-cachet/flutter-plugins/pull/653), [#652](https://github.com/cph-cachet/flutter-plugins/pull/652), [#639](https://github.com/cph-cachet/flutter-plugins/pull/639), [#644](https://github.com/cph-cachet/flutter-plugins/pull/644), [#668](https://github.com/cph-cachet/flutter-plugins/pull/668)
* Further developed [#644](https://github.com/cph-cachet/flutter-plugins/pull/644) on android to accommodate having the `writeBloodPressure` api.
* Small bug fixes

## 4.4.0

* Merged pull request #[566](https://github.com/cph-cachet/flutter-plugins/pull/566), [#578](https://github.com/cph-cachet/flutter-plugins/pull/578), [#596](https://github.com/cph-cachet/flutter-plugins/pull/596), [#623](https://github.com/cph-cachet/flutter-plugins/pull/623), [#632](https://github.com/cph-cachet/flutter-plugins/pull/632)
* ECG added as part of [#566](https://github.com/cph-cachet/flutter-plugins/pull/566)
* Small fixes

## 4.3.0

* upgrade to `device_info_plus: ^8.0.0`

## 4.2.0

* upgrade to `device_info_plus: ^7.0.0`

## 4.1.1

* fix of [#572](https://github.com/cph-cachet/flutter-plugins/issues/572).

## 4.1.0

* update of `device_info_plus: ^4.0.0`
* upgraded to Dart 2.17 and Flutter 3.0

## 4.0.0

* Large refactor of the `HealthDataPoint` value into generic `HealthValue` and added `NumericHealthValue`, `AudiogramHealthValue` and `WorkoutHealthValue`
* Added support for Audiograms with `writeAudiogram` and in `getHealthDataFromTypes`
* Added support for Workouts with `writeWorkout` and in `getHealthDataFromTypes`
* Added all `HealthWorkoutActivityType`s
* Added more `HealthDataUnit` types
* Fix of [#432](https://github.com/cph-cachet/flutter-plugins/issues/532)
* updated documentation in code
* updated documentation in README.md
* updated example app
* cleaned up code
* removed `requestPermissions` as it was essentially a duplicate of `requestAuthorization`

## 3.4.4

* Fix of [#500](https://github.com/cph-cachet/flutter-plugins/issues/500).
* Added Headache-types to HealthDataTypes on iOS

## 3.4.3

* fix of [#401](https://github.com/cph-cachet/flutter-plugins/issues/401).

## 3.4.2

* Resolved concurrent issues with native threads [PR#483](https://github.com/cph-cachet/flutter-plugins/pull/483).
* HealthKit CategorySample [PR#485](https://github.com/cph-cachet/flutter-plugins/pull/485).
* update of API documentation.

## 3.4.0

* Add sleep in bed to android [PR#457](https://github.com/cph-cachet/flutter-plugins/pull/457).
* Add the android.permission.ACTIVITY_RECOGNITION setup to the README [PR#458](https://github.com/cph-cachet/flutter-plugins/pull/458).
* Fixed (regression) issues with metric and permissions [PR#462](https://github.com/cph-cachet/flutter-plugins/pull/462).
* Get total steps [PR#471](https://github.com/cph-cachet/flutter-plugins/pull/471).
* update of example app to reflect new features.
* update of API documentation.

## 3.3.1

* DISTANCE_DELTA is for Android, not iOS [PR#428](https://github.com/cph-cachet/flutter-plugins/pull/428).
* added missing READ_ACCESS [PR#454](https://github.com/cph-cachet/flutter-plugins/pull/454).

## 3.3.0

* Write support on Google Fit and HealthKit [PR#430](https://github.com/cph-cachet/flutter-plugins/pull/430).

## 3.2.1

* Updated `device_info_plus` version dependency

## 3.2.0

* added simple `HKWorkout` and `ExerciseTime` support [PR#421](https://github.com/cph-cachet/flutter-plugins/pull/421).

## 3.1.1+1

* added functions to request authorization [PR#394](https://github.com/cph-cachet/flutter-plugins/pull/394)

## 3.1.0

* added sleep data to Android + fix of permissions and initialization [PR#372](https://github.com/cph-cachet/flutter-plugins/pull/372)
* testability of HealthDataPoint [PR#388](https://github.com/cph-cachet/flutter-plugins/pull/388).
* update to using the `device_info_plus` plugin

## 3.0.6

* Added two new fields to the `HealthDataPoint` - `SourceId` and `SourceName` and populate when data is read. This allows data points to be disambiguous and in some cases allows us to get more accurate data. For example the number of steps can be reported from Apple Health and Watch and without source data they are aggregated into just "steps" producing an inaccurate result [PR#281](https://github.com/cph-cachet/flutter-plugins/pull/281).

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

* Bugfix regarding BMI from <https://github.com/cph-cachet/flutter-plugins/pull/258>

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

* Fixed a Google sign-in issue, and a type issue on Android (<https://github.com/cph-cachet/flutter-plugins/issues/201>)

## 2.0.6

* Fixed a Google sign-in issue. (<https://github.com/cph-cachet/flutter-plugins/issues/172>)

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
* See <https://github.com/cph-cachet/flutter-plugins/issues/133>

## 1.1.4

* Corrected table of units

## 1.1.3

* Updated table with units

## 1.1.2

* Now supports the data type `HEART_RATE_VARIABILITY_SDNN` on iOS

## 1.1.1

* Fixed issue #88 (<https://github.com/cph-cachet/flutter-plugins/issues/88>)

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
