import 'dart:async';

import 'package:flutter/services.dart';

class Pedometer {
  static const EventChannel _eventChannel =
      const EventChannel("pedometer.eventChannel");

  /// The pedometer stream will continuously return the cumulative number of
  /// steps taken since the application was started.
  /// A step count is an [int] value.
  Stream<int> _pedometerStream;

  /// The stream which is subscribed to
  Stream<int> get pedometerStream {
    if (_pedometerStream == null) {
      _pedometerStream = _eventChannel.receiveBroadcastStream().map((value) => value);
    }
    return _pedometerStream;
  }
}
