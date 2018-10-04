import 'dart:async';

import 'package:flutter/services.dart';

class Light {
  static const EventChannel _eventChannel =
      const EventChannel("flutter_light.eventChannel");

  Stream<int> _onLightSensorEvent;

  Stream<int> get lightSensorStream {
    if (_onLightSensorEvent == null) {
      _onLightSensorEvent =
          _eventChannel.receiveBroadcastStream().map((lux) => lux);
    }
    return _onLightSensorEvent;
  }
}
