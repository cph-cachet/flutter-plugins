import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class Light {
  static const EventChannel _eventChannel =
      const EventChannel("light.eventChannel");

  Stream<int> _lightStream;
  StreamSubscription<int> _lightStreamSubScription;

  /// Start listening to the light sensor, but only if on an Android device.
  void listen(void onData(int event),
      {Function onError, void onDone(), bool cancelOnError}) {
    if (Platform.isAndroid) {
      _lightStream = _eventChannel.receiveBroadcastStream().map((lux) => lux);
      _lightStream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: true);
    } else {
      print('[light]: Light sensor API not available on iOS!');
    }
  }

  /// Cancel the subscription, if it has been started.
  void cancel() {
    if (_lightStreamSubScription != null) {
      _lightStreamSubScription.cancel();
    }
  }
}
