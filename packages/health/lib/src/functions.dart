part of '../health.dart';

/// Custom Exception for the plugin. Used when a Health Data Type is requested,
/// but not available on the current platform.
class HealthException implements Exception {
  /// Data Type that was requested.
  dynamic dataType;

  /// Cause of the exception.
  String cause;

  HealthException(this.dataType, this.cause);

  @override
  String toString() =>
      "Error requesting health data type '$dataType' - cause: $cause";
}

/// A list of supported platforms.
enum PlatformType { IOS, ANDROID }

/// Health Connect availability status.
///
/// NOTE:
/// The enum order is arbitrary. If you need the native value, use [nativeValue] and not the index.
///
/// Reference:
/// https://developer.android.com/reference/kotlin/androidx/health/connect/client/HealthConnectClient#constants_1
enum HealthConnectAvailability {
  /// https://developer.android.com/reference/kotlin/androidx/health/connect/client/HealthConnectClient#SDK_UNAVAILABLE()
  NOT_SUPPORT(1),

  /// https://developer.android.com/reference/kotlin/androidx/health/connect/client/HealthConnectClient#SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED()
  NOT_INSTALL(2),

  /// https://developer.android.com/reference/kotlin/androidx/health/connect/client/HealthConnectClient#SDK_AVAILABLE()
  INSTALLED(3);

  const HealthConnectAvailability(this.nativeValue);

  /// The native value that matches the value in the Android SDK.
  final int nativeValue;

  factory HealthConnectAvailability.fromNativeValue(int value) {
    return HealthConnectAvailability.values.firstWhere(
            (e) => e.nativeValue == value,
        orElse: () => HealthConnectAvailability.NOT_SUPPORT);
  }
}
