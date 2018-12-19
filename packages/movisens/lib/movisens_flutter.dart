import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:convert';

class MetLevel {
  DateTime _time;
  double _sedentary, _light, _moderate;

  MetLevel(String level) {
    List<String> levels = level.split(',');
    String timestamp = levels[0].split('=')[1].trim();
    _sedentary = double.parse(levels[1].split('=')[1].trim());
    _light = double.parse(levels[2].split('=')[1].trim());
    _moderate = double.parse(levels[3].split('=')[1].trim());
    _time = DateTime.parse(timestamp);
  }

  DateTime get time => time;

  double get sedentary => _sedentary;
  double get light => _light;
  double get moderate => _moderate;
}

class MovisensDataPoint {
  static const String TAP_MARKER = 'tap_marker',
      BATTERY_LEVEL = 'battery_level',
      STEP_COUNT = 'step_count',
      MET = 'met',
      MET_LEVEL = 'met_level',
      BODY_POSITION = 'body_position',
      MOVEMENT_ACCELERATION = 'movement_acceleration';

  String _batteryLevel,
      _tapMarker,
      _stepCount,
      _met,
      _bodyPosition,
      _movementAcceleration;
  MetLevel _metLevel;

  MovisensDataPoint(Map<String, dynamic> data) {
    _batteryLevel =
        data.containsKey(BATTERY_LEVEL) ? data[BATTERY_LEVEL] : 'none';
    _tapMarker = data.containsKey(TAP_MARKER) ? data[TAP_MARKER] : 'none';
    _stepCount = data.containsKey(STEP_COUNT) ? data[STEP_COUNT] : 'none';
    _met = data.containsKey(MET) ? data[MET] : 'none';
    _metLevel =
        new MetLevel(data.containsKey(MET_LEVEL) ? data[MET_LEVEL] : 'none');
    _bodyPosition =
        data.containsKey(BODY_POSITION) ? data[BODY_POSITION] : 'none';
    _movementAcceleration = data.containsKey(MOVEMENT_ACCELERATION)
        ? data[MOVEMENT_ACCELERATION]
        : 'none';
  }

  String get batteryLevel => _batteryLevel;

  String get tapMarker => _tapMarker;

  String get stepCount => _stepCount;

  String get met => _met;

  MetLevel get metLevel => _metLevel;

  String get bodyPosition => _bodyPosition;

  String get movementAcceleration => _movementAcceleration;

  @override
  String toString() {
    return 'Movisens Data Point {'
        'Battery Level: $batteryLevel, '
        'Tap Marker: $tapMarker, '
        'Step Count: $stepCount, '
        'Met: $met, '
        'Met level: $metLevel, '
        'Body position: $bodyPosition, '
        'Movement acceleration: $movementAcceleration'
        '}';
  }
}

MovisensDataPoint parseDataPoint(dynamic dataPoint) {
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

  void startSensing() {
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

    _methodChannel.invokeMethod('userData', args);
  }
}
