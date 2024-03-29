part of '../health.dart';

/// A [WorkoutSummary] object store vary metrics of a workout.
///  * totalDistance - The total distance that was traveled during a workout.
///  * totalEnergyBurned - The amount of energy that was burned during a workout.
///  * totalSteps - The count of steps was burned during a workout.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class WorkoutSummary {
  /// Workout type.
  String workoutType;

  /// The total distance value of the workout.
  num totalDistance;

  /// The total energy burned value of the workout.
  num totalEnergyBurned;

  /// The total steps value of the workout.
  num totalSteps;

  WorkoutSummary(
    this.workoutType,
    this.totalDistance,
    this.totalEnergyBurned,
    this.totalSteps,
  );

  /// Create a [HealthDataPoint] from json.
  factory WorkoutSummary.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSummaryFromJson(json);

  /// Convert this [HealthDataPoint] to json.
  Map<String, dynamic> toJson() => _$WorkoutSummaryToJson(this);

  // /// Converts a json object to the [WorkoutSummary]
  // factory WorkoutSummary.fromJson(json) => WorkoutSummary(
  //       json['workoutType'],
  //       json['totalDistance'],
  //       json['totalEnergyBurned'],
  //       json['totalSteps'],
  //     );

  // /// Converts the [WorkoutSummary] to a json object
  // Map<String, dynamic> toJson() => {
  //       'workoutType': workoutType,
  //       'totalDistance': totalDistance,
  //       'totalEnergyBurned': totalEnergyBurned,
  //       'totalSteps': totalSteps
  //     };

  @override
  String toString() => '$runtimeType - '
      'workoutType: $workoutType'
      'totalDistance: $totalDistance, '
      'totalEnergyBurned: $totalEnergyBurned, '
      'totalSteps: $totalSteps';
}
