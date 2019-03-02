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

  Stream<int> _lightStream;

  /// Getter for light stream, throws an exception if device isn't on Android platform
  Stream<int> get lightStream {
    if (Platform.isAndroid) {
      _lightStream = _eventChannel.receiveBroadcastStream().map((lux) => lux);
      return _lightStream;
    }
    throw LightException('Light sensor API exclusively available on Android!');
  }

/// Getter for light stream, returns null if device isn't on Android platform
//  Stream<int> get lightStream {
//    assert(Platform.isAndroid, '[light]: Light sensor API exclusively available on Android!');
//
//    if (Platform.isAndroid) {
//      _lightStream = _eventChannel.receiveBroadcastStream().map((lux) => lux);
//      return _lightStream;
//    }
//    return null;
//  }
}
