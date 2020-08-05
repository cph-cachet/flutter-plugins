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
| FLIGHTS_CLIMBED             | NO_UNIT                 | yes         |                 |                      |
| MOVE_MINUTES                | MILLISECONDS            |             | yes             |                      |
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
num value;
String unit;
int dateFrom;
int dateTo;
String dataType;
String platform;
String uuid;
```
A `HealthData healthData` object can be serialized to JSON with the `healthData.toJson()` method.


### Full example
```dart

    List<HealthDataPoint> _healthDataList = [];
    DateTime startDate = DateTime.utc(2001, 01, 01);
    DateTime endDate = DateTime.now();
    ...
    
    Future<void> fetchData() async {
      if (await Health.requestAuthorization()) {
        print('Authorized');
  
        bool weightAvailable = Health.isDataTypeAvailable(HealthDataType.WEIGHT);
        print("is WEIGHT data type available?: $weightAvailable");
  
        /// Specify the wished data types
        List<HealthDataType> types = [
          HealthDataType.WEIGHT,
          HealthDataType.HEIGHT,
          HealthDataType.STEPS,
          HealthDataType.BODY_MASS_INDEX,
          HealthDataType.WAIST_CIRCUMFERENCE,
          HealthDataType.BODY_FAT_PERCENTAGE,
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.BASAL_ENERGY_BURNED,
          HealthDataType.HEART_RATE,
          HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          HealthDataType.RESTING_HEART_RATE,
          HealthDataType.BLOOD_GLUCOSE,
          HealthDataType.BLOOD_OXYGEN,
        ];
  
        for (HealthDataType type in types) {
          /// Calls must be wrapped in a try catch block
          try {
            /// Fetch new data
            List<HealthDataPoint> healthData =
                await Health.getHealthDataFromType(startDate, endDate, type);
  
            /// Save all the new data points
            _healthDataList.addAll(healthData);
  
            /// Filter out duplicates based on their UUID
            _healthDataList = Health.removeDuplicates(_healthDataList);
          } catch (exception) {
            print(exception.toString());
          }
        }
  
        /// Print the results
        _healthDataList.forEach((x) => print("Data point: $x"));
        
      } else {
        print('Not authorized');
      }
    }
```


### Check authorization
The following example shows prompting the user for authorization to the API, which is necessary in order to fetch any data. 

Calls to fetch data from the API should be done within the inner if-clause.

```dart
if (await Health.requestAuthorization())
```
### Specify data type
Data types indicate the type of data to fetch from the API and are available from the enum class `HealthDataType`. 

Below is an example of a few data types:

```dart
List<HealthDataType> types = [
        HealthDataType.WEIGHT,
        HealthDataType.HEIGHT,
        HealthDataType.STEPS,
    ];
```
For an overview of all data types see the table in __Data Types__ section above.

### Check if data type available
Not all data types are available on both platforms. In order to check whether or not a data type is available for the current platform, 

```dart
bool weightAvailable = Health.isDataTypeAvailable(HealthDataType.WEIGHT);
```

### Fetch data for a given type
Given the list of data types (`types`) as well as a `startData` and an `endDate`, we can now fetch all the data, for each data type with a call to the `Health.getHealthDataFromType` function.

Set up dates:

```dart
DateTime startDate = DateTime.utc(2001, 01, 01);
DateTime endDate = DateTime.now();
```

Make the fetch call:

```dart
/// Fetch new data
List<HealthDataPoint> healthData =
    await Health.getHealthDataFromType(startDate, endDate, type);
```

This call must be inside a try catch block, since when some data type is not available, an exception will be thrown. 
Also, make sure the access to the API has been authorized (see __Check authorization__).

### Filtering out duplicates
If the same data is requested multiple times it will result in duplicates. Luckily each data point has a UUID and is
therefore unique. To filter out duplicates, use the `Health.removeDuplicates` method:

```dart
_healthDataList = Health.removeDuplicates(_healthDataList);
```
