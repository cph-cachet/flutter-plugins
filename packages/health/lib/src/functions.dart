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

/// A list of supported platforms.
enum PlatformType { IOS, ANDROID }
