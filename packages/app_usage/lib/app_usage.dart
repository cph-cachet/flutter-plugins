import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class AppUsage {
  static const MethodChannel _methodChannel =
      const MethodChannel("app_usage.methodChannel");

  Future<Map> getUsage(DateTime startDate, DateTime endDate) async {
    Map<dynamic, dynamic> usage = new Map();
    if (Platform.isAndroid) {
      int end = endDate.millisecondsSinceEpoch;
      int start = startDate.millisecondsSinceEpoch;

      Map<String, int> interval = {'start': start, 'end': end};
      usage = await _methodChannel.invokeMethod('getUsage', interval);
    } else if (Platform.isIOS) {
      usage['error.n/a'] = 0.0;
    }

    return Map<String, double>.from(usage);
  }
}
