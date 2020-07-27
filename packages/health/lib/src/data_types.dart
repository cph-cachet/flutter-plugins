part of health;

/// List of all available data types.
enum HealthDataType {
  BODY_FAT_PERCENTAGE,
  HEIGHT,
  WEIGHT,
  BODY_MASS_INDEX,
  WAIST_CIRCUMFERENCE,
  STEPS,
  BASAL_ENERGY_BURNED,
  ACTIVE_ENERGY_BURNED,
  HEART_RATE,
  BODY_TEMPERATURE,
  BLOOD_PRESSURE_SYSTOLIC,
  BLOOD_PRESSURE_DIASTOLIC,
  RESTING_HEART_RATE,
  WALKING_HEART_RATE,
  BLOOD_OXYGEN,
  BLOOD_GLUCOSE,
  ELECTRODERMAL_ACTIVITY,

  // Heart Rate events (specific to Apple Watch)
  HIGH_HEART_RATE_EVENT,
  LOW_HEART_RATE_EVENT,
  IRREGULAR_HEART_RATE_EVENT
}

/// List of data types available on iOS
const List<HealthDataType> _dataTypesIOS = [
  HealthDataType.BODY_FAT_PERCENTAGE,
  HealthDataType.HEIGHT,
  HealthDataType.WEIGHT,
  HealthDataType.BODY_MASS_INDEX,
  HealthDataType.WAIST_CIRCUMFERENCE,
  HealthDataType.STEPS,
  HealthDataType.BASAL_ENERGY_BURNED,
  HealthDataType.ACTIVE_ENERGY_BURNED,
  HealthDataType.HEART_RATE,
  HealthDataType.BODY_TEMPERATURE,
  HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
  HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  HealthDataType.RESTING_HEART_RATE,
  HealthDataType.WALKING_HEART_RATE,
  HealthDataType.BLOOD_OXYGEN,
  HealthDataType.BLOOD_GLUCOSE,
  HealthDataType.ELECTRODERMAL_ACTIVITY,
  HealthDataType.HIGH_HEART_RATE_EVENT,
  HealthDataType.LOW_HEART_RATE_EVENT,
  HealthDataType.IRREGULAR_HEART_RATE_EVENT
];

/// List of data types available on Android
const List<HealthDataType> _dataTypesAndroid = [
  HealthDataType.BODY_FAT_PERCENTAGE,
  HealthDataType.HEIGHT,
  HealthDataType.WEIGHT,
  HealthDataType.BODY_MASS_INDEX,
  HealthDataType.STEPS,
  HealthDataType.ACTIVE_ENERGY_BURNED,
  HealthDataType.HEART_RATE,
  HealthDataType.BODY_TEMPERATURE,
  HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
  HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  HealthDataType.BLOOD_OXYGEN,
  HealthDataType.BLOOD_GLUCOSE,
];

/// Map a [HealthDataType] to a [HealthDataUnit].
const Map<HealthDataType, HealthDataUnit> _dataTypeToUnit = {
  HealthDataType.BODY_FAT_PERCENTAGE: HealthDataUnit.PERCENTAGE,
  HealthDataType.HEIGHT: HealthDataUnit.METERS,
  HealthDataType.WEIGHT: HealthDataUnit.KILOGRAMS,
  HealthDataType.BODY_MASS_INDEX: HealthDataUnit.NO_UNIT,
  HealthDataType.WAIST_CIRCUMFERENCE: HealthDataUnit.METERS,
  HealthDataType.STEPS: HealthDataUnit.COUNT,
  HealthDataType.BASAL_ENERGY_BURNED: HealthDataUnit.CALORIES,
  HealthDataType.ACTIVE_ENERGY_BURNED: HealthDataUnit.CALORIES,
  HealthDataType.HEART_RATE: HealthDataUnit.BEATS_PER_MINUTE,
  HealthDataType.BODY_TEMPERATURE: HealthDataUnit.DEGREE_CELSIUS,
  HealthDataType.BLOOD_PRESSURE_SYSTOLIC: HealthDataUnit.MILLIMETER_OF_MERCURY,
  HealthDataType.BLOOD_PRESSURE_DIASTOLIC: HealthDataUnit.MILLIMETER_OF_MERCURY,
  HealthDataType.RESTING_HEART_RATE: HealthDataUnit.BEATS_PER_MINUTE,
  HealthDataType.WALKING_HEART_RATE: HealthDataUnit.BEATS_PER_MINUTE,
  HealthDataType.BLOOD_OXYGEN: HealthDataUnit.PERCENTAGE,
  HealthDataType.BLOOD_GLUCOSE: HealthDataUnit.MILLIGRAM_PER_DECILITER,
  HealthDataType.ELECTRODERMAL_ACTIVITY: HealthDataUnit.SIEMENS,

  /// Heart Rate events (specific to Apple Watch)
  HealthDataType.HIGH_HEART_RATE_EVENT: HealthDataUnit.NO_UNIT,
  HealthDataType.LOW_HEART_RATE_EVENT: HealthDataUnit.NO_UNIT,
  HealthDataType.IRREGULAR_HEART_RATE_EVENT: HealthDataUnit.NO_UNIT
};
