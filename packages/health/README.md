# Health

Enables reading and writing health data from/to Apple Health, Google Fit and Health Connect.

> Google Fitness API is deprecated and will be turned down in 2024, thus this package will also transition to only support Health Connect.

The plugin supports:

- handling permissions to access health data using the `hasPermissions`, `requestAuthorization`, `revokePermissions` methods.
- reading health data using the `getHealthDataFromTypes` method.
- writing health data using the `writeHealthData` method.
- writing workouts using the `writeWorkout` method.
- writing meals on iOS (Apple Health) & Android using the `writeMeal` method.
- writing audiograms on iOS using the `writeAudiogram` method.
- writing blood pressure data using the `writeBloodPressure` method.
- accessing total step counts using the `getTotalStepsInInterval` method.
- cleaning up duplicate data points via the `removeDuplicates` method.
- removing data of a given type in a selected period of time using the `delete` method.

Note that for Android, the target phone **needs** to have [Health Connect](https://health.google/health-connect-android/) (which is currently in beta) installed and have access to the internet, otherwise this plugin will not work.

See the tables below for supported health and workout data types.

## Setup

### Apple Health (iOS)

Step 1: Append the `Info.plist` with the following 2 entries

```xml
<key>NSHealthShareUsageDescription</key>
<string>We will sync your data with the Apple Health app to give you better insights</string>
<key>NSHealthUpdateUsageDescription</key>
<string>We will sync your data with the Apple Health app to give you better insights</string>
```

Step 2: Open your Flutter project in Xcode by right clicking on the "ios" folder and selecting "Open in Xcode". Next, enable "HealthKit" by adding a capability inside the "Signing & Capabilities" tab of the Runner target's settings.

### Android

Starting from API level 28 (Android 9.0) accessing some fitness data (e.g. Steps) requires a special permission. To set it add the following line to your `AndroidManifest.xml` file.

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
```

Additionally, for workouts, if the distance of a workout is requested then the location permissions below are needed.

```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

#### Health Connect 

Health Connect requires the following lines in the `AndroidManifest.xml` file (see also the example app):

```xml
<!-- Check whether Health Connect is installed or not -->
<queries>
  <package android:name="com.google.android.apps.healthdata" />
  <intent>
    <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" />
  </intent>
</queries>
```

In the Health Connect permissions activity there is a link to your privacy policy. You need to grant the Health Connect app access in order to link back to your privacy policy. In the example below, you should either replace `.MainActivity` with an activity that presents the privacy policy or have the Main Activity route the user to the policy. This step may be required to pass Google app review when requesting access to sensitive permissions.

```xml
<activity-alias
     android:name="ViewPermissionUsageActivity"
     android:exported="true"
     android:targetActivity=".MainActivity"
     android:permission="android.permission.START_VIEW_PERMISSION_USAGE">
        <intent-filter>
            <action android:name="android.intent.action.VIEW_PERMISSION_USAGE" />
            <category android:name="android.intent.category.HEALTH_PERMISSIONS" />
        </intent-filter>
</activity-alias>
```

If using Health Connect on Android it requires special permissions in the `AndroidManifest.xml` file. The permissions can be found here: <https://developer.android.com/guide/health-and-fitness/health-connect/data-and-data-types/data-types>

Example shown here (can also be found in the example app):

```xml
<uses-permission android:name="android.permission.health.READ_HEART_RATE"/>
<uses-permission android:name="android.permission.health.WRITE_HEART_RATE"/>
...
```

Furthermore, an `intent-filter` needs to be added to the `.MainActivity` activity.

```xml
<activity
  android:name=".MainActivity"
  android:exported="true"

  ....

  <!-- Intention to show Permissions screen for Health Connect API -->
  <intent-filter>
    <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" />
  </intent-filter>
</activity>
```

There's a `debug`, `main` and `profile` version which are chosen depending on how you start your app. In general, it's sufficient to add permission only to the `main` version.

Because this is labeled as a `dangerous` protection level, the permission system will not grant it automatically and it requires the user's action.

You can prompt the user for it using the [permission_handler](https://pub.dev/packages/permission_handler) plugin.
Follow the plugin setup instructions and add the following line before requesting the data:

```dart
await Permission.activityRecognition.request();
await Permission.location.request();
```

### Android 14

This plugin uses the new `registerForActivityResult` when requesting permissions from Health Connect.
In order for that to work, the Main app's activity should extend `FlutterFragmentActivity` instead of `FlutterActivity`.
This adjustment allows casting from `Activity` to `ComponentActivity` for accessing `registerForActivityResult`.

In your MainActivity.kt file, update the `MainActivity` class so that it extends `FlutterFragmentActivity` instead of the default `FlutterActivity`:

```kotlin
...
import io.flutter.embedding.android.FlutterFragmentActivity
...

class MainActivity: FlutterFragmentActivity() {
...
}
```

### Android X

Replace the content of the `android/gradle.properties` file with the following lines:

```bash
org.gradle.jvmargs=-Xmx1536M
android.enableJetifier=true
android.useAndroidX=true
```

## Usage

See the example app for detailed examples of how to use the Health API.

The Health plugin is used via the `Health()` singleton using the different methods for handling permissions and getting and adding data to Apple Health or Google Health Connect.
Below is a simplified flow of how to use the plugin.

```dart
  // configure the health plugin before use.
  Health().configure();


  // define the types to get
  var types = [
    HealthDataType.STEPS,
    HealthDataType.BLOOD_GLUCOSE,
  ];

  // requesting access to the data types before reading them
  bool requested = await Health().requestAuthorization(types);

  var now = DateTime.now();

  // fetch health data from the last 24 hours
  List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
     now.subtract(Duration(days: 1)), now, types);

  // request permissions to write steps and blood glucose
  types = [HealthDataType.STEPS, HealthDataType.BLOOD_GLUCOSE];
  var permissions = [
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE
  ];
  await Health().requestAuthorization(types, permissions: permissions);

  // write steps and blood glucose
  bool success = await Health().writeHealthData(10, HealthDataType.STEPS, now, now);
  success = await Health().writeHealthData(3.1, HealthDataType.BLOOD_GLUCOSE, now, now);

  // get the number of steps for today
  var midnight = DateTime(now.year, now.month, now.day);
  int? steps = await Health().getTotalStepsInInterval(midnight, now);
```

### Health Data

A [`HealthDataPoint`](https://pub.dev/documentation/health/latest/health/HealthDataPoint-class.html) object contains the following data fields:

```dart
HealthValue value;
HealthDataType type;
HealthDataUnit unit;
DateTime dateFrom;
DateTime dateTo;
HealthPlatformType sourcePlatform;
String sourceDeviceId;
String sourceId;
String sourceName;
bool isManualEntry;
WorkoutSummary? workoutSummary;
```

where a [`HealthValue`](https://pub.dev/documentation/health/latest/health/HealthValue-class.html) can be any type of `AudiogramHealthValue`, `ElectrocardiogramHealthValue`, `ElectrocardiogramVoltageValue`, `NumericHealthValue`, `NutritionHealthValue`, or `WorkoutHealthValue`.

A `HealthDataPoint` object can be serialized to and from JSON using the `toJson()` and `fromJson()` methods. JSON serialization is using camel_case notation. Null values are not serialized. For example;

```json
{
  "value": {
    "__type": "NumericHealthValue",
    "numeric_value": 141.0
  },
  "type": "STEPS",
  "unit": "COUNT",
  "date_from": "2024-04-03T10:06:57.736",
  "date_to": "2024-04-03T10:12:51.724",
  "source_platform": "appleHealth",
  "source_device_id": "F74938B9-C011-4DE4-AA5E-CF41B60B96E7",
  "source_id": "com.apple.health.81AE7156-EC05-47E3-AC93-2D6F65C717DF",
  "source_name": "iPhone12.bardram.net",
  "is_manual_entry": false
  "value": {
    "__type": "NumericHealthValue",
    "numeric_value": 141.0
  },
  "type": "STEPS",
  "unit": "COUNT",
  "date_from": "2024-04-03T10:06:57.736",
  "date_to": "2024-04-03T10:12:51.724",
  "source_platform": "appleHealth",
  "source_device_id": "F74938B9-C011-4DE4-AA5E-CF41B60B96E7",
  "source_id": "com.apple.health.81AE7156-EC05-47E3-AC93-2D6F65C717DF",
  "source_name": "iPhone12.bardram.net",
  "is_manual_entry": false
}
```

### Fetch health data

See the example app for a showcasing of how it's done.

**Note** On iOS the device must be unlocked before health data can be requested. Otherwise an error will be thrown:

```bash
flutter: Health Plugin Error:
flutter:  PlatformException(FlutterHealth, Results are null, Optional(Error Domain=com.apple.healthkit Code=6 "Protected health data is inaccessible" UserInfo={NSLocalizedDescription=Protected health data is inaccessible}))
```

### Filtering out duplicates

If the same data is requested multiple times and saved in the same array duplicates will occur.

A single data point can be compared to each other with the == operator, i.e.

```dart
HealthDataPoint p1 = ...;
HealthDataPoint p2 = ...;
bool same = p1 == p2;
```

If you have a list of data points, duplicates can be removed with:

```dart
List<HealthDataPoint> points = ...;
points = Health().removeDuplicates(points);
```

## Data Types

The plugin supports the following [`HealthDataType`](https://pub.dev/documentation/health/latest/health/HealthDataType.html).

| **Data Type**                | **Unit**                | **Apple Health** | **Google Health Connect** | **Comments**                           |
| ---------------------------- | ----------------------- | ---------------- | ------------------------- | -------------------------------------- |
| ACTIVE_ENERGY_BURNED         | CALORIES                | yes              | yes                       |                                        |
| BASAL_ENERGY_BURNED          | CALORIES                | yes              | yes                       |                                        |
| BLOOD_GLUCOSE                | MILLIGRAM_PER_DECILITER | yes              | yes                       |                                        |
| BLOOD_OXYGEN                 | PERCENTAGE              | yes              | yes                       |                                        |
| BLOOD_PRESSURE_DIASTOLIC     | MILLIMETER_OF_MERCURY   | yes              | yes                       |                                        |
| BLOOD_PRESSURE_SYSTOLIC      | MILLIMETER_OF_MERCURY   | yes              | yes                       |                                        |
| BODY_FAT_PERCENTAGE          | PERCENTAGE              | yes              | yes                       |                                        |
| BODY_MASS_INDEX              | NO_UNIT                 | yes              | yes                       |                                        |
| BODY_TEMPERATURE             | DEGREE_CELSIUS          | yes              | yes                       |                                        |
| BODY_WATER_MASS              | KILOGRAMS               |                  | yes                       |                                        |
| ELECTRODERMAL_ACTIVITY       | SIEMENS                 | yes              |                           |                                        |
| HEART_RATE                   | BEATS_PER_MINUTE        | yes              | yes                       |                                        |
| HEIGHT                       | METERS                  | yes              | yes                       |                                        |
| RESTING_HEART_RATE           | BEATS_PER_MINUTE        | yes              | yes                       |                                        |
| RESPIRATORY_RATE             | RESPIRATIONS_PER_MINUTE | yes              | yes                       |                                        |
| PERIPHERAL_PERFUSION_INDEX   | PERCENTAGE              | yes              |                           |                                        |
| STEPS                        | COUNT                   | yes              | yes                       |                                        |
| WAIST_CIRCUMFERENCE          | METERS                  | yes              |                           |                                        |
| WALKING_HEART_RATE           | BEATS_PER_MINUTE        | yes              |                           |                                        |
| WEIGHT                       | KILOGRAMS               | yes              | yes                       |                                        |
| DISTANCE_WALKING_RUNNING     | METERS                  | yes              |                           |                                        |
| FLIGHTS_CLIMBED              | COUNT                   | yes              | yes                       |                                        |
| DISTANCE_DELTA               | METERS                  |                  | yes                       |                                        |
| MINDFULNESS                  | MINUTES                 | yes              |                           |                                        |
| SLEEP_IN_BED                 | MINUTES                 | yes              |                           |                                        |
| SLEEP_ASLEEP                 | MINUTES                 | yes              | yes                       |                                        |
| SLEEP_AWAKE                  | MINUTES                 | yes              | yes                       |                                        |
| SLEEP_DEEP                   | MINUTES                 | yes              | yes                       |                                        |
| SLEEP_LIGHT                  | MINUTES                 |                  | yes                       |                                        |
| SLEEP_REM                    | MINUTES                 | yes              | yes                       |                                        |
| SLEEP_OUT_OF_BED             | MINUTES                 |                  | yes                       |                                        |
| SLEEP_SESSION                | MINUTES                 |                  | yes                       |                                        |
| WATER                        | LITER                   | yes              | yes                       |                                        |
| EXERCISE_TIME                | MINUTES                 | yes              |                           |                                        |
| WORKOUT                      | NO_UNIT                 | yes              | yes                       | See table below                        |
| HIGH_HEART_RATE_EVENT        | NO_UNIT                 | yes              |                           | Requires Apple Watch to write the data |
| LOW_HEART_RATE_EVENT         | NO_UNIT                 | yes              |                           | Requires Apple Watch to write the data |
| IRREGULAR_HEART_RATE_EVENT   | NO_UNIT                 | yes              |                           | Requires Apple Watch to write the data |
| HEART_RATE_VARIABILITY_RMSSD | MILLISECONDS            |                  | yes                       |                                        |
| HEART_RATE_VARIABILITY_SDNN  | MILLISECONDS            | yes              |                           | Requires Apple Watch to write the data |
| HEADACHE_NOT_PRESENT         | MINUTES                 | yes              |                           |                                        |
| HEADACHE_MILD                | MINUTES                 | yes              |                           |                                        |
| HEADACHE_MODERATE            | MINUTES                 | yes              |                           |                                        |
| HEADACHE_SEVERE              | MINUTES                 | yes              |                           |                                        |
| HEADACHE_UNSPECIFIED         | MINUTES                 | yes              |                           |                                        |
| AUDIOGRAM                    | DECIBEL_HEARING_LEVEL   | yes              |                           |                                        |
| ELECTROCARDIOGRAM            | VOLT                    | yes              |                           | Requires Apple Watch to write the data |
| NUTRITION                    | NO_UNIT                 | yes              | yes                       |                                        |
| INSULIN_DELIVERY             | INTERNATIONAL_UNIT      | yes              |                           |                                        |

## Workout Types

The plugin supports the following [`HealthWorkoutActivityType`](https://pub.dev/documentation/health/latest/health/HealthWorkoutActivityType.html).

| **Workout Type**                 | **Apple Health** | **Google Health Connect** | **Comments**                                                      |
| -------------------------------- | ---------------- | ------------------------- | ----------------------------------------------------------------- |
| AMERICAN_FOOTBALL                | yes              | yes                       |                                                                   |
| ARCHERY                          | yes              |                           |                                                                   |
| AUSTRALIAN_FOOTBALL              | yes              | yes                       |                                                                   |
| BADMINTON                        | yes              | yes                       |                                                                   |
| BARRE                            | yes              |                           |                                                                   |
| BASEBALL                         | yes              | yes                       |                                                                   |
| BASKETBALL                       | yes              | yes                       |                                                                   |
| BIKING                           | yes              | yes                       | on iOS this is CYCLING, but name changed here to fit with Android |
| BOWLING                          | yes              |                           |                                                                   |
| BOXING                           | yes              | yes                       |                                                                   |
| CALISTHENICS                     |                  | yes                       |                                                                   |
| CARDIO_DANCE                     | yes              |                           |                                                                   |
| CLIMBING                         | yes              |                           |                                                                   |
| COOLDOWN                         | yes              |                           |                                                                   |
| CORE_TRAINING                    | yes              |                           |                                                                   |
| CRICKET                          | yes              | yes                       |                                                                   |
| CROSS_COUNTRY_SKIING             | yes              |                           |                                                                   |
| CROSS_TRAINING                   | yes              |                           |                                                                   |
| CURLING                          | yes              |                           |                                                                   |
| DANCING                          | yes              | yes                       | on iOS this is DANCE, but name changed here to fit with Android |
| DISC_SPORTS                      | yes              |                           |                                                                   |
| DOWNHILL_SKIING                  | yes              |                           |                                                                   |
| ELLIPTICAL                       | yes              | yes                       |                                                                   |
| EQUESTRIAN_SPORTS                | yes              |                           |                                                                   |
| FENCING                          | yes              | yes                       |                                                                   |
| FISHING                          | yes              |                           |                                                                   |
| FITNESS_GAMING                   | yes              |                           |                                                                   |
| FLEXIBILITY                      | yes              |                           |                                                                   |
| FRISBEE_DISC                     |                  | yes                       |                                                                   |
| FUNCTIONAL_STRENGTH_TRAINING     | yes              |                           |                                                                   |
| GOLF                             | yes              | yes                       |                                                                   |
| GUIDED_BREATHING                 |                  | yes                       |                                                                   |
| GYMNASTICS                       | yes              | yes                       |                                                                   |
| HAND_CYCLING                     | yes              |                           |                                                                   |
| HANDBALL                         | yes              | yes                       |                                                                   |
| HIGH_INTENSITY_INTERVAL_TRAINING | yes              | yes                       |                                                                   |
| HIKING                           | yes              | yes                       |                                                                   |
| HOCKEY                           | yes              |                           |                                                                   |
| HUNTING                          | yes              |                           |                                                                   |
| JUMP_ROPE                        | yes              |                           |                                                                   |
| KICKBOXING                       | yes              |                           |                                                                   |
| LACROSSE                         | yes              |                           |                                                                   |
| MARTIAL_ARTS                     | yes              | yes                       |                                                                   |
| MIND_AND_BODY                    | yes              |                           |                                                                   |
| MIXED_CARDIO                     | yes              |                           |                                                                   |
| PADDLE_SPORTS                    | yes              |                           |                                                                   |
| PARAGLIDING                      |                  | yes                       |                                                                   |
| PICKLEBALL                       | yes              |                           |                                                                   |
| PILATES                          | yes              | yes                       |                                                                   |
| PLAY                             | yes              |                           |                                                                   |
| PREPARATION_AND_RECOVERY         | yes              |                           |                                                                   |
| RACQUETBALL                      | yes              | yes                       |                                                                   |
| ROCK_CLIMBING                    | (yes)            | yes                       | on iOS this will be stored as CLIMBING                            |
| ROWING                           | yes              | yes                       |                                                                   |
| RUGBY                            | yes              | yes                       |                                                                   |
| RUNNING                          | yes              | yes                       |                                                                   |
| RUNNING_JOGGING                  | (yes)            |                           | on iOS this will be stored as RUNNING                             |
| RUNNING_SAND                     | (yes)            |                           | on iOS this will be stored as RUNNING                             |
| RUNNING_TREADMILL                | (yes)            | yes                       | on iOS this will be stored as RUNNING                             |
| SAILING                          | yes              | yes                       |                                                                   |
| SCUBA_DIVING                     |                  | yes                       |                                                                   |
| SKATING                          | yes              | yes                       | On iOS this is skating_sports                                     |
| SKATING_CROSS                    | (yes)            |                           | on iOS this will be stored as SKATING                             |
| SKATING_INDOOR                   | (yes)            |                           | on iOS this will be stored as SKATING                             |
| SKATING_INLINE                   | (yes)            |                           | on iOS this will be stored as SKATING                             |
| SKIING_BACK_COUNTRY              |                  |                           |                                                                   |
| SKIING_KITE                      |                  |                           |                                                                   |
| SKIING_ROLLER                    |                  |                           |                                                                   |
| SNOW_SPORTS                      | yes              |                           |                                                                   |
| SNOWBOARDING                     | yes              | yes                       |                                                                   |
| SOCCER                           | yes              |                           |                                                                   |
| SOCIAL_DANCE                     | yes              |                           |                                                                   |
| SOFTBALL                         | yes              | yes                       |                                                                   |
| SQUASH                           | yes              | yes                       |                                                                   |
| STAIR_CLIMBING                   | yes              | yes                       |                                                                   |
| STAIR_CLIMBING_MACHINE           |                  | yes                       |                                                                   |
| STAIRS                           | yes              |                           |                                                                   |
| STEP_TRAINING                    | yes              |                           |                                                                   |
| STRENGTH_TRAINING                |                  | yes                       |                                                                   |
| SURFING                          |                  | yes                       |                                                                   |
| SURFING_SPORTS                   | yes              |                           |                                                                   |
| SWIMMING                         | yes              |                           |                                                                   |
| SWIMMING_OPEN_WATER              |                  | yes                       |                                                                   |
| SWIMMING_POOL                    |                  | yes                       |                                                                   |
| TABLE_TENNIS                     | yes              | yes                       |                                                                   |
| TAI_CHI                          | yes              |                           |                                                                   |
| TENNIS                           | yes              | yes                       |                                                                   |
| TRACK_AND_FIELD                  | yes              |                           |                                                                   |
| TRADITIONAL_STRENGTH_TRAINING    | yes              |                           |                                                                   |
| TREADMILL                        |                  |                           |                                                                   |
| VOLLEYBALL                       | yes              | yes                       |                                                                   |
| VOLLEYBALL_BEACH                 |                  |                           |                                                                   |
| VOLLEYBALL_INDOOR                |                  |                           |                                                                   |
| WALKING                          | yes              | yes                       |                                                                   |
| WATER_FITNESS                    | yes              |                           |                                                                   |
| WATER_POLO                       | yes              | yes                       |                                                                   |
| WATER_SPORTS                     | yes              |                           |                                                                   |
| WEIGHTLIFTING                    |                  | yes                       |                                                                   |
| WHEELCHAIR                       |                  | yes                       |                                                                   |
| WHEELCHAIR_RUN_PACE              | yes              |                           |                                                                   |
| WHEELCHAIR_WALK_PACE             | yes              |                           |                                                                   |
| WRESTLING                        | yes              |                           |                                                                   |
| YOGA                             | yes              | yes                       |                                                                   |
| OTHER                            | yes              | yes                       |                                                                   |
