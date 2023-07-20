import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Custom Exception for the plugin,
/// thrown whenever the plugin is used on platforms other than Android
class LightException implements Exception {
  String cause;
  LightException(this.cause);
  @override
  String toString() => "$runtimeType - $cause";
}

class Light {
  static Light? _singleton;
  static const EventChannel _eventChannel =
      const EventChannel("light.eventChannel");

  /// Constructs a singleton instance of [Light].
  ///
  /// [Light] is designed to work as a singleton.
  factory Light() => _singleton ??= Light._();

  Light._();

  Stream<int>? _lightSensorStream;

  /// The stream of light events.
  /// Throws a [LightException] if device isn't on Android.
  Stream<int> get lightSensorStream {
    if (!Platform.isAndroid)
      throw LightException('Light sensor API only available on Android.');

    return _lightSensorStream ??=
        _eventChannel.receiveBroadcastStream().map((lux) => lux);
  }
}
