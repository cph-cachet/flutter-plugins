# flutter_health

This library combines both GoogleFit and AppleHealthKit. It support most of the values provided.

Works on from **iOS 11.0**. Some data types are supported from **iOS 12.2**.

Supports **Android X**


## HealthKit Data Types (iOS)
(X) = tested, (?) = not tested
* BODY_FAT (X)
* HEIGHT (X)
* BODY_MASS_INDEX (X)
* WAIST_CIRCUMFERENCE (X)
* STEPS (X)
* BASAL_ENERGY_BURNED (X)
* ACTIVE_ENERGY_BURNED (X)
* HEART_RATE (X)
* BODY_TEMPERATURE (X)
* BLOOD_PRESSURE_SYSTOLIC (X)
* BLOOD_PRESSURE_DIASTOLIC (X)
* RESTING_HEART_RATE (X) 
* WALKING_HEART_RATE (?) (Apple Watch)
* BLOOD_OXYGEN (X)
* BLOOD_GLUCOSE (X)
* ELECTRODERMAL_ACTIVITY (?) (Apple Watch)
* HIGH_HEART_RATE_EVENT (?) (Apple Watch)
* LOW_HEART_RATE_EVENT (?) (Apple Watch)
* IRREGULAR_HEART_RATE_EVENT (?) (Apple Watch)

## GoogleFit Data Types (Android)
(X) = tested, (?) = not tested
* BODY_FAT (?)
* HEIGHT (?)
* STEPS (?)
* CALORIES (?)
* HEART_RATE (?)
* BODY_TEMPERATURE (?)
* BLOOD_PRESSURE (?)
* BLOOD_OXYGEN (?)
* BLOOD_GLUCOSE (?)


## Setup

For GoogleFit, the initial setup is a bit longer, and can get frustrating.
Just follow [this setup](https://developers.google.com/fit/android/get-started). 

