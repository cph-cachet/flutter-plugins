import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class Light {
  static const EventChannel _eventChannel =
      const EventChannel("light.eventChannel");

  Stream<int> _onLightSensorEvent;

  Stream<int> get lightSensorStream {
    if (_onLightSensorEvent == null) {
      _onLightSensorEvent =
          _eventChannel.receiveBroadcastStream().map((lux) => lux);
    }
    return _onLightSensorEvent;
  }

  StreamSubscription<int> listen(void onData(int event),
      {Function onError, void onDone(), bool cancelOnError}) {
    if (Platform.isAndroid) {
      return lightSensorStream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: true);
    }
    print('[light]: Light sensor API not available on iOS!');
    return null;
  }
}
