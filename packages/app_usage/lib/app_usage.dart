import 'dart:async';

import 'package:flutter/services.dart';

class AppUsage {
  static const MethodChannel _methodChannel =
      const MethodChannel("app_usage.methodChannel");

  Future<Map> getUsage(DateTime startDate, DateTime endDate) async {
    int end = endDate.millisecondsSinceEpoch;
    int start = startDate.millisecondsSinceEpoch;

    Map<String, int> interval = {'start': start, 'end': end};
    Map<dynamic, dynamic> usage = await _methodChannel.invokeMethod('getUsage', interval);

    return Map<String, double>.from(usage);
  }
}
