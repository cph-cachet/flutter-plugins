// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthDataPoint _$HealthDataPointFromJson(Map<String, dynamic> json) =>
    HealthDataPoint(
      uuid: json['uuid'] as String,
      value: HealthValue.fromJson(json['value'] as Map<String, dynamic>),
      type: $enumDecode(_$HealthDataTypeEnumMap, json['type']),
      unit: $enumDecode(_$HealthDataUnitEnumMap, json['unit']),
      dateFrom: DateTime.parse(json['dateFrom'] as String),
      dateTo: DateTime.parse(json['dateTo'] as String),
      sourcePlatform:
          $enumDecode(_$HealthPlatformTypeEnumMap, json['sourcePlatform']),
      sourceDeviceId: json['sourceDeviceId'] as String,
      sourceId: json['sourceId'] as String,
      sourceName: json['sourceName'] as String,
      recordingMethod: $enumDecodeNullable(
              _$RecordingMethodEnumMap, json['recordingMethod']) ??
          RecordingMethod.unknown,
      workoutSummary: json['workoutSummary'] == null
          ? null
          : WorkoutSummary.fromJson(
              json['workoutSummary'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$HealthDataPointToJson(HealthDataPoint instance) {
  final val = <String, dynamic>{
    'uuid': instance.uuid,
    'value': instance.value.toJson(),
    'type': _$HealthDataTypeEnumMap[instance.type]!,
    'unit': _$HealthDataUnitEnumMap[instance.unit]!,
    'dateFrom': instance.dateFrom.toIso8601String(),
    'dateTo': instance.dateTo.toIso8601String(),
    'sourcePlatform': _$HealthPlatformTypeEnumMap[instance.sourcePlatform]!,
    'sourceDeviceId': instance.sourceDeviceId,
    'sourceId': instance.sourceId,
    'sourceName': instance.sourceName,
    'recordingMethod': _$RecordingMethodEnumMap[instance.recordingMethod]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('workoutSummary', instance.workoutSummary?.toJson());
  writeNotNull('metadata', instance.metadata);
  return val;
}

const _$HealthDataTypeEnumMap = {
  HealthDataType.ACTIVE_ENERGY_BURNED: 'ACTIVE_ENERGY_BURNED',
  HealthDataType.ATRIAL_FIBRILLATION_BURDEN: 'ATRIAL_FIBRILLATION_BURDEN',
  HealthDataType.AUDIOGRAM: 'AUDIOGRAM',
  HealthDataType.BASAL_ENERGY_BURNED: 'BASAL_ENERGY_BURNED',
  HealthDataType.BLOOD_GLUCOSE: 'BLOOD_GLUCOSE',
  HealthDataType.BLOOD_OXYGEN: 'BLOOD_OXYGEN',
  HealthDataType.BLOOD_PRESSURE_DIASTOLIC: 'BLOOD_PRESSURE_DIASTOLIC',
  HealthDataType.BLOOD_PRESSURE_SYSTOLIC: 'BLOOD_PRESSURE_SYSTOLIC',
  HealthDataType.BODY_FAT_PERCENTAGE: 'BODY_FAT_PERCENTAGE',
  HealthDataType.BODY_MASS_INDEX: 'BODY_MASS_INDEX',
  HealthDataType.BODY_TEMPERATURE: 'BODY_TEMPERATURE',
  HealthDataType.BODY_WATER_MASS: 'BODY_WATER_MASS',
  HealthDataType.DIETARY_CARBS_CONSUMED: 'DIETARY_CARBS_CONSUMED',
  HealthDataType.DIETARY_CAFFEINE: 'DIETARY_CAFFEINE',
  HealthDataType.DIETARY_ENERGY_CONSUMED: 'DIETARY_ENERGY_CONSUMED',
  HealthDataType.DIETARY_FATS_CONSUMED: 'DIETARY_FATS_CONSUMED',
  HealthDataType.DIETARY_PROTEIN_CONSUMED: 'DIETARY_PROTEIN_CONSUMED',
  HealthDataType.DIETARY_FIBER: 'DIETARY_FIBER',
  HealthDataType.DIETARY_SUGAR: 'DIETARY_SUGAR',
  HealthDataType.DIETARY_FAT_MONOUNSATURATED: 'DIETARY_FAT_MONOUNSATURATED',
  HealthDataType.DIETARY_FAT_POLYUNSATURATED: 'DIETARY_FAT_POLYUNSATURATED',
  HealthDataType.DIETARY_FAT_SATURATED: 'DIETARY_FAT_SATURATED',
  HealthDataType.DIETARY_CHOLESTEROL: 'DIETARY_CHOLESTEROL',
  HealthDataType.DIETARY_VITAMIN_A: 'DIETARY_VITAMIN_A',
  HealthDataType.DIETARY_THIAMIN: 'DIETARY_THIAMIN',
  HealthDataType.DIETARY_RIBOFLAVIN: 'DIETARY_RIBOFLAVIN',
  HealthDataType.DIETARY_NIACIN: 'DIETARY_NIACIN',
  HealthDataType.DIETARY_PANTOTHENIC_ACID: 'DIETARY_PANTOTHENIC_ACID',
  HealthDataType.DIETARY_VITAMIN_B6: 'DIETARY_VITAMIN_B6',
  HealthDataType.DIETARY_BIOTIN: 'DIETARY_BIOTIN',
  HealthDataType.DIETARY_VITAMIN_B12: 'DIETARY_VITAMIN_B12',
  HealthDataType.DIETARY_VITAMIN_C: 'DIETARY_VITAMIN_C',
  HealthDataType.DIETARY_VITAMIN_D: 'DIETARY_VITAMIN_D',
  HealthDataType.DIETARY_VITAMIN_E: 'DIETARY_VITAMIN_E',
  HealthDataType.DIETARY_VITAMIN_K: 'DIETARY_VITAMIN_K',
  HealthDataType.DIETARY_FOLATE: 'DIETARY_FOLATE',
  HealthDataType.DIETARY_CALCIUM: 'DIETARY_CALCIUM',
  HealthDataType.DIETARY_CHLORIDE: 'DIETARY_CHLORIDE',
  HealthDataType.DIETARY_IRON: 'DIETARY_IRON',
  HealthDataType.DIETARY_MAGNESIUM: 'DIETARY_MAGNESIUM',
  HealthDataType.DIETARY_PHOSPHORUS: 'DIETARY_PHOSPHORUS',
  HealthDataType.DIETARY_POTASSIUM: 'DIETARY_POTASSIUM',
  HealthDataType.DIETARY_SODIUM: 'DIETARY_SODIUM',
  HealthDataType.DIETARY_ZINC: 'DIETARY_ZINC',
  HealthDataType.DIETARY_CHROMIUM: 'DIETARY_CHROMIUM',
  HealthDataType.DIETARY_COPPER: 'DIETARY_COPPER',
  HealthDataType.DIETARY_IODINE: 'DIETARY_IODINE',
  HealthDataType.DIETARY_MANGANESE: 'DIETARY_MANGANESE',
  HealthDataType.DIETARY_MOLYBDENUM: 'DIETARY_MOLYBDENUM',
  HealthDataType.DIETARY_SELENIUM: 'DIETARY_SELENIUM',
  HealthDataType.FORCED_EXPIRATORY_VOLUME: 'FORCED_EXPIRATORY_VOLUME',
  HealthDataType.HEART_RATE: 'HEART_RATE',
  HealthDataType.HEART_RATE_VARIABILITY_SDNN: 'HEART_RATE_VARIABILITY_SDNN',
  HealthDataType.HEART_RATE_VARIABILITY_RMSSD: 'HEART_RATE_VARIABILITY_RMSSD',
  HealthDataType.HEIGHT: 'HEIGHT',
  HealthDataType.INSULIN_DELIVERY: 'INSULIN_DELIVERY',
  HealthDataType.RESTING_HEART_RATE: 'RESTING_HEART_RATE',
  HealthDataType.RESPIRATORY_RATE: 'RESPIRATORY_RATE',
  HealthDataType.PERIPHERAL_PERFUSION_INDEX: 'PERIPHERAL_PERFUSION_INDEX',
  HealthDataType.STEPS: 'STEPS',
  HealthDataType.WAIST_CIRCUMFERENCE: 'WAIST_CIRCUMFERENCE',
  HealthDataType.WALKING_HEART_RATE: 'WALKING_HEART_RATE',
  HealthDataType.WEIGHT: 'WEIGHT',
  HealthDataType.DISTANCE_WALKING_RUNNING: 'DISTANCE_WALKING_RUNNING',
  HealthDataType.DISTANCE_SWIMMING: 'DISTANCE_SWIMMING',
  HealthDataType.DISTANCE_CYCLING: 'DISTANCE_CYCLING',
  HealthDataType.FLIGHTS_CLIMBED: 'FLIGHTS_CLIMBED',
  HealthDataType.DISTANCE_DELTA: 'DISTANCE_DELTA',
  HealthDataType.MINDFULNESS: 'MINDFULNESS',
  HealthDataType.WATER: 'WATER',
  HealthDataType.SLEEP_ASLEEP: 'SLEEP_ASLEEP',
  HealthDataType.SLEEP_AWAKE_IN_BED: 'SLEEP_AWAKE_IN_BED',
  HealthDataType.SLEEP_AWAKE: 'SLEEP_AWAKE',
  HealthDataType.SLEEP_DEEP: 'SLEEP_DEEP',
  HealthDataType.SLEEP_IN_BED: 'SLEEP_IN_BED',
  HealthDataType.SLEEP_LIGHT: 'SLEEP_LIGHT',
  HealthDataType.SLEEP_OUT_OF_BED: 'SLEEP_OUT_OF_BED',
  HealthDataType.SLEEP_REM: 'SLEEP_REM',
  HealthDataType.SLEEP_SESSION: 'SLEEP_SESSION',
  HealthDataType.SLEEP_UNKNOWN: 'SLEEP_UNKNOWN',
  HealthDataType.EXERCISE_TIME: 'EXERCISE_TIME',
  HealthDataType.WORKOUT: 'WORKOUT',
  HealthDataType.HEADACHE_NOT_PRESENT: 'HEADACHE_NOT_PRESENT',
  HealthDataType.HEADACHE_MILD: 'HEADACHE_MILD',
  HealthDataType.HEADACHE_MODERATE: 'HEADACHE_MODERATE',
  HealthDataType.HEADACHE_SEVERE: 'HEADACHE_SEVERE',
  HealthDataType.HEADACHE_UNSPECIFIED: 'HEADACHE_UNSPECIFIED',
  HealthDataType.NUTRITION: 'NUTRITION',
  HealthDataType.GENDER: 'GENDER',
  HealthDataType.BIRTH_DATE: 'BIRTH_DATE',
  HealthDataType.BLOOD_TYPE: 'BLOOD_TYPE',
  HealthDataType.MENSTRUATION_FLOW: 'MENSTRUATION_FLOW',
  HealthDataType.HIGH_HEART_RATE_EVENT: 'HIGH_HEART_RATE_EVENT',
  HealthDataType.LOW_HEART_RATE_EVENT: 'LOW_HEART_RATE_EVENT',
  HealthDataType.IRREGULAR_HEART_RATE_EVENT: 'IRREGULAR_HEART_RATE_EVENT',
  HealthDataType.ELECTRODERMAL_ACTIVITY: 'ELECTRODERMAL_ACTIVITY',
  HealthDataType.ELECTROCARDIOGRAM: 'ELECTROCARDIOGRAM',
  HealthDataType.TOTAL_CALORIES_BURNED: 'TOTAL_CALORIES_BURNED',
};

const _$HealthDataUnitEnumMap = {
  HealthDataUnit.GRAM: 'GRAM',
  HealthDataUnit.KILOGRAM: 'KILOGRAM',
  HealthDataUnit.OUNCE: 'OUNCE',
  HealthDataUnit.POUND: 'POUND',
  HealthDataUnit.STONE: 'STONE',
  HealthDataUnit.METER: 'METER',
  HealthDataUnit.INCH: 'INCH',
  HealthDataUnit.FOOT: 'FOOT',
  HealthDataUnit.YARD: 'YARD',
  HealthDataUnit.MILE: 'MILE',
  HealthDataUnit.LITER: 'LITER',
  HealthDataUnit.MILLILITER: 'MILLILITER',
  HealthDataUnit.FLUID_OUNCE_US: 'FLUID_OUNCE_US',
  HealthDataUnit.FLUID_OUNCE_IMPERIAL: 'FLUID_OUNCE_IMPERIAL',
  HealthDataUnit.CUP_US: 'CUP_US',
  HealthDataUnit.CUP_IMPERIAL: 'CUP_IMPERIAL',
  HealthDataUnit.PINT_US: 'PINT_US',
  HealthDataUnit.PINT_IMPERIAL: 'PINT_IMPERIAL',
  HealthDataUnit.PASCAL: 'PASCAL',
  HealthDataUnit.MILLIMETER_OF_MERCURY: 'MILLIMETER_OF_MERCURY',
  HealthDataUnit.INCHES_OF_MERCURY: 'INCHES_OF_MERCURY',
  HealthDataUnit.CENTIMETER_OF_WATER: 'CENTIMETER_OF_WATER',
  HealthDataUnit.ATMOSPHERE: 'ATMOSPHERE',
  HealthDataUnit.DECIBEL_A_WEIGHTED_SOUND_PRESSURE_LEVEL:
      'DECIBEL_A_WEIGHTED_SOUND_PRESSURE_LEVEL',
  HealthDataUnit.SECOND: 'SECOND',
  HealthDataUnit.MILLISECOND: 'MILLISECOND',
  HealthDataUnit.MINUTE: 'MINUTE',
  HealthDataUnit.HOUR: 'HOUR',
  HealthDataUnit.DAY: 'DAY',
  HealthDataUnit.JOULE: 'JOULE',
  HealthDataUnit.KILOCALORIE: 'KILOCALORIE',
  HealthDataUnit.LARGE_CALORIE: 'LARGE_CALORIE',
  HealthDataUnit.SMALL_CALORIE: 'SMALL_CALORIE',
  HealthDataUnit.DEGREE_CELSIUS: 'DEGREE_CELSIUS',
  HealthDataUnit.DEGREE_FAHRENHEIT: 'DEGREE_FAHRENHEIT',
  HealthDataUnit.KELVIN: 'KELVIN',
  HealthDataUnit.DECIBEL_HEARING_LEVEL: 'DECIBEL_HEARING_LEVEL',
  HealthDataUnit.HERTZ: 'HERTZ',
  HealthDataUnit.SIEMEN: 'SIEMEN',
  HealthDataUnit.VOLT: 'VOLT',
  HealthDataUnit.INTERNATIONAL_UNIT: 'INTERNATIONAL_UNIT',
  HealthDataUnit.COUNT: 'COUNT',
  HealthDataUnit.PERCENT: 'PERCENT',
  HealthDataUnit.BEATS_PER_MINUTE: 'BEATS_PER_MINUTE',
  HealthDataUnit.RESPIRATIONS_PER_MINUTE: 'RESPIRATIONS_PER_MINUTE',
  HealthDataUnit.MILLIGRAM_PER_DECILITER: 'MILLIGRAM_PER_DECILITER',
  HealthDataUnit.UNKNOWN_UNIT: 'UNKNOWN_UNIT',
  HealthDataUnit.NO_UNIT: 'NO_UNIT',
};

const _$HealthPlatformTypeEnumMap = {
  HealthPlatformType.appleHealth: 'appleHealth',
  HealthPlatformType.googleHealthConnect: 'googleHealthConnect',
};

const _$RecordingMethodEnumMap = {
  RecordingMethod.unknown: 'unknown',
  RecordingMethod.active: 'active',
  RecordingMethod.automatic: 'automatic',
  RecordingMethod.manual: 'manual',
};

HealthValue _$HealthValueFromJson(Map<String, dynamic> json) =>
    HealthValue()..$type = json['__type'] as String?;

Map<String, dynamic> _$HealthValueToJson(HealthValue instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  return val;
}

NumericHealthValue _$NumericHealthValueFromJson(Map<String, dynamic> json) =>
    NumericHealthValue(
      numericValue: json['numericValue'] as num,
    )..$type = json['__type'] as String?;

Map<String, dynamic> _$NumericHealthValueToJson(NumericHealthValue instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  val['numericValue'] = instance.numericValue;
  return val;
}

AudiogramHealthValue _$AudiogramHealthValueFromJson(
        Map<String, dynamic> json) =>
    AudiogramHealthValue(
      frequencies:
          (json['frequencies'] as List<dynamic>).map((e) => e as num).toList(),
      leftEarSensitivities: (json['leftEarSensitivities'] as List<dynamic>)
          .map((e) => e as num)
          .toList(),
      rightEarSensitivities: (json['rightEarSensitivities'] as List<dynamic>)
          .map((e) => e as num)
          .toList(),
    )..$type = json['__type'] as String?;

Map<String, dynamic> _$AudiogramHealthValueToJson(
    AudiogramHealthValue instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  val['frequencies'] = instance.frequencies;
  val['leftEarSensitivities'] = instance.leftEarSensitivities;
  val['rightEarSensitivities'] = instance.rightEarSensitivities;
  return val;
}

WorkoutHealthValue _$WorkoutHealthValueFromJson(Map<String, dynamic> json) =>
    WorkoutHealthValue(
      workoutActivityType: $enumDecode(
          _$HealthWorkoutActivityTypeEnumMap, json['workoutActivityType']),
      totalEnergyBurned: (json['totalEnergyBurned'] as num?)?.toInt(),
      totalEnergyBurnedUnit: $enumDecodeNullable(
          _$HealthDataUnitEnumMap, json['totalEnergyBurnedUnit']),
      totalDistance: (json['totalDistance'] as num?)?.toInt(),
      totalDistanceUnit: $enumDecodeNullable(
          _$HealthDataUnitEnumMap, json['totalDistanceUnit']),
      totalSteps: (json['totalSteps'] as num?)?.toInt(),
      totalStepsUnit:
          $enumDecodeNullable(_$HealthDataUnitEnumMap, json['totalStepsUnit']),
    )..$type = json['__type'] as String?;

Map<String, dynamic> _$WorkoutHealthValueToJson(WorkoutHealthValue instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  val['workoutActivityType'] =
      _$HealthWorkoutActivityTypeEnumMap[instance.workoutActivityType]!;
  writeNotNull('totalEnergyBurned', instance.totalEnergyBurned);
  writeNotNull('totalEnergyBurnedUnit',
      _$HealthDataUnitEnumMap[instance.totalEnergyBurnedUnit]);
  writeNotNull('totalDistance', instance.totalDistance);
  writeNotNull(
      'totalDistanceUnit', _$HealthDataUnitEnumMap[instance.totalDistanceUnit]);
  writeNotNull('totalSteps', instance.totalSteps);
  writeNotNull(
      'totalStepsUnit', _$HealthDataUnitEnumMap[instance.totalStepsUnit]);
  return val;
}

const _$HealthWorkoutActivityTypeEnumMap = {
  HealthWorkoutActivityType.AMERICAN_FOOTBALL: 'AMERICAN_FOOTBALL',
  HealthWorkoutActivityType.ARCHERY: 'ARCHERY',
  HealthWorkoutActivityType.AUSTRALIAN_FOOTBALL: 'AUSTRALIAN_FOOTBALL',
  HealthWorkoutActivityType.BADMINTON: 'BADMINTON',
  HealthWorkoutActivityType.BASEBALL: 'BASEBALL',
  HealthWorkoutActivityType.BASKETBALL: 'BASKETBALL',
  HealthWorkoutActivityType.BIKING: 'BIKING',
  HealthWorkoutActivityType.BOXING: 'BOXING',
  HealthWorkoutActivityType.CRICKET: 'CRICKET',
  HealthWorkoutActivityType.CROSS_COUNTRY_SKIING: 'CROSS_COUNTRY_SKIING',
  HealthWorkoutActivityType.CURLING: 'CURLING',
  HealthWorkoutActivityType.DOWNHILL_SKIING: 'DOWNHILL_SKIING',
  HealthWorkoutActivityType.ELLIPTICAL: 'ELLIPTICAL',
  HealthWorkoutActivityType.FENCING: 'FENCING',
  HealthWorkoutActivityType.GOLF: 'GOLF',
  HealthWorkoutActivityType.GYMNASTICS: 'GYMNASTICS',
  HealthWorkoutActivityType.HANDBALL: 'HANDBALL',
  HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING:
      'HIGH_INTENSITY_INTERVAL_TRAINING',
  HealthWorkoutActivityType.HIKING: 'HIKING',
  HealthWorkoutActivityType.HOCKEY: 'HOCKEY',
  HealthWorkoutActivityType.JUMP_ROPE: 'JUMP_ROPE',
  HealthWorkoutActivityType.KICKBOXING: 'KICKBOXING',
  HealthWorkoutActivityType.MARTIAL_ARTS: 'MARTIAL_ARTS',
  HealthWorkoutActivityType.PILATES: 'PILATES',
  HealthWorkoutActivityType.RACQUETBALL: 'RACQUETBALL',
  HealthWorkoutActivityType.ROWING: 'ROWING',
  HealthWorkoutActivityType.RUGBY: 'RUGBY',
  HealthWorkoutActivityType.RUNNING: 'RUNNING',
  HealthWorkoutActivityType.SAILING: 'SAILING',
  HealthWorkoutActivityType.SKATING: 'SKATING',
  HealthWorkoutActivityType.SNOWBOARDING: 'SNOWBOARDING',
  HealthWorkoutActivityType.SOCCER: 'SOCCER',
  HealthWorkoutActivityType.SOFTBALL: 'SOFTBALL',
  HealthWorkoutActivityType.SQUASH: 'SQUASH',
  HealthWorkoutActivityType.STAIR_CLIMBING: 'STAIR_CLIMBING',
  HealthWorkoutActivityType.SWIMMING: 'SWIMMING',
  HealthWorkoutActivityType.TABLE_TENNIS: 'TABLE_TENNIS',
  HealthWorkoutActivityType.TENNIS: 'TENNIS',
  HealthWorkoutActivityType.VOLLEYBALL: 'VOLLEYBALL',
  HealthWorkoutActivityType.WALKING: 'WALKING',
  HealthWorkoutActivityType.WATER_POLO: 'WATER_POLO',
  HealthWorkoutActivityType.YOGA: 'YOGA',
  HealthWorkoutActivityType.BARRE: 'BARRE',
  HealthWorkoutActivityType.BOWLING: 'BOWLING',
  HealthWorkoutActivityType.CARDIO_DANCE: 'CARDIO_DANCE',
  HealthWorkoutActivityType.CLIMBING: 'CLIMBING',
  HealthWorkoutActivityType.COOLDOWN: 'COOLDOWN',
  HealthWorkoutActivityType.CORE_TRAINING: 'CORE_TRAINING',
  HealthWorkoutActivityType.CROSS_TRAINING: 'CROSS_TRAINING',
  HealthWorkoutActivityType.DISC_SPORTS: 'DISC_SPORTS',
  HealthWorkoutActivityType.EQUESTRIAN_SPORTS: 'EQUESTRIAN_SPORTS',
  HealthWorkoutActivityType.FISHING: 'FISHING',
  HealthWorkoutActivityType.FITNESS_GAMING: 'FITNESS_GAMING',
  HealthWorkoutActivityType.FLEXIBILITY: 'FLEXIBILITY',
  HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING:
      'FUNCTIONAL_STRENGTH_TRAINING',
  HealthWorkoutActivityType.HAND_CYCLING: 'HAND_CYCLING',
  HealthWorkoutActivityType.HUNTING: 'HUNTING',
  HealthWorkoutActivityType.LACROSSE: 'LACROSSE',
  HealthWorkoutActivityType.MIND_AND_BODY: 'MIND_AND_BODY',
  HealthWorkoutActivityType.MIXED_CARDIO: 'MIXED_CARDIO',
  HealthWorkoutActivityType.PADDLE_SPORTS: 'PADDLE_SPORTS',
  HealthWorkoutActivityType.PICKLEBALL: 'PICKLEBALL',
  HealthWorkoutActivityType.PLAY: 'PLAY',
  HealthWorkoutActivityType.PREPARATION_AND_RECOVERY:
      'PREPARATION_AND_RECOVERY',
  HealthWorkoutActivityType.SNOW_SPORTS: 'SNOW_SPORTS',
  HealthWorkoutActivityType.SOCIAL_DANCE: 'SOCIAL_DANCE',
  HealthWorkoutActivityType.STAIRS: 'STAIRS',
  HealthWorkoutActivityType.STEP_TRAINING: 'STEP_TRAINING',
  HealthWorkoutActivityType.SURFING: 'SURFING',
  HealthWorkoutActivityType.TAI_CHI: 'TAI_CHI',
  HealthWorkoutActivityType.TRACK_AND_FIELD: 'TRACK_AND_FIELD',
  HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING:
      'TRADITIONAL_STRENGTH_TRAINING',
  HealthWorkoutActivityType.WATER_FITNESS: 'WATER_FITNESS',
  HealthWorkoutActivityType.WATER_SPORTS: 'WATER_SPORTS',
  HealthWorkoutActivityType.WHEELCHAIR_RUN_PACE: 'WHEELCHAIR_RUN_PACE',
  HealthWorkoutActivityType.WHEELCHAIR_WALK_PACE: 'WHEELCHAIR_WALK_PACE',
  HealthWorkoutActivityType.WRESTLING: 'WRESTLING',
  HealthWorkoutActivityType.BIKING_STATIONARY: 'BIKING_STATIONARY',
  HealthWorkoutActivityType.CALISTHENICS: 'CALISTHENICS',
  HealthWorkoutActivityType.DANCING: 'DANCING',
  HealthWorkoutActivityType.FRISBEE_DISC: 'FRISBEE_DISC',
  HealthWorkoutActivityType.GUIDED_BREATHING: 'GUIDED_BREATHING',
  HealthWorkoutActivityType.ICE_SKATING: 'ICE_SKATING',
  HealthWorkoutActivityType.PARAGLIDING: 'PARAGLIDING',
  HealthWorkoutActivityType.ROCK_CLIMBING: 'ROCK_CLIMBING',
  HealthWorkoutActivityType.ROWING_MACHINE: 'ROWING_MACHINE',
  HealthWorkoutActivityType.RUNNING_TREADMILL: 'RUNNING_TREADMILL',
  HealthWorkoutActivityType.SCUBA_DIVING: 'SCUBA_DIVING',
  HealthWorkoutActivityType.SKIING: 'SKIING',
  HealthWorkoutActivityType.SNOWSHOEING: 'SNOWSHOEING',
  HealthWorkoutActivityType.STAIR_CLIMBING_MACHINE: 'STAIR_CLIMBING_MACHINE',
  HealthWorkoutActivityType.STRENGTH_TRAINING: 'STRENGTH_TRAINING',
  HealthWorkoutActivityType.SWIMMING_OPEN_WATER: 'SWIMMING_OPEN_WATER',
  HealthWorkoutActivityType.SWIMMING_POOL: 'SWIMMING_POOL',
  HealthWorkoutActivityType.WALKING_TREADMILL: 'WALKING_TREADMILL',
  HealthWorkoutActivityType.WEIGHTLIFTING: 'WEIGHTLIFTING',
  HealthWorkoutActivityType.WHEELCHAIR: 'WHEELCHAIR',
  HealthWorkoutActivityType.OTHER: 'OTHER',
};

ElectrocardiogramHealthValue _$ElectrocardiogramHealthValueFromJson(
        Map<String, dynamic> json) =>
    ElectrocardiogramHealthValue(
      voltageValues: (json['voltageValues'] as List<dynamic>)
          .map((e) =>
              ElectrocardiogramVoltageValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageHeartRate: json['averageHeartRate'] as num?,
      samplingFrequency: (json['samplingFrequency'] as num?)?.toDouble(),
      classification: $enumDecodeNullable(
          _$ElectrocardiogramClassificationEnumMap, json['classification']),
    )..$type = json['__type'] as String?;

Map<String, dynamic> _$ElectrocardiogramHealthValueToJson(
    ElectrocardiogramHealthValue instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  val['voltageValues'] = instance.voltageValues.map((e) => e.toJson()).toList();
  writeNotNull('averageHeartRate', instance.averageHeartRate);
  writeNotNull('samplingFrequency', instance.samplingFrequency);
  writeNotNull('classification',
      _$ElectrocardiogramClassificationEnumMap[instance.classification]);
  return val;
}

const _$ElectrocardiogramClassificationEnumMap = {
  ElectrocardiogramClassification.NOT_SET: 'NOT_SET',
  ElectrocardiogramClassification.SINUS_RHYTHM: 'SINUS_RHYTHM',
  ElectrocardiogramClassification.ATRIAL_FIBRILLATION: 'ATRIAL_FIBRILLATION',
  ElectrocardiogramClassification.INCONCLUSIVE_LOW_HEART_RATE:
      'INCONCLUSIVE_LOW_HEART_RATE',
  ElectrocardiogramClassification.INCONCLUSIVE_HIGH_HEART_RATE:
      'INCONCLUSIVE_HIGH_HEART_RATE',
  ElectrocardiogramClassification.INCONCLUSIVE_POOR_READING:
      'INCONCLUSIVE_POOR_READING',
  ElectrocardiogramClassification.INCONCLUSIVE_OTHER: 'INCONCLUSIVE_OTHER',
  ElectrocardiogramClassification.UNRECOGNIZED: 'UNRECOGNIZED',
};

ElectrocardiogramVoltageValue _$ElectrocardiogramVoltageValueFromJson(
        Map<String, dynamic> json) =>
    ElectrocardiogramVoltageValue(
      voltage: json['voltage'] as num,
      timeSinceSampleStart: json['timeSinceSampleStart'] as num,
    )..$type = json['__type'] as String?;

Map<String, dynamic> _$ElectrocardiogramVoltageValueToJson(
    ElectrocardiogramVoltageValue instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  val['voltage'] = instance.voltage;
  val['timeSinceSampleStart'] = instance.timeSinceSampleStart;
  return val;
}

InsulinDeliveryHealthValue _$InsulinDeliveryHealthValueFromJson(
        Map<String, dynamic> json) =>
    InsulinDeliveryHealthValue(
      units: (json['units'] as num).toDouble(),
      reason: $enumDecode(_$InsulinDeliveryReasonEnumMap, json['reason']),
    )..$type = json['__type'] as String?;

Map<String, dynamic> _$InsulinDeliveryHealthValueToJson(
    InsulinDeliveryHealthValue instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  val['units'] = instance.units;
  val['reason'] = _$InsulinDeliveryReasonEnumMap[instance.reason]!;
  return val;
}

const _$InsulinDeliveryReasonEnumMap = {
  InsulinDeliveryReason.NOT_SET: 'NOT_SET',
  InsulinDeliveryReason.BASAL: 'BASAL',
  InsulinDeliveryReason.BOLUS: 'BOLUS',
};

NutritionHealthValue _$NutritionHealthValueFromJson(
        Map<String, dynamic> json) =>
    NutritionHealthValue(
      name: json['name'] as String?,
      mealType: json['mealType'] as String?,
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      caffeine: (json['caffeine'] as num?)?.toDouble(),
      vitaminA: (json['vitaminA'] as num?)?.toDouble(),
      b1Thiamine: (json['b1Thiamine'] as num?)?.toDouble(),
      b2Riboflavin: (json['b2Riboflavin'] as num?)?.toDouble(),
      b3Niacin: (json['b3Niacin'] as num?)?.toDouble(),
      b5PantothenicAcid: (json['b5PantothenicAcid'] as num?)?.toDouble(),
      b6Pyridoxine: (json['b6Pyridoxine'] as num?)?.toDouble(),
      b7Biotin: (json['b7Biotin'] as num?)?.toDouble(),
      b9Folate: (json['b9Folate'] as num?)?.toDouble(),
      b12Cobalamin: (json['b12Cobalamin'] as num?)?.toDouble(),
      vitaminC: (json['vitaminC'] as num?)?.toDouble(),
      vitaminD: (json['vitaminD'] as num?)?.toDouble(),
      vitaminE: (json['vitaminE'] as num?)?.toDouble(),
      vitaminK: (json['vitaminK'] as num?)?.toDouble(),
      calcium: (json['calcium'] as num?)?.toDouble(),
      chloride: (json['chloride'] as num?)?.toDouble(),
      cholesterol: (json['cholesterol'] as num?)?.toDouble(),
      choline: (json['choline'] as num?)?.toDouble(),
      chromium: (json['chromium'] as num?)?.toDouble(),
      copper: (json['copper'] as num?)?.toDouble(),
      fatUnsaturated: (json['fatUnsaturated'] as num?)?.toDouble(),
      fatMonounsaturated: (json['fatMonounsaturated'] as num?)?.toDouble(),
      fatPolyunsaturated: (json['fatPolyunsaturated'] as num?)?.toDouble(),
      fatSaturated: (json['fatSaturated'] as num?)?.toDouble(),
      fatTransMonoenoic: (json['fatTransMonoenoic'] as num?)?.toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      iodine: (json['iodine'] as num?)?.toDouble(),
      iron: (json['iron'] as num?)?.toDouble(),
      magnesium: (json['magnesium'] as num?)?.toDouble(),
      manganese: (json['manganese'] as num?)?.toDouble(),
      molybdenum: (json['molybdenum'] as num?)?.toDouble(),
      phosphorus: (json['phosphorus'] as num?)?.toDouble(),
      potassium: (json['potassium'] as num?)?.toDouble(),
      selenium: (json['selenium'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      water: (json['water'] as num?)?.toDouble(),
      zinc: (json['zinc'] as num?)?.toDouble(),
    )..$type = json['__type'] as String?;

Map<String, dynamic> _$NutritionHealthValueToJson(
    NutritionHealthValue instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  writeNotNull('name', instance.name);
  writeNotNull('mealType', instance.mealType);
  writeNotNull('calories', instance.calories);
  writeNotNull('protein', instance.protein);
  writeNotNull('fat', instance.fat);
  writeNotNull('carbs', instance.carbs);
  writeNotNull('caffeine', instance.caffeine);
  writeNotNull('vitaminA', instance.vitaminA);
  writeNotNull('b1Thiamine', instance.b1Thiamine);
  writeNotNull('b2Riboflavin', instance.b2Riboflavin);
  writeNotNull('b3Niacin', instance.b3Niacin);
  writeNotNull('b5PantothenicAcid', instance.b5PantothenicAcid);
  writeNotNull('b6Pyridoxine', instance.b6Pyridoxine);
  writeNotNull('b7Biotin', instance.b7Biotin);
  writeNotNull('b9Folate', instance.b9Folate);
  writeNotNull('b12Cobalamin', instance.b12Cobalamin);
  writeNotNull('vitaminC', instance.vitaminC);
  writeNotNull('vitaminD', instance.vitaminD);
  writeNotNull('vitaminE', instance.vitaminE);
  writeNotNull('vitaminK', instance.vitaminK);
  writeNotNull('calcium', instance.calcium);
  writeNotNull('chloride', instance.chloride);
  writeNotNull('cholesterol', instance.cholesterol);
  writeNotNull('choline', instance.choline);
  writeNotNull('chromium', instance.chromium);
  writeNotNull('copper', instance.copper);
  writeNotNull('fatUnsaturated', instance.fatUnsaturated);
  writeNotNull('fatMonounsaturated', instance.fatMonounsaturated);
  writeNotNull('fatPolyunsaturated', instance.fatPolyunsaturated);
  writeNotNull('fatSaturated', instance.fatSaturated);
  writeNotNull('fatTransMonoenoic', instance.fatTransMonoenoic);
  writeNotNull('fiber', instance.fiber);
  writeNotNull('iodine', instance.iodine);
  writeNotNull('iron', instance.iron);
  writeNotNull('magnesium', instance.magnesium);
  writeNotNull('manganese', instance.manganese);
  writeNotNull('molybdenum', instance.molybdenum);
  writeNotNull('phosphorus', instance.phosphorus);
  writeNotNull('potassium', instance.potassium);
  writeNotNull('selenium', instance.selenium);
  writeNotNull('sodium', instance.sodium);
  writeNotNull('sugar', instance.sugar);
  writeNotNull('water', instance.water);
  writeNotNull('zinc', instance.zinc);
  return val;
}

MenstruationFlowHealthValue _$MenstruationFlowHealthValueFromJson(
        Map<String, dynamic> json) =>
    MenstruationFlowHealthValue(
      flow: $enumDecodeNullable(_$MenstrualFlowEnumMap, json['flow']),
      dateTime: DateTime.parse(json['dateTime'] as String),
      isStartOfCycle: json['isStartOfCycle'] as bool?,
      wasUserEntered: json['wasUserEntered'] as bool?,
    )..$type = json['__type'] as String?;

Map<String, dynamic> _$MenstruationFlowHealthValueToJson(
    MenstruationFlowHealthValue instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  writeNotNull('flow', _$MenstrualFlowEnumMap[instance.flow]);
  writeNotNull('isStartOfCycle', instance.isStartOfCycle);
  writeNotNull('wasUserEntered', instance.wasUserEntered);
  val['dateTime'] = instance.dateTime.toIso8601String();
  return val;
}

const _$MenstrualFlowEnumMap = {
  MenstrualFlow.unspecified: 'unspecified',
  MenstrualFlow.none: 'none',
  MenstrualFlow.light: 'light',
  MenstrualFlow.medium: 'medium',
  MenstrualFlow.heavy: 'heavy',
  MenstrualFlow.spotting: 'spotting',
};

WorkoutSummary _$WorkoutSummaryFromJson(Map<String, dynamic> json) =>
    WorkoutSummary(
      workoutType: json['workoutType'] as String,
      totalDistance: json['totalDistance'] as num,
      totalEnergyBurned: json['totalEnergyBurned'] as num,
      totalSteps: json['totalSteps'] as num,
    );

Map<String, dynamic> _$WorkoutSummaryToJson(WorkoutSummary instance) =>
    <String, dynamic>{
      'workoutType': instance.workoutType,
      'totalDistance': instance.totalDistance,
      'totalEnergyBurned': instance.totalEnergyBurned,
      'totalSteps': instance.totalSteps,
    };
