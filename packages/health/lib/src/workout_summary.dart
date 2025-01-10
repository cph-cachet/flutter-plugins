part of '../health.dart';

/// A [WorkoutSummary] object store vary metrics of a workout.
///
///  * [workoutType] - The type of workout. See [HealthWorkoutActivityType] for available types.
///  * [totalDistance] - The total distance that was traveled during a workout.
///  * [totalEnergyBurned] - The amount of energy that was burned during a workout.
///  * [totalSteps] - The number of steps during a workout.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class WorkoutSummary {
  /// Workout type.
  String workoutType;

  /// The total distance value of the workout.
  num totalDistance;

  /// The total energy burned value of the workout.
  num totalEnergyBurned;

  /// The total steps value of the workout.
  num totalSteps;

  WorkoutSummary({
    required this.workoutType,
    required this.totalDistance,
    required this.totalEnergyBurned,
    required this.totalSteps,
  });

  /// Create a [WorkoutSummary] based on a health data point from native data format.
  factory WorkoutSummary.fromHealthDataPoint(dynamic dataPoint) =>
      WorkoutSummary(
        workoutType: dataPoint['workout_type'] as String? ?? '',
        totalDistance: dataPoint['total_distance'] as num? ?? 0,
        totalEnergyBurned: dataPoint['total_energy_burned'] as num? ?? 0,
        totalSteps: dataPoint['total_steps'] as num? ?? 0,
      );

  /// Create a [HealthDataPoint] from json.
  factory WorkoutSummary.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSummaryFromJson(json);

  /// Convert this [HealthDataPoint] to json.
  Map<String, dynamic> toJson() => _$WorkoutSummaryToJson(this);

  @override
  String toString() => '$runtimeType - '
      'workoutType: $workoutType'
      'totalDistance: $totalDistance, '
      'totalEnergyBurned: $totalEnergyBurned, '
      'totalSteps: $totalSteps';
}
