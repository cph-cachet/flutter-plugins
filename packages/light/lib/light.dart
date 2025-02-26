import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class Light {
  static Light? _instance;
  static const EventChannel _eventChannel = EventChannel("light.eventChannel");

  /// Constructs a singleton instance of [Light].
  ///
  /// [Light] is designed to work as a singleton.
  factory Light() => _instance ??= Light._();

  Light._();

  Stream<int>? _lightSensorStream;

  /// The stream of light events.
  ///
  /// Return an empty Stream if this device isn't Android or if the accessing
  /// the light sensor fails.
  Stream<int> get lightSensorStream {
    try {
      return (Platform.isAndroid)
          ? _lightSensorStream ??= _eventChannel
              .receiveBroadcastStream()
              .map((lux) => int.tryParse(lux.toString()) ?? -1)
          : Stream<int>.empty();
    } catch (_) {
      return Stream<int>.empty();
    }
  }
}
