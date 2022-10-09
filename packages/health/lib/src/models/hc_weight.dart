part of health;

class HealthConnectWeight extends HealthConnectData {
  final String uID;
  final Mass weight;
  final String zonedDateTime;
  final HealthDataType healthDataType;

  HealthConnectWeight(
      this.uID, this.weight, this.zonedDateTime, this.healthDataType)
      : super(uID, healthDataType);

  factory HealthConnectWeight.fromJson(json, HealthDataType healthDataType) =>
      HealthConnectWeight(
          json['uid'],
          Mass(json['weight'],),
          json['zonedDateTime'],
          healthDataType);

  /// Converts the [HealthDataPoint] to a json object
  Map<String, dynamic> toJson() => {
        'uid': uID,
        'weight': weight.getInKilograms,
        'zonedDateTime': zonedDateTime,
      };

  @override
  String toString() => '${this.runtimeType} - '
      'uid: $uID, '
      'weight: $weight, '
      'zonedDateTime: $zonedDateTime, ';
}
