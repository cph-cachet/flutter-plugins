part of health;

/// Custom Exception for the plugin. Used when a Health Data Type is requested,
/// but not available on the current platform.
class HealthException implements Exception {
  dynamic dataType;
  String cause;

  HealthException(this.dataType, this.cause);

  String toString() =>
      "Error requesting health data type '$dataType' - cause: $cause";
}

/// Extracts the string value from an enum
String _enumToString(enumItem) => enumItem.toString().split('.').last;

extension HealthWorkoutActivityTypeToStringExtension
    on HealthWorkoutActivityType {
  /// Returns the string representation of the enum
  /// e.g. [HealthWorkoutActivityType.CYCLING] -> 'CYCLING'
  String typeToString() => _enumToString(this);
}

extension HealthDataTypeToStringExtension on HealthDataType {
  /// Returns the string representation of the enum
  /// e.g. [HealthDataType.BLOOD_GLUCOSE] -> 'BLOOD_GLUCOSE'
  String typeToString() => _enumToString(this);
}

extension HealthDataUnitToStringExtension on HealthDataUnit {
  /// Returns the string representation of the enum
  /// e.g. [HealthDataUnit.LITER] -> 'LITER'
  String typeToString() => _enumToString(this);
}

/// A list of supported platforms.
enum PlatformType { IOS, ANDROID }
