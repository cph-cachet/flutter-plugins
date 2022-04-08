library empaticae4;

import 'dart:async';

import 'package:flutter/services.dart';

class EmpaticaE4link {


  static const MethodChannel _channel = MethodChannel('empatica_e4link');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<bool> authenticateWithAPIKey() async {
    final bool result = await _channel.invokeMethod('authenticateWithAPIKey', <String, dynamic>{
      'apiKey': '4daa8ba5bc4b419c81b597d6e592289b',
    });
    return result;
  }
}
