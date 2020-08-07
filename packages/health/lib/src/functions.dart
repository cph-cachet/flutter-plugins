part of health;

/// Custom Exception for the plugin,
/// thrown whenever a Health Data Type is requested,
/// when not available on the current platform
class _HealthException implements Exception {
  HealthDataType _dataType;
  String _cause;

  _HealthException(this._dataType, this._cause);

  String toString() {
    return "An exception happend when requesting type ${_dataType.toString()}. Cause: $_cause";
  }
}

/// Extracts the string value from an enum
String _enumToString(enumItem) => enumItem.toString().split('.')[1];

enum PlatformType { IOS, ANDROID }

