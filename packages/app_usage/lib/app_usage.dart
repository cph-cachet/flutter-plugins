import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Custom Exception for the plugin,
/// thrown whenever the plugin is used on platforms other than Android
class AppUsageException implements Exception {
  String _cause;
  AppUsageException(this._cause);

  @override
  String toString() {
    return _cause;
  }
}

class AppUsage {
  static const MethodChannel _methodChannel =
      const MethodChannel("app_usage.methodChannel");

  Future<Map> fetchUsage(DateTime startDate, DateTime endDate) async {
    Map<dynamic, dynamic> usage = new Map();
    if (Platform.isAndroid) {
      int end = endDate.millisecondsSinceEpoch;
      int start = startDate.millisecondsSinceEpoch;
      Map<String, int> interval = {'start': start, 'end': end};
      usage = await _methodChannel.invokeMethod('getUsage', interval);
      return Map<String, double>.from(usage);
    }
    throw new AppUsageException('AppUsage API exclusively available on Android!');
  }
}
