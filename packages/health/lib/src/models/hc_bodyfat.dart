part of health;

class HealthConnectBodyFat extends HealthConnectData {
  final double bodyFat;
  final DateTime zonedDateTime;

  HealthConnectBodyFat({
    required super.uID,
    required super.packageName,
    required this.bodyFat,
    required this.zonedDateTime,
    required super.healthDataType,
  });

  factory HealthConnectBodyFat.fromJson(json, HealthDataType healthDataType) =>
      HealthConnectBodyFat(
          uID: json['uid'],
          packageName: json['packageName'],
          bodyFat: json['bodyFat'],
          zonedDateTime: DateTime.fromMillisecondsSinceEpoch(
              (json['zonedDateTime'] as int)),
          healthDataType: healthDataType);

  /// Converts the [HealthDataPoint] to a json object
  Map<String, dynamic> toJson() => {
        'uid': uID,
        'bodyFat': bodyFat,
        'zonedDateTime': zonedDateTime,
      };

  @override
  String toString() => '${this.runtimeType} - '
      'uid: $uID, '
      'bodyFat: $bodyFat, '
      'zonedDateTime: $zonedDateTime, ';
}
