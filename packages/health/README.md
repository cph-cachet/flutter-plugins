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
- cleaning up dublicate data points via the `removeDuplicates` method.
- removing data of a given type in a selected period of time using the `delete` method.
- Support the future Android API Health Connect.

Note that for Android, the target phone **needs** to have [Google Fit](https://www.google.com/fit/) or [Health Connect](https://health.google/health-connect-android/) (which is currently in beta) installed and have access to the internet, otherwise this plugin will not work.

## Data Types

| **Data Type**               | **Unit**                | **iOS** | **Android (Google Fit)** | **Android (Health Connect)** | **Comments**                           |
| --------------------------- | ----------------------- | ------- | ------------------------ |------------------------------| -------------------------------------- |
| ACTIVE_ENERGY_BURNED        | CALORIES                | yes     | yes                      | yes                          |                                        |
| BASAL_ENERGY_BURNED         | CALORIES                | yes     |                          | yes                          |                                        |
| BLOOD_GLUCOSE               | MILLIGRAM_PER_DECILITER | yes     | yes                      | yes                          |                                        |
| BLOOD_OXYGEN                | PERCENTAGE              | yes     | yes                      | yes                          |                                        |
| BLOOD_PRESSURE_DIASTOLIC    | MILLIMETER_OF_MERCURY   | yes     | yes                      | yes                          |                                        |
| BLOOD_PRESSURE_SYSTOLIC     | MILLIMETER_OF_MERCURY   | yes     | yes                      | yes                          |                                        |
| BODY_FAT_PERCENTAGE         | PERCENTAGE              | yes     | yes                      | yes                          |                                        |
| BODY_MASS_INDEX             | NO_UNIT                 | yes     | yes                      | yes                          |                                        |
| BODY_TEMPERATURE            | DEGREE_CELSIUS          | yes     | yes                      | yes                          |                                        |
| ELECTRODERMAL_ACTIVITY      | SIEMENS                 | yes     |                          |                              |                                        |
| HEART_RATE                  | BEATS_PER_MINUTE        | yes     | yes                      | yes                          |                                        |
| HEIGHT                      | METERS                  | yes     | yes                      | yes                          |                                        |
| RESTING_HEART_RATE          | BEATS_PER_MINUTE        | yes     |                          | yes                          |                                        |
| RESPIRATORY_RATE            | RESPIRATIONS_PER_MINUTE | yes     |                          | yes                                                                   |
| PERIPHERAL_PERFUSION_INDEX  | PERCENTAGE              | yes     |                          |                                                             |
| STEPS                       | COUNT                   | yes     | yes                      | yes                          |                                        |
| WAIST_CIRCUMFERENCE         | METERS                  | yes     |                          |                              |                                        |
| WALKING_HEART_RATE          | BEATS_PER_MINUTE        | yes     |                          |                              |                                        |
| WEIGHT                      | KILOGRAMS               | yes     | yes                      | yes                          |                                        |
| DISTANCE_WALKING_RUNNING    | METERS                  | yes     |                          |                              |                                        |
| FLIGHTS_CLIMBED             | COUNT                   | yes     |                          | yes                          |                                        |
| MOVE_MINUTES                | MINUTES                 |         | yes                      |                              |                                        |
| DISTANCE_DELTA              | METERS                  |         | yes                      | yes                          |                                        |
| MINDFULNESS                 | MINUTES                 | yes     |                          |                              |                                        |
| SLEEP_IN_BED                | MINUTES                 | yes     |                          |                              |                                        |
| SLEEP_ASLEEP                | MINUTES                 | yes     |                          | yes                          |                                        |
| SLEEP_AWAKE                 | MINUTES                 | yes     |                          | yes                          |                                        |
| SLEEP_DEEP                  | MINUTES                 | yes     |                          | yes                          |                                        |
| SLEEP_LIGHT                 | MINUTES                 |         |                          | yes                          |                                        |
| SLEEP_REM                   | MINUTES                 | yes     |                          | yes                          |                                        |
| SLEEP_OUT_OF_BED            | MINUTES                 |         |                          | yes                          |                                        |
| SLEEP_SESSION               | MINUTES                 |         |                          | yes                          |                                        |
| WATER                       | LITER                   | yes     | yes                      | yes                          |                                        |
| EXERCISE_TIME               | MINUTES                 | yes     |                          |                              |                                        |
| WORKOUT                     | NO_UNIT                 | yes     | yes                      | yes                          | (Has other workout types)              |
| HIGH_HEART_RATE_EVENT       | NO_UNIT                 | yes     |                          |                              | Requires Apple Watch to write the data |
| LOW_HEART_RATE_EVENT        | NO_UNIT                 | yes     |                          |                              | Requires Apple Watch to write the data |
| IRREGULAR_HEART_RATE_EVENT  | NO_UNIT                 | yes     |                          |                              | Requires Apple Watch to write the data |
| HEART_RATE_VARIABILITY_SDNN | MILLISECONDS            | yes     |                          |                              | Requires Apple Watch to write the data |
| HEADACHE_NOT_PRESENT        | MINUTES                 | yes     |                          |                              |                                        |
| HEADACHE_MILD               | MINUTES                 | yes     |                          |                              |                                        |
| HEADACHE_MODERATE           | MINUTES                 | yes     |                          |                              |                                        |
| HEADACHE_SEVERE             | MINUTES                 | yes     |                          |                              |                                        |
| HEADACHE_UNSPECIFIED        | MINUTES                 | yes     |                          |                              |                                        |
| AUDIOGRAM                   | DECIBEL_HEARING_LEVEL   | yes     |                          |                              |                                        |
| ELECTROCARDIOGRAM           | VOLT                    | yes     |                          |                              | Requires Apple Watch to write the data |
| NUTRITION                   | NO_UNIT                 | yes     | yes                      | yes                          |                                        |

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

### Google Fit (Android option 1)

Follow the guide at <https://developers.google.com/fit/android/get-api-key>

Below is an example of following the guide:

Change directory to your key-store directory (MacOS):
`cd ~/.android/`

Get your keystore SHA1 fingerprint:
`keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`

Example output:

```
Alias name: androiddebugkey
Creation date: Jan 01, 2013
Entry type: PrivateKeyEntry
Certificate chain length: 1
Certificate[1]:
Owner: CN=Android Debug, O=Android, C=US
Issuer: CN=Android Debug, O=Android, C=US
Serial number: 4aa9b300
Valid from: Mon Jan 01 08:04:04 UTC 2013 until: Mon Jan 01 18:04:04 PST 2033
Certificate fingerprints:
     MD5:  AE:9F:95:D0:A6:86:89:BC:A8:70:BA:34:FF:6A:AC:F9
     SHA1: BB:0D:AC:74:D3:21:E1:43:07:71:9B:62:90:AF:A1:66:6E:44:5D:75
     Signature algorithm name: SHA1withRSA
     Version: 3
```

Follow the instructions at <https://developers.google.com/fit/android/get-api-key> for setting up an OAuth2 Client ID for a Google project, and adding the SHA1 fingerprint to that OAuth2 credential.

The client id will look something like `YOUR_CLIENT_ID.apps.googleusercontent.com`.

### Health Connect (Android option 2)

Health Connect requires the following lines in the `AndroidManifest.xml` file (also seen in the example app):

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

```
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

### Android Permissions

Starting from API level 28 (Android 9.0) accessing some fitness data (e.g. Steps) requires a special permission.

To set it add the following line to your `AndroidManifest.xml` file.

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
```

#### Health Connect

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

#### Workout permissions

Additionally, for Workouts: If the distance of a workout is requested then the location permissions below are needed.

```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
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

```
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

The Health plugin is used via the `HealthFactory` class using the different methods for handling permissions and getting and adding data to Apple Health / Google Fit.
Below is a simplified flow of how to use the plugin.

```dart
  // create a HealthFactory for use in the app, choose if HealthConnect should be used or not
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  // define the types to get
  var types = [
    HealthDataType.STEPS,
    HealthDataType.BLOOD_GLUCOSE,
  ];

  // requesting access to the data types before reading them
  bool requested = await health.requestAuthorization(types);

  var now = DateTime.now();

  // fetch health data from the last 24 hours
  List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
     now.subtract(Duration(days: 1)), now, types);

  // request permissions to write steps and blood glucose
  types = [HealthDataType.STEPS, HealthDataType.BLOOD_GLUCOSE];
  var permissions = [
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE
  ];
  await health.requestAuthorization(types, permissions: permissions);

  // write steps and blood glucose
  bool success = await health.writeHealthData(10, HealthDataType.STEPS, now, now);
  success = await health.writeHealthData(3.1, HealthDataType.BLOOD_GLUCOSE, now, now);

  // get the number of steps for today
  var midnight = DateTime(now.year, now.month, now.day);
  int? steps = await health.getTotalStepsInInterval(midnight, now);
```

### Health Data

A `HealthDataPoint` object contains the following data fields:

```dart
HealthValue value; // NumericHealthValue, AudiogramHealthValue, WorkoutHealthValue, ElectrocardiogramHealthValue
HealthDataType type;
HealthDataUnit unit;
DateTime dateFrom;
DateTime dateTo;
PlatformType platform;
String uuid, deviceId;
String sourceId;
String sourceName;
```

A `HealthData` object can be serialized to JSON with the `toJson()` method.

### Fetch health data

See the example here on pub.dev, for a showcasing of how it's done.

NB for iOS: The device must be unlocked before Health data can be requested, otherwise an error will be thrown:

```
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
points = Health.removeDuplicates(points);
```

## Workouts

As of 4.0.0 Health supports adding workouts to both iOS and Android.

### Workout Types

| **Workout Type**                 | **iOS** | **Android (Google Fit)** | **Android (Health Connect)** | **Comments**                                                      |
| -------------------------------- | ------- | ------------------------ | ---------------------------- | ----------------------------------------------------------------- |
| ARCHERY                          | yes     | yes                      |                              |                                                                   |
| BADMINTON                        | yes     | yes                      | yes                          |                                                                   |
| BASEBALL                         | yes     | yes                      | yes                          |                                                                   |
| BASKETBALL                       | yes     | yes                      | yes                          |                                                                   |
| BIKING                           | yes     | yes                      | yes                          | on iOS this is CYCLING, but name changed here to fit with Android |
| BOXING                           | yes     | yes                      | yes                          |                                                                   |
| CRICKET                          | yes     | yes                      | yes                          |                                                                   |
| CURLING                          | yes     | yes                      |                              |                                                                   |
| ELLIPTICAL                       | yes     | yes                      | yes                          |                                                                   |
| FENCING                          | yes     | yes                      | yes                          |                                                                   |
| AMERICAN_FOOTBALL                | yes     | yes                      | yes                          |                                                                   |
| AUSTRALIAN_FOOTBALL              | yes     | yes                      | yes                          |                                                                   |
| SOCCER                           | yes     | yes                      |                              |                                                                   |
| GOLF                             | yes     | yes                      | yes                          |                                                                   |
| GYMNASTICS                       | yes     | yes                      | yes                          |                                                                   |
| HANDBALL                         | yes     | yes                      | yes                          |                                                                   |
| HIGH_INTENSITY_INTERVAL_TRAINING | yes     | yes                      | yes                          |                                                                   |
| HIKING                           | yes     | yes                      | yes                          |                                                                   |
| HOCKEY                           | yes     | yes                      |                              |                                                                   |
| SKATING                          | yes     | yes                      | yes                          | On iOS this is skating_sports                                     |
| JUMP_ROPE                        | yes     | yes                      |                              |                                                                   |
| KICKBOXING                       | yes     | yes                      |                              |                                                                   |
| MARTIAL_ARTS                     | yes     | yes                      | yes                          |                                                                   |
| PILATES                          | yes     | yes                      | yes                          |                                                                   |
| RACQUETBALL                      | yes     | yes                      | yes                          |                                                                   |
| RUGBY                            | yes     | yes                      | yes                          |                                                                   |
| RUNNING                          | yes     | yes                      | yes                          |                                                                   |
| ROWING                           | yes     | yes                      | yes                          |                                                                   |
| SAILING                          | yes     | yes                      | yes                          |                                                                   |
| CROSS_COUNTRY_SKIING             | yes     | yes                      |                              |                                                                   |
| DOWNHILL_SKIING                  | yes     | yes                      |                              |                                                                   |
| SNOWBOARDING                     | yes     | yes                      | yes                          |                                                                   |
| SOFTBALL                         | yes     | yes                      | yes                          |                                                                   |
| SQUASH                           | yes     | yes                      | yes                          |                                                                   |
| STAIR_CLIMBING                   | yes     | yes                      | yes                          |                                                                   |
| SWIMMING                         | yes     | yes                      |                              |                                                                   |
| TABLE_TENNIS                     | yes     | yes                      | yes                          |                                                                   |
| TENNIS                           | yes     | yes                      | yes                          |                                                                   |
| VOLLEYBALL                       | yes     | yes                      | yes                          |                                                                   |
| WALKING                          | yes     | yes                      | yes                          |                                                                   |
| WATER_POLO                       | yes     | yes                      | yes                          |                                                                   |
| YOGA                             | yes     | yes                      | yes                          |                                                                   |
| BOWLING                          | yes     |                          |                              |                                                                   |
| CROSS_TRAINING                   | yes     |                          |                              |                                                                   |
| TRACK_AND_FIELD                  | yes     |                          |                              |                                                                   |
| DISC_SPORTS                      | yes     |                          |                              |                                                                   |
| LACROSSE                         | yes     |                          |                              |                                                                   |
| PREPARATION_AND_RECOVERY         | yes     |                          |                              |                                                                   |
| FLEXIBILITY                      | yes     |                          |                              |                                                                   |
| COOLDOWN                         | yes     |                          |                              |                                                                   |
| WHEELCHAIR_WALK_PACE             | yes     |                          |                              |                                                                   |
| WHEELCHAIR_RUN_PACE              | yes     |                          |                              |                                                                   |
| HAND_CYCLING                     | yes     |                          |                              |                                                                   |
| CORE_TRAINING                    | yes     |                          |                              |                                                                   |
| FUNCTIONAL_STRENGTH_TRAINING     | yes     |                          |                              |                                                                   |
| TRADITIONAL_STRENGTH_TRAINING    | yes     |                          |                              |                                                                   |
| MIXED_CARDIO                     | yes     |                          |                              |                                                                   |
| STAIRS                           | yes     |                          |                              |                                                                   |
| STEP_TRAINING                    | yes     |                          |                              |                                                                   |
| FITNESS_GAMING                   | yes     |                          |                              |                                                                   |
| BARRE                            | yes     |                          |                              |                                                                   |
| CARDIO_DANCE                     | yes     |                          |                              |                                                                   |
| SOCIAL_DANCE                     | yes     |                          |                              |                                                                   |
| MIND_AND_BODY                    | yes     |                          |                              |                                                                   |
| PICKLEBALL                       | yes     |                          |                              |                                                                   |
| CLIMBING                         | yes     |                          |                              |                                                                   |
| EQUESTRIAN_SPORTS                | yes     |                          |                              |                                                                   |
| FISHING                          | yes     |                          |                              |                                                                   |
| HUNTING                          | yes     |                          |                              |                                                                   |
| PLAY                             | yes     |                          |                              |                                                                   |
| SNOW_SPORTS                      | yes     |                          |                              |                                                                   |
| PADDLE_SPORTS                    | yes     |                          |                              |                                                                   |
| SURFING_SPORTS                   | yes     |                          |                              |                                                                   |
| WATER_FITNESS                    | yes     |                          |                              |                                                                   |
| WATER_SPORTS                     | yes     |                          |                              |                                                                   |
| TAI_CHI                          | yes     |                          |                              |                                                                   |
| WRESTLING                        | yes     |                          |                              |                                                                   |
| AEROBICS                         |         | yes                      |                              |                                                                   |
| BIATHLON                         |         | yes                      |                              |                                                                   |
| CALISTHENICS                     |         | yes                      | yes                          |                                                                   |
| CIRCUIT_TRAINING                 |         | yes                      |                              |                                                                   |
| CROSS_FIT                        |         | yes                      |                              |                                                                   |
| DANCING                          |         | yes                      | yes                          |                                                                   |
| DIVING                           |         | yes                      |                              |                                                                   |
| ELEVATOR                         |         | yes                      |                              |                                                                   |
| ERGOMETER                        |         | yes                      |                              |                                                                   |
| ESCALATOR                        |         | yes                      |                              |                                                                   |
| FRISBEE_DISC                     |         | yes                      | yes                          |                                                                   |
| GARDENING                        |         | yes                      |                              |                                                                   |
| GUIDED_BREATHING                 |         | yes                      | yes                          |                                                                   |
| HORSEBACK_RIDING                 |         | yes                      |                              |                                                                   |
| HOUSEWORK                        |         | yes                      |                              |                                                                   |
| INTERVAL_TRAINING                |         | yes                      |                              |                                                                   |
| IN_VEHICLE                       |         | yes                      |                              |                                                                   |
| KAYAKING                         |         | yes                      |                              |                                                                   |
| KETTLEBELL_TRAINING              |         | yes                      |                              |                                                                   |
| KICK_SCOOTER                     |         | yes                      |                              |                                                                   |
| KITE_SURFING                     |         | yes                      |                              |                                                                   |
| MEDITATION                       |         | yes                      |                              |                                                                   |
| MIXED_MARTIAL_ARTS               |         | yes                      |                              |                                                                   |
| P90X                             |         | yes                      |                              |                                                                   |
| PARAGLIDING                      |         | yes                      | yes                          |                                                                   |
| POLO                             |         | yes                      |                              |                                                                   |
| ROCK_CLIMBING                    | (yes)   | yes                      | yes                          | on iOS this will be stored as CLIMBING                            |
| RUNNING_JOGGING                  | (yes)   | yes                      |                              | on iOS this will be stored as RUNNING                             |
| RUNNING_SAND                     | (yes)   | yes                      |                              | on iOS this will be stored as RUNNING                             |
| RUNNING_TREADMILL                | (yes)   | yes                      | yes                          | on iOS this will be stored as RUNNING                             |
| SCUBA_DIVING                     |         | yes                      | yes                          |                                                                   |
| SKATING_CROSS                    | (yes)   | yes                      |                              | on iOS this will be stored as SKATING                             |
| SKATING_INDOOR                   | (yes)   | yes                      |                              | on iOS this will be stored as SKATING                             |
| SKATING_INLINE                   | (yes)   | yes                      |                              | on iOS this will be stored as SKATING                             |
| SKIING_BACK_COUNTRY              |         | yes                      |                              |                                                                   |
| SKIING_KITE                      |         | yes                      |                              |                                                                   |
| SKIING_ROLLER                    |         | yes                      |                              |                                                                   |
| SLEDDING                         |         | yes                      |                              |                                                                   |
| STAIR_CLIMBING_MACHINE           |         | yes                      | yes                          |                                                                   |
| STANDUP_PADDLEBOARDING           |         | yes                      |                              |                                                                   |
| STILL                            |         | yes                      |                              |                                                                   |
| STRENGTH_TRAINING                |         | yes                      | yes                          |                                                                   |
| SURFING                          |         | yes                      | yes                          |                                                                   |
| SWIMMING_OPEN_WATER              |         | yes                      | yes                          |                                                                   |
| SWIMMING_POOL                    |         | yes                      | yes                          |                                                                   |
| TEAM_SPORTS                      |         | yes                      |                              |                                                                   |
| TILTING                          |         | yes                      |                              |                                                                   |
| TREADMILL                        |         | yes                      |                              |                                                                   |
| VOLLEYBALL_BEACH                 |         | yes                      |                              |                                                                   |
| VOLLEYBALL_INDOOR                |         | yes                      |                              |                                                                   |
| WAKEBOARDING                     |         | yes                      |                              |                                                                   |
| WALKING_FITNESS                  |         | yes                      |                              |                                                                   |
| WALKING_NORDIC                   |         | yes                      |                              |                                                                   |
| WALKING_STROLLER                 |         | yes                      |                              |                                                                   |
| WALKING_TREADMILL                |         | yes                      |                              |                                                                   |
| WEIGHTLIFTING                    |         | yes                      | yes                          |                                                                   |
| WHEELCHAIR                       |         | yes                      | yes                          |                                                                   |
| WINDSURFING                      |         | yes                      |                              |                                                                   |
| ZUMBA                            |         | yes                      |                              |                                                                   |
| OTHER                            | yes     | yes                      |                              |                                                                   |
