part of health;

/// Custom Exception for the plugin,
/// thrown whenever a Health Data Type is requested,
/// when not available on the current platform
class _HealthException implements Exception {
  dynamic _dataType;
  String _cause;

  _HealthException(this._dataType, this._cause);

  String toString() {
    return "An exception happened when requesting ${_dataType.toString()}. Cause: $_cause";
  }
}

/// Extracts the string value from an enum
String _enumToString(enumItem) => enumItem.toString().split('.').last;

enum PlatformType { IOS, ANDROID }
