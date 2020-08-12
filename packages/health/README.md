# Health
This library combines both GoogleFit and AppleHealthKit. It support most of the values provided.

Supports **iOS** and **Android X**

NB: For Android, your app *needs* to have Google Fit installed and have access to the internet, otherwise this plugin will not work.

## Data Types
| Data Type                   | Unit                    | iOS Support | Android support | Comments             |
|-----------------------------|-------------------------|-------------|-----------------|----------------------|
| ACTIVE_ENERGY_BURNED        | CALORIES                | yes         | yes             |                      |
| BASAL_ENERGY_BURNED         | CALORIES                | yes         |                 |                      |
| BLOOD_GLUCOSE               | MILLIGRAM_PER_DECILITER | yes         | yes             |                      |
| BLOOD_OXYGEN                | PERCENTAGE              | yes         | yes             |                      |
| BLOOD_PRESSURE_DIASTOLIC    | MILLIMETER_OF_MERCURY   | yes         | yes             |                      |
| BLOOD_PRESSURE_SYSTOLIC     | MILLIMETER_OF_MERCURY   | yes         | yes             |                      |
| BODY_FAT_PERCENTAGE         | PERCENTAGE              | yes         | yes             |                      |
| BODY_MASS_INDEX             | NO_UNIT                 | yes         | yes             |                      |
| BODY_TEMPERATURE            | DEGREE_CELSIUS          | yes         | yes             |                      |
| ELECTRODERMAL_ACTIVITY      | SIEMENS                 | yes         |                 |                      |
| HEART_RATE                  | BEATS_PER_MINUTE        | yes         | yes             |                      |
| HEIGHT                      | METERS                  | yes         | yes             |                      |
| RESTING_HEART_RATE          | BEATS_PER_MINUTE        | yes         |                 |                      |
| STEPS                       | COUNT                   | yes         | yes             |                      |
| WAIST_CIRCUMFERENCE         | METERS                  | yes         |                 |                      |
| WALKING_HEART_RATE          | BEATS_PER_MINUTE        | yes         |                 |                      |
| WEIGHT                      | KILOGRAMS               | yes         | yes             |                      |
| DISTANCE_WALKING_RUNNING    | METERS                  | yes         |                 |                      |
| FLIGHTS_CLIMBED             | COUNT                   | yes         |                 |                      |
| MOVE_MINUTES                | MINUTES                 |             | yes             |                      |
| DISTANCE_DELTA              | METERS                  |             | yes             |                      |
| HIGH_HEART_RATE_EVENT       | NO_UNIT                 | yes         |                 | Requires Apple Watch |
| LOW_HEART_RATE_EVENT        | NO_UNIT                 | yes         |                 | Requires Apple Watch |
| IRREGULAR_HEART_RATE_EVENT  | NO_UNIT                 | yes         |                 | Requires Apple Watch |
| HEART_RATE_VARIABILITY_SDNN | MILLISECONDS            | yes         |                 | Requires Apple Watch |

## Setup
### Apple HealthKit (iOS)
Step 1: Append the Info.plist with the following 2 entries 
```xml
<key>NSHealthShareUsageDescription</key>
<string>We will sync your data with the Apple Health app to give you better insights</string>
<key>NSHealthUpdateUsageDescription</key>
<string>We will sync your data with the Apple Health app to give you better insights</string>
```

Step 2: Enable "HealthKit" inside the "Capabilities" tab.

### Google Fit (Android)
Follow the guide at https://developers.google.com/fit/android/get-api-key

Below is an example of following the guide:

Change directory to your key-store directory (MacOS):
```cd ~/.android/```

Get your keystore SHA1 fingerprint:
```keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android```

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

Follow the instructions at https://console.developers.google.com/flows/enableapi?apiid=fitness for setting up an OAuth2 Client ID for a Google project, and adding the SHA1 fingerprint to that OAuth2 credential.

The client id will look something like `YOUR_CLIENT_ID.apps.googleusercontent.com`

### Android X
Replace the content of the `android/gradle.properties` file with the following lines:

```bash
org.gradle.jvmargs=-Xmx1536M
android.enableJetifier=true
android.useAndroidX=true
```

## Usage
Below is a snippet from the `example app` showing the plugin in use.

### Health data
A `HealthData` object contains the following fields:
```dart
num _value;
HealthDataType _type;
HealthDataUnit _unit;
DateTime _dateFrom;
DateTime _dateTo;
PlatformType _platform;
String _uuid, _deviceId;
```
A `HealthData healthData` object can be serialized to JSON with the `healthData.toJson()` method.


### Fetch health data for a single data type

### Fetch health data

To fetch data, specify a date-interval and the desired health data types:

```dart

List<HealthDataType> types = [
  HealthDataType.BODY_MASS_INDEX,
  HealthDataType.STEPS,
  HealthDataType.WEIGHT,
  HealthDataType.ACTIVE_ENERGY_BURNED
];

DateTime startDate = DateTime.utc(2001, 01, 01);
DateTime endDate = DateTime.now();

List<HealthDataPoint> healthData =
            await health.getHealthDataFromType(startDate, endDate, types);
```

NB for iOS: The device must be unlocked before Health data can be requested, otherwise an error will be thrown:

```
flutter: Health Plugin Error:
flutter: 	PlatformException(FlutterHealth, Results are null, Optional(Error Domain=com.apple.healthkit Code=6 "Protected health data is inaccessible" UserInfo={NSLocalizedDescription=Protected health data is inaccessible}))
```


### Full example
```dart
List<HealthDataPoint> _healthDataList = [];
DateTime startDate = DateTime.utc(2001, 01, 01);
DateTime endDate = DateTime.now();

HealthFactory health = HealthFactory();

/// Define the types to get.
List<HealthDataType> types = [
  HealthDataType.BODY_MASS_INDEX,
  HealthDataType.STEPS,
  HealthDataType.WEIGHT,
];

/// Fetch new data
List<HealthDataPoint> healthData =
    await health.getHealthDataFromTypes(startDate, endDate, types);

/// Save all the new data points
_healthDataList.addAll(healthData);

/// Filter out duplicates
_healthDataList = HealthFactory.removeDuplicates(_healthDataList);
```


### Filtering out duplicates
If the same data is requested multiple times and saved in the same array (as in the example above) duplicates will occur. 

A single data point can be compared to each other with the == operator, i.e.

````dart
HealthDataPoint p1 = ...;
HealthDataPoint p2 = ...;
bool same = p1 == p2;
````

If you have a list of data points, duplicates can be removed with:

```dart
List<HealthDataPoint> points = ...;
points = Health.removeDuplicates(points);
```
