part of health;

class HealthConnectWeight extends HealthConnectData {
  final Mass weight;
  final DateTime zonedDateTime;

  HealthConnectWeight({
    super.uID,
    required this.weight,
    required this.zonedDateTime,
    required super.healthDataType,
    super.packageName,
  });

  factory HealthConnectWeight.fromJson(json, HealthDataType healthDataType) {
    print(json);
    return HealthConnectWeight(
      uID: json['uid'],
      packageName: json['packageName'],
      weight: Mass(
        json['weight'],
      ),
      zonedDateTime:
          DateTime.fromMillisecondsSinceEpoch((json['zonedDateTime'] as int)),
      healthDataType: healthDataType,
    );
  }

  /// Converts the [HealthDataPoint] to a json object
  Map<String, dynamic> toJson() => {
        'uid': uID,
        'weight': weight.kilograms,
        'zonedDateTime': zonedDateTime,
      };

  @override
  String toString() => '${this.runtimeType} - '
      'uid: $uID, '
      'packageName: $packageName, '
      'weight: $weight, '
      'zonedDateTime: $zonedDateTime, ';
}
