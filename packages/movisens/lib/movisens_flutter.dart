import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:convert';

class MovisensDataPoint {
  static const String TAP_MARKER = 'tap_marker',
      BATTERY = 'battery_level',
      STEP_COUNT = 'step_count',
      MET = 'met',
      MET_LEVEL = 'met_level';

  String _batteryLevel, _tapMarker, _stepCount, _met, _metLevel;

  MovisensDataPoint(Map<String, dynamic> data) {
    _batteryLevel = data.containsKey(BATTERY) ? data[BATTERY] : 'none';
    _tapMarker = data.containsKey(TAP_MARKER) ? data[TAP_MARKER] : 'none';
    _stepCount = data.containsKey(STEP_COUNT) ? data[STEP_COUNT] : 'none';
    _met = data.containsKey(MET) ? data[MET] : 'none';
    _metLevel = data.containsKey(MET_LEVEL) ? data[MET_LEVEL] : 'none';
  }

  String get batteryLevel => _batteryLevel;

  String get tapMarker => _tapMarker;

  String get stepCount => _stepCount;

  String get met => _met;

  String get metLevel => _metLevel;

  @override
  String toString() {
    return 'Movisens Data Point {'
        'Battery Level: $batteryLevel, '
        'Tap Marker: $tapMarker, '
        'Step Count: $stepCount, '
        'Met: $met, '
        'Met level: $metLevel'
        '}';
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
        'age': '40',
        'sensor_location': 'CHEST',
        'sensor_address': '88:6B:0F:82:1D:33',
        'sensor_name': 'Sensor 02655'
      }
    };

    var res = await _methodChannel.invokeMethod('userData', args);
    print("Response from android -> $res");
  }
}
