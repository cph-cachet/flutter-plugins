part of health;

class HealthConnectHydration extends HealthConnectData {
  /// in milliliters
  final double volume;
  final DateTime startTime;
  final DateTime endTime;

  HealthConnectHydration(
    this.startTime,
    this.endTime, {
    required super.uID,
    required super.packageName,
    required this.volume,
    required super.healthDataType,
  });

  factory HealthConnectHydration.fromJson(json, HealthDataType healthDataType) => HealthConnectHydration(
        DateTime.fromMillisecondsSinceEpoch(json['startDateTime']),
        DateTime.fromMillisecondsSinceEpoch(json['endDateTime']),
        uID: json['uid'],
        packageName: json['packageName'],
        volume: json['volume'],
        healthDataType: healthDataType,
      );

  /// Converts the [HealthDataPoint] to a json object
  Map<String, dynamic> toJson() => {
        'startTime': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startTime).toString(),
        'endTime': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(endTime).toString(),
        'uid': uID,
        'volume': volume,
      };

  @override
  String toString() => '${this.runtimeType} - '
      '${toJson().toString()}';

  /// Adds two hydrations. The resulting package name is null if the package names are different. uID is null.
  HealthConnectHydration operator +(HealthConnectHydration other) {
    final sum = volume + other.volume;
    final newPackageName = packageName == other.packageName ? packageName : null;
    final newStartTime = startTime.isBefore(other.startTime) ? startTime : other.startTime;
    final newEndTime = endTime.isAfter(other.endTime) ? endTime : other.endTime;
    return HealthConnectHydration(
      newStartTime,
      newEndTime,
      uID: null,
      packageName: newPackageName,
      volume: sum,
      healthDataType: healthDataType,
    );
  }
}
