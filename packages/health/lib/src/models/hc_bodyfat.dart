part of health;

class HealthConnectBodyFat extends HealthConnectData {
  final String uID;
  final double bodyFat;
  final DateTime zonedDateTime;
  final HealthDataType healthDataType;

  HealthConnectBodyFat(
      {required this.uID,
      required this.bodyFat,
      required this.zonedDateTime,
      required this.healthDataType})
      : super(uID, healthDataType);

  factory HealthConnectBodyFat.fromJson(json, HealthDataType healthDataType) =>
      HealthConnectBodyFat(
          uID: json['uid'],
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
