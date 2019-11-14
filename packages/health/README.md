# health
This library combines both GoogleFit and AppleHealthKit. It support most of the values provided.

Supports **iOS** and **Android X**

## Data Types
| Data Type                    | Available on iOS | Available on Android | Comments             |
|------------------------------|------------------|----------------------|----------------------|
| `BODY_FAT`                   | yes              | yes                  |                      |
| `HEIGHT`                     | yes              | yes                  |                      |
| `WEIGHT`                     | yes              | yes                  |                      |
| `BODY_MASS_INDEX`            | yes              | yes                  |                      |
| `WAIST_CIRCUMFERENCE`        | yes              |                      |                      |
| `STEPS`                      | yes              | yes                  |                      |
| `BASAL_ENERGY_BURNED`        | yes              |                      |                      |
| `ACTIVE_ENERGY_BURNED`       | yes              | yes                  |                      |
| `HEART_RATE`                 | yes              | yes                  |                      |
| `BODY_TEMPERATURE`           | yes              | yes                  |                      |
| `BLOOD_PRESSURE_SYSTOLIC`    | yes              | yes                  |                      |
| `BLOOD_PRESSURE_DIASTOLIC`   | yes              | yes                  |                      |
| `RESTING_HEART_RATE`         | yes              |                      |                      |
| `WALKING_HEART_RATE`         | yes              |                      |                      |
| `BLOOD_OXYGEN`               | yes              | yes                  |                      |
| `BLOOD_GLUCOSE`              | yes              | yes                  |                      |
| `ELECTRODERMAL_ACTIVITY`     | yes              |                      | Requires Apple Watch |
| `HIGH_HEART_RATE_EVENT`      | yes              |                      | Requires Apple Watch |
| `LOW_HEART_RATE_EVENT`       | yes              |                      | Requires Apple Watch |
| `IRREGULAR_HEART_RATE_EVENT` | yes              |                      | Requires Apple Watch |

## Setup
### Apple HealthKit
Step 1: Append the Info.plist with the following 2 entries 
```xml
<key>NSHealthShareUsageDescription</key>
<string>We will sync your data with the Apple Health app to give you better insights</string>
<key>NSHealthUpdateUsageDescription</key>
<string>We will sync your data with the Apple Health app to give you better insights</string>
```

Step 2: Enable "HealthKit" inside "Capabilities"

### Google Fit
For GoogleFit, the initial setup is a bit longer, and can get frustrating.
Just follow [this setup](https://developers.google.com/fit/android/get-started). 

