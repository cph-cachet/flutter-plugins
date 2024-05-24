part of health;

class HealthConnectData {
  final String? uID;
  final HealthDataType? healthDataType;
  final String? packageName;

  HealthConnectData({
    required this.uID,
    required this.healthDataType,
    required this.packageName,
  });
}
