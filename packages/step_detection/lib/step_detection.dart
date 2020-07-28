import 'dart:async';

import 'package:flutter/services.dart';

class StepDetection {
  static const EventChannel _channel = const EventChannel('step_detection');

  static Future<Stream> get stepStream async {
    Stream stream = _channel.receiveBroadcastStream();
    return stream;
  }
}
