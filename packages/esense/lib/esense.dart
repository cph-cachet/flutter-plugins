import 'dart:async';

import 'package:flutter/services.dart';

class Esense {
  static const MethodChannel _channel =
      const MethodChannel('esense');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
