import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Custom Exception for the plugin,
/// thrown whenever the plugin is used on platforms other than Android
class LightException implements Exception {
  String _cause;

  LightException(this._cause);

  @override
  String toString() {
    return _cause;
  }
}

class Light {
  static const EventChannel _eventChannel =
      const EventChannel("light.eventChannel");

  Stream<int> _lightSensorStream;

  /// Getter for light stream, throws an exception if device isn't on Android platform
  Stream<int> get lightSensorStream {
    if (Platform.isAndroid) {
      if (_lightSensorStream == null) {
        _lightSensorStream =
            _eventChannel.receiveBroadcastStream().map((lux) => lux);
      }
      return _lightSensorStream;
    }
    throw LightException('Light sensor API exclusively available on Android!');
  }
}
