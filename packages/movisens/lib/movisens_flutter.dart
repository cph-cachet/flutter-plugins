import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:convert';

class MovisensDataPoint {
  static const String TAP_MARKER = 'tapMarker',
      BATTERY_LEVEL = 'batteryLevel',
      STEP_COUNT = 'step_count';

  String _batteryLevel, _tapMarker, _stepCount;

  MovisensDataPoint(Map<String, dynamic> data) {
    _batteryLevel =
        data.containsKey(BATTERY_LEVEL) ? data[BATTERY_LEVEL] : 'none';
    _tapMarker = data.containsKey(TAP_MARKER) ? data[TAP_MARKER] : 'none';
    _stepCount = data.containsKey(STEP_COUNT) ? data[STEP_COUNT] : 'none';
  }

  String get batteryLevel => _batteryLevel;

  String get tapMarker => _tapMarker;

  String get stepCount => _stepCount;

  @override
  String toString() {
    return 'Movisens Data Point {Battery Level: $batteryLevel, Tap Marker: $tapMarker, Step Count: $stepCount}';
  }
}

MovisensDataPoint parseDataPoint(dynamic dataPoint) {
//  Map<dynamic, dynamic> jsonMap = json.decode(dataPoint);
  Map<String, dynamic> data = new Map<String, dynamic>.from(dataPoint);
  return MovisensDataPoint(data);
}

class MovisensFlutter {
  MethodChannel _methodChannel = MethodChannel('movisens.method_channel');
  EventChannel _eventChannel = EventChannel('movisens.event_channel');
  Stream<MovisensDataPoint> _movisenStream;

  Stream<MovisensDataPoint> get movisensStream {
    _movisenStream = _eventChannel.receiveBroadcastStream().map(parseDataPoint);
    return _movisenStream;
  }

  void makeUserData() async {
    print('Make user data');
    Map<String, dynamic> args = {
      'user_data': {
        'weight': '100',
        'height': '180',
        'gender': 'male',
        'age': '40'
      }
    };

    dynamic res = await _methodChannel.invokeMethod('userData', args);
    print("Response from android -> $res");
  }
}
