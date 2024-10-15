part of '../health.dart';

/// A [WorkoutSummary] object store vary metrics of a workout.
///
///  * [workoutType] - The type of workout. See [HealthWorkoutActivityType] for available types.
///  * [totalDistance] - The total distance that was traveled during a workout.
///  * [totalEnergyBurned] - The amount of energy that was burned during a workout.
///  * [totalSteps] - The number of steps during a workout.
///  * [route] - The route of the workout.
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

  /// The route of the workout.
  List<RoutePoint>? route;

  WorkoutSummary({
    required this.workoutType,
    required this.totalDistance,
    required this.totalEnergyBurned,
    required this.totalSteps,
    this.route,
  });

  /// Create a [WorkoutSummary] based on a health data point from native data format.
  factory WorkoutSummary.fromHealthDataPoint(dynamic dataPoint) =>
      WorkoutSummary(
        workoutType: dataPoint['workout_type'] as String? ?? '',
        totalDistance: dataPoint['total_distance'] as num? ?? 0,
        totalEnergyBurned: dataPoint['total_energy_burned'] as num? ?? 0,
        totalSteps: dataPoint['total_steps'] as num? ?? 0,
        route: (dataPoint['route'] as List<dynamic>?)?.isNotEmpty ?? false
            ? (dataPoint['route'] as List<dynamic>?)!
                .map((l) => RoutePoint(
                    longitude: l['longitude'] as double,
                    latitude: l['latitude'] as double,
                    altitude: l['altitude'] as double,
                    timestamp: l['timestamp'] as int,
                    horizontalAccuracy: l['horizontal_accuracy'] as double?,
                    verticalAccuracy: l['vertical_accuracy'] as double?))
                .toList()
            : null,
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
      'totalSteps: $totalSteps, '
      'route: ${route?.map((l) => l.toString()).join('\n')}';
}
