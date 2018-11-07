import 'dart:async';

import 'package:flutter/services.dart';

class Apps {
  static const MethodChannel _channel =
      const MethodChannel('apps');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getForegroundApp');
    return version;
  }
}
