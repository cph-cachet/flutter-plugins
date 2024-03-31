part of '../health.dart';

/// An abstract class for health values.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class HealthValue extends Serializable {
  HealthValue();

  @override
  Function get fromJsonFunction => _$HealthValueFromJson;
  factory HealthValue.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json) as HealthValue;
  @override
  Map<String, dynamic> toJson() => _$HealthValueToJson(this);
}

/// A numerical value from Apple HealthKit or Google Fit
/// such as integer or double. E.g. 1, 2.9, -3
///
/// Parameters:
/// * [numericValue] - a [num] value for the [HealthDataPoint]
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class NumericHealthValue extends HealthValue {
  /// A [num] value for the [HealthDataPoint].
  num numericValue;

  NumericHealthValue({required this.numericValue});

  /// Create a [NumericHealthValue] based on a health data point from native data format.
  factory NumericHealthValue.fromHealthDataPoint(dynamic dataPoint) =>
      NumericHealthValue(numericValue: dataPoint['value'] as num? ?? 0);

  @override
  String toString() => '$runtimeType - numericValue: $numericValue';

  @override
  Function get fromJsonFunction => _$NumericHealthValueFromJson;
  factory NumericHealthValue.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json) as NumericHealthValue;
  @override
  Map<String, dynamic> toJson() => _$NumericHealthValueToJson(this);

  @override
  bool operator ==(Object other) =>
      other is NumericHealthValue && numericValue == other.numericValue;

  @override
  int get hashCode => numericValue.hashCode;
}

/// A [HealthValue] object for audiograms
///
/// Parameters:
/// * [frequencies] - array of frequencies of the test
/// * [leftEarSensitivities] threshold in decibel for the left ear
/// * [rightEarSensitivities] threshold in decibel for the left ear
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class AudiogramHealthValue extends HealthValue {
  /// Array of frequencies of the test.
  List<num> frequencies;

  /// Threshold in decibel for the left ear.
  List<num> leftEarSensitivities;

  /// Threshold in decibel for the right ear.
  List<num> rightEarSensitivities;

  AudiogramHealthValue({
    required this.frequencies,
    required this.leftEarSensitivities,
    required this.rightEarSensitivities,
  });

  /// Create a [AudiogramHealthValue] based on a health data point from native data format.
  factory AudiogramHealthValue.fromHealthDataPoint(dynamic dataPoint) =>
      AudiogramHealthValue(
          frequencies: List<num>.from(dataPoint['frequencies'] as List),
          leftEarSensitivities:
              List<num>.from(dataPoint['leftEarSensitivities'] as List),
          rightEarSensitivities:
              List<num>.from(dataPoint['rightEarSensitivities'] as List));

  @override
  String toString() => """$runtimeType - frequencies: ${frequencies.toString()},
    left ear sensitivities: ${leftEarSensitivities.toString()},
    right ear sensitivities: ${rightEarSensitivities.toString()}""";

  @override
  Function get fromJsonFunction => _$AudiogramHealthValueFromJson;
  factory AudiogramHealthValue.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json) as AudiogramHealthValue;
  @override
  Map<String, dynamic> toJson() => _$AudiogramHealthValueToJson(this);

  @override
  bool operator ==(Object other) =>
      other is AudiogramHealthValue &&
      listEquals(frequencies, other.frequencies) &&
      listEquals(leftEarSensitivities, other.leftEarSensitivities) &&
      listEquals(rightEarSensitivities, other.rightEarSensitivities);

  @override
  int get hashCode =>
      Object.hash(frequencies, leftEarSensitivities, rightEarSensitivities);
}

/// A [HealthValue] object for workouts
///
/// Parameters:
/// * [workoutActivityType] - the type of workout
/// * [totalEnergyBurned] - the total energy burned during the workout
/// * [totalEnergyBurnedUnit] - the unit of the total energy burned
/// * [totalDistance] - the total distance of the workout
/// * [totalDistanceUnit] - the unit of the total distance
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class WorkoutHealthValue extends HealthValue {
  /// The type of the workout.
  HealthWorkoutActivityType workoutActivityType;

  /// The total energy burned during the workout.
  /// Might not be available for all workouts.
  int? totalEnergyBurned;

  /// The unit of the total energy burned during the workout.
  /// Might not be available for all workouts.
  HealthDataUnit? totalEnergyBurnedUnit;

  /// The total distance covered during the workout.
  /// Might not be available for all workouts.
  int? totalDistance;

  /// The unit of the total distance covered during the workout.
  /// Might not be available for all workouts.
  HealthDataUnit? totalDistanceUnit;

  /// The total steps covered during the workout.
  /// Might not be available for all workouts.
  int? totalSteps;

  /// The unit of the total steps covered during the workout.
  /// Might not be available for all workouts.
  HealthDataUnit? totalStepsUnit;

  WorkoutHealthValue(
      {required this.workoutActivityType,
      this.totalEnergyBurned,
      this.totalEnergyBurnedUnit,
      this.totalDistance,
      this.totalDistanceUnit,
      this.totalSteps,
      this.totalStepsUnit});

  /// Create a [WorkoutHealthValue] based on a health data point from native data format.
  factory WorkoutHealthValue.fromHealthDataPoint(dynamic dataPoint) =>
      WorkoutHealthValue(
          workoutActivityType: HealthWorkoutActivityType.values.firstWhere(
              (element) => element.name == dataPoint['workoutActivityType']),
          totalEnergyBurned: dataPoint['totalEnergyBurned'] != null
              ? (dataPoint['totalEnergyBurned'] as num).toInt()
              : null,
          totalEnergyBurnedUnit: dataPoint['totalEnergyBurnedUnit'] != null
              ? HealthDataUnit.values.firstWhere((element) =>
                  element.name == dataPoint['totalEnergyBurnedUnit'])
              : null,
          totalDistance: dataPoint['totalDistance'] != null
              ? (dataPoint['totalDistance'] as num).toInt()
              : null,
          totalDistanceUnit: dataPoint['totalDistanceUnit'] != null
              ? HealthDataUnit.values.firstWhere(
                  (element) => element.name == dataPoint['totalDistanceUnit'])
              : null,
          totalSteps: dataPoint['totalSteps'] != null
              ? (dataPoint['totalSteps'] as num).toInt()
              : null,
          totalStepsUnit: dataPoint['totalStepsUnit'] != null
              ? HealthDataUnit.values.firstWhere(
                  (element) => element.name == dataPoint['totalStepsUnit'])
              : null);

  @override
  Function get fromJsonFunction => _$WorkoutHealthValueFromJson;
  factory WorkoutHealthValue.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json) as WorkoutHealthValue;
  @override
  Map<String, dynamic> toJson() => _$WorkoutHealthValueToJson(this);

  @override
  String toString() =>
      """$runtimeType - workoutActivityType: ${workoutActivityType.name},
           totalEnergyBurned: $totalEnergyBurned,
           totalEnergyBurnedUnit: ${totalEnergyBurnedUnit?.name},
           totalDistance: $totalDistance,
           totalDistanceUnit: ${totalDistanceUnit?.name}
           totalSteps: $totalSteps,
           totalStepsUnit: ${totalStepsUnit?.name}""";

  @override
  bool operator ==(Object other) =>
      other is WorkoutHealthValue &&
      workoutActivityType == other.workoutActivityType &&
      totalEnergyBurned == other.totalEnergyBurned &&
      totalEnergyBurnedUnit == other.totalEnergyBurnedUnit &&
      totalDistance == other.totalDistance &&
      totalDistanceUnit == other.totalDistanceUnit &&
      totalSteps == other.totalSteps &&
      totalStepsUnit == other.totalStepsUnit;

  @override
  int get hashCode => Object.hash(
      workoutActivityType,
      totalEnergyBurned,
      totalEnergyBurnedUnit,
      totalDistance,
      totalDistanceUnit,
      totalSteps,
      totalStepsUnit);
}

/// A [HealthValue] object for ECGs
///
/// Parameters:
/// * [voltageValues] - an array of [ElectrocardiogramVoltageValue]s
/// * [averageHeartRate] - the average heart rate during the ECG (in BPM)
/// * [samplingFrequency] - the frequency at which the Apple Watch sampled the voltage.
/// * [classification] - an [ElectrocardiogramClassification]
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ElectrocardiogramHealthValue extends HealthValue {
  /// An array of [ElectrocardiogramVoltageValue]s.
  List<ElectrocardiogramVoltageValue> voltageValues;

  /// The average heart rate during the ECG (in BPM).
  num? averageHeartRate;

  /// The frequency at which the Apple Watch sampled the voltage.
  double? samplingFrequency;

  /// An [ElectrocardiogramClassification].
  ElectrocardiogramClassification? classification;

  ElectrocardiogramHealthValue({
    required this.voltageValues,
    this.averageHeartRate,
    this.samplingFrequency,
    this.classification,
  });

  @override
  Function get fromJsonFunction => _$ElectrocardiogramHealthValueFromJson;
  factory ElectrocardiogramHealthValue.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json) as ElectrocardiogramHealthValue;
  @override
  Map<String, dynamic> toJson() => _$ElectrocardiogramHealthValueToJson(this);

  /// Create a [ElectrocardiogramHealthValue] based on a health data point from native data format.
  factory ElectrocardiogramHealthValue.fromHealthDataPoint(dynamic dataPoint) =>
      ElectrocardiogramHealthValue(
        voltageValues: (dataPoint['voltageValues'] as List)
            .map((voltageValue) =>
                ElectrocardiogramVoltageValue.fromHealthDataPoint(voltageValue))
            .toList(),
        averageHeartRate: dataPoint['averageHeartRate'] as num?,
        samplingFrequency: dataPoint['samplingFrequency'] as double?,
        classification: ElectrocardiogramClassification.values
            .firstWhere((c) => c.value == dataPoint['classification']),
      );

  @override
  bool operator ==(Object other) =>
      other is ElectrocardiogramHealthValue &&
      voltageValues == other.voltageValues &&
      averageHeartRate == other.averageHeartRate &&
      samplingFrequency == other.samplingFrequency &&
      classification == other.classification;

  @override
  int get hashCode => Object.hash(
      voltageValues, averageHeartRate, samplingFrequency, classification);

  @override
  String toString() =>
      '$runtimeType - ${voltageValues.length} values, $averageHeartRate BPM, $samplingFrequency HZ, $classification';
}

/// Single voltage value belonging to a [ElectrocardiogramHealthValue]
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ElectrocardiogramVoltageValue extends HealthValue {
  /// Voltage of the ECG.
  num voltage;

  /// Time since the start of the ECG.
  num timeSinceSampleStart;

  ElectrocardiogramVoltageValue({
    required this.voltage,
    required this.timeSinceSampleStart,
  });

  /// Create a [ElectrocardiogramVoltageValue] based on a health data point from native data format.
  factory ElectrocardiogramVoltageValue.fromHealthDataPoint(
          dynamic dataPoint) =>
      ElectrocardiogramVoltageValue(
          voltage: dataPoint['voltage'] as num,
          timeSinceSampleStart: dataPoint['timeSinceSampleStart'] as num);

  @override
  Function get fromJsonFunction => _$ElectrocardiogramVoltageValueFromJson;
  factory ElectrocardiogramVoltageValue.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json) as ElectrocardiogramVoltageValue;
  @override
  Map<String, dynamic> toJson() => _$ElectrocardiogramVoltageValueToJson(this);

  @override
  bool operator ==(Object other) =>
      other is ElectrocardiogramVoltageValue &&
      voltage == other.voltage &&
      timeSinceSampleStart == other.timeSinceSampleStart;

  @override
  int get hashCode => Object.hash(voltage, timeSinceSampleStart);

  @override
  String toString() => '$runtimeType - voltage: $voltage';
}

/// A [HealthValue] object for nutrition.
///
/// Parameters:
///  * [protein] - the amount of protein in grams
///  * [calories] - the amount of calories in kcal
///  * [fat] - the amount of fat in grams
///  * [name] - the name of the food
///  * [carbs] - the amount of carbs in grams
///  * [caffeine] - the amount of caffeine in grams
///  * [mealType] - the type of meal
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class NutritionHealthValue extends HealthValue {
  /// The type of meal.
  String? mealType;

  /// The amount of protein in grams.
  double? protein;

  /// The amount of calories in kcal.
  double? calories;

  /// The amount of fat in grams.
  double? fat;

  /// The name of the food.
  String? name;

  /// The amount of carbs in grams.
  double? carbs;

  /// The amount of caffeine in grams.
  double? caffeine;

  NutritionHealthValue({
    this.mealType,
    this.protein,
    this.calories,
    this.fat,
    this.name,
    this.carbs,
    this.caffeine,
  });

  @override
  Function get fromJsonFunction => _$NutritionHealthValueFromJson;
  factory NutritionHealthValue.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json) as NutritionHealthValue;
  @override
  Map<String, dynamic> toJson() => _$NutritionHealthValueToJson(this);

  /// Create a [NutritionHealthValue] based on a health data point from native data format.
  factory NutritionHealthValue.fromHealthDataPoint(dynamic dataPoint) =>
      NutritionHealthValue(
        mealType: dataPoint['mealType'] as String,
        protein: dataPoint['protein'] != null
            ? (dataPoint['protein'] as num).toDouble()
            : null,
        calories: dataPoint['calories'] != null
            ? (dataPoint['calories'] as num).toDouble()
            : null,
        fat: dataPoint['fat'] != null
            ? (dataPoint['fat'] as num).toDouble()
            : null,
        name: dataPoint['name'] != null ? (dataPoint['name'] as String) : null,
        carbs: dataPoint['carbs'] != null
            ? (dataPoint['carbs'] as num).toDouble()
            : null,
        caffeine: dataPoint['caffeine'] != null
            ? (dataPoint['caffeine'] as num).toDouble()
            : null,
      );

  @override
  String toString() => """$runtimeType - protein: ${protein.toString()},
    calories: ${calories.toString()},
    fat: ${fat.toString()},
    name: ${name.toString()},
    carbs: ${carbs.toString()},
    caffeine: ${caffeine.toString()},
    mealType: $mealType""";

  @override
  bool operator ==(Object other) =>
      other is NutritionHealthValue &&
      other.protein == protein &&
      other.calories == calories &&
      other.fat == fat &&
      other.name == name &&
      other.carbs == carbs &&
      other.caffeine == caffeine &&
      other.mealType == mealType;

  @override
  int get hashCode =>
      Object.hash(protein, calories, fat, name, carbs, caffeine);
}
