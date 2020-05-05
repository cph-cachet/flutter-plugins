import 'dart:async';

import 'package:flutter/services.dart';

class Pedometer {
  static const EventChannel _eventChannel =
      const EventChannel("pedometer.eventChannel");

  /// The pedometer stream will continuously return the cumulative number of
  /// steps taken since the application was started.
  /// A step count is an [int] value.
  Stream<int> _pedometerStream;

  /// Keep track at the step count at plugin start-up
  /// -1 indicates the value is 'clean'
  int _stepsAtPluginStart = -1;

  /// The stream which is subscribed to
  Stream<int> get pedometerStream {
    if (_pedometerStream == null) {
      _pedometerStream = _eventChannel.receiveBroadcastStream().map((value) {
        /// If the [_stepsAtPluginStart] is 'clean'
        /// then set it to the first step count value, and make it dirty/
        if (_stepsAtPluginStart == -1) {
          _stepsAtPluginStart = value;
        }
        /// The value returned from iOS/Android is step counts since last boot.
        /// Therefore the [_stepsAtPluginStart] is subtracted from this value.
        return value - _stepsAtPluginStart;
      });
    }
    return _pedometerStream;
  }
}
