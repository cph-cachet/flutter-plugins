part of health;

/// Custom Exception for the plugin,
/// thrown whenever a Health Data Type is requested,
/// when not available on the current platform
class _HealthDataNotAvailableException implements Exception {
  HealthDataType _dataType;
  _PlatformType _platformType;

  _HealthDataNotAvailableException(this._dataType, this._platformType);

  String toString() {
    return "Method ${_dataType.toString()} not implemented for platform ${_platformType.toString()}";
  }
}

/// Extracts the string value from an enum
String _enumToString(enumItem) => enumItem.toString().split('.')[1];

enum _PlatformType { IOS, ANDROID }

