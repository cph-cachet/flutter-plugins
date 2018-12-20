import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:convert';

/// Keys for Movisens data points
const String TAP_MARKER = 'tap_marker',
    BATTERY_LEVEL = 'battery_level',
    STEP_COUNT = 'step_count',
    MET = 'met',
    MET_LEVEL = 'met_level',
    BODY_POSITION = 'body_position',
    MOVEMENT_ACCELERATION = 'movement_acceleration';

/// Generic Movisens data-point which all concrete data-points inherit from. Each data-point has a timestamp.
abstract class MovisensDataPoint {
  DateTime _timeStamp;

  MovisensDataPoint() {
    /// Log timestamp of data point creation
    _timeStamp = DateTime.now();
  }

  DateTime get timeStamp => _timeStamp;
}

/// Metabolic buffered level, holds met level values for a sedentary, light and moderate state.
class MovisensMetLevel extends MovisensDataPoint {
  double _sedentary, _light, _moderate, _vigorous;

  MovisensMetLevel(String metLevel) {
    Map<String, dynamic> metLevelMap = jsonDecode(metLevel);
    _sedentary = metLevelMap['sedentary'];
    _light = metLevelMap['light'];
    _moderate = metLevelMap['moderate'];
    _vigorous = metLevelMap['vigorous'];
  }

  double get sedentary => _sedentary;

  double get light => _light;

  double get moderate => _moderate;

  double get vigorous => _vigorous;
}

/// Battery level of the Movisens device, in percent (%)
class MovisensBatteryLevel extends MovisensDataPoint {
  double _batteryLevel;

  MovisensBatteryLevel(String batteryString) {
    _batteryLevel = double.parse(batteryString);
  }

  double get batteryLevel => _batteryLevel;
}

/// Step count monitored by the Movisens device
class MovisensStepCount extends MovisensDataPoint {
  int _stepCount;

  MovisensStepCount(String value) {
    _stepCount = int.parse(value);
  }

  int get stepCount => _stepCount;
}

/// A generic class which only contains a timestamp, for when the movisens device was tapped.
class MovisensTapMarker extends MovisensDataPoint {}

class MovisensMet extends MovisensDataPoint {
  double _met;

  MovisensMet(String value) {
    _met = double.parse(value);
  }

  double get met => _met;
}

/// Movisens body-position, which depends on the sensor location
class MovisensBodyPosition extends MovisensDataPoint {
  String _bodyPosition;

  MovisensBodyPosition(this._bodyPosition);

  String get bodyPosition => _bodyPosition;
}

/// Accelerometer measure of the Movisens device
class MovisensMovementAcceleration extends MovisensDataPoint {
  double _movementAcceleration;

  MovisensMovementAcceleration(String value) {
    _movementAcceleration = double.parse(value);
  }

  double get met => _movementAcceleration;
}
/// Factory function for converting a generic object sent through the platform channel into a concrete [MovisensDataPoint] object.
MovisensDataPoint movisensFactory(dynamic javaMap) {
  Map<String, dynamic> data = Map<String, dynamic>.from(javaMap);
  print(data);

  String _batteryLevel =
      data.containsKey(BATTERY_LEVEL) ? data[BATTERY_LEVEL] : null;
  String _tapMarker = data.containsKey(TAP_MARKER) ? data[TAP_MARKER] : null;
  String _stepCount = data.containsKey(STEP_COUNT) ? data[STEP_COUNT] : null;
  String _met = data.containsKey(MET) ? data[MET] : null;
  dynamic _metLevel = data.containsKey(MET_LEVEL) ? data[MET_LEVEL] : null;
  String _bodyPosition =
      data.containsKey(BODY_POSITION) ? data[BODY_POSITION] : null;
  String _movementAcceleration = data.containsKey(MOVEMENT_ACCELERATION)
      ? data[MOVEMENT_ACCELERATION]
      : null;

  if (_batteryLevel != null) return new MovisensBatteryLevel(_batteryLevel);
  if (_tapMarker != null) return new MovisensTapMarker();
  if (_stepCount != null) return new MovisensStepCount(_stepCount);
  if (_met != null) return new MovisensMet(_met);
  if (_metLevel != null) return new MovisensMetLevel(_metLevel);
  if (_bodyPosition != null) return new MovisensBodyPosition(_bodyPosition);
  if (_movementAcceleration != null)
    return new MovisensMovementAcceleration(_movementAcceleration);
  return null;
}

/// The main plugin class which establishes a [MethodChannel] and an [EventChannel].
class MovisensFlutter {
  MethodChannel _methodChannel = MethodChannel('movisens.method_channel');
  EventChannel _eventChannel = EventChannel('movisens.event_channel');
  Stream<MovisensDataPoint> _movisensStream;

  /// Starts listening to incoming data sent over the [EventChannel]
  Stream<MovisensDataPoint> get movisensStream {
    _movisensStream =
        _eventChannel.receiveBroadcastStream().map(movisensFactory);
    return _movisensStream;
  }

  /// Sends data used for starting the Movisens device.
  /// The sampling will begin once the data is received on the other end of the [MethodChannel].
  void startSensing(Map<String, String> userData) {
    Map<String, dynamic> args = {'user_data': userData};
    _methodChannel.invokeMethod('userData', args);
  }
}
