import 'dart:async';

import 'package:flutter/services.dart';

class Pedometer {
  static const EventChannel _eventChannel =
      const EventChannel("pedometer.eventChannel");

  Stream<int> _pedometerStream;

  Stream<int> get stepCountStream {
    if (_pedometerStream == null) {
      _pedometerStream =
          _eventChannel.receiveBroadcastStream().map((stepCount) => stepCount);
    }
    return _pedometerStream;
  }

}
