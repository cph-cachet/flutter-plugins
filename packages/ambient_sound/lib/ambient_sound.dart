import 'dart:async';

import 'package:flutter/services.dart';

class AmbientSound {
  static const MethodChannel _channel =
      const MethodChannel('ambient_sound');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
