import 'dart:async';

import 'package:flutter/services.dart';

class Pedometer {
  static const EventChannel _eventChannel = const EventChannel("flutter_pedometer.eventChannel");

  Stream<int> _onStepCountEvent;

  Stream<int> get stepCountStream {
    if (_onStepCountEvent == null) {
      _onStepCountEvent = _eventChannel.receiveBroadcastStream().map((element) => element);
    }
    return _onStepCountEvent;
  }
}
