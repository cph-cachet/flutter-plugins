import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:convert';

enum Gender { male, female }

enum SensorLocation {
  left_ankle,
  left_hip,
  left_thigh,
  left_upper_arm,
  left_wrist,
  right_ankle,
  right_hip,
  right_thigh,
  right_upper_arm,
  right_wrist,
  chest
}

class UserData {
  int weight, height, age;

  /// Weight in kg, height in cm, age in years
  Gender gender;

  /// Gender: male or female
  SensorLocation sensorLocation;

  /// Sensor placement on body
  String sensorAddress, sensorName;

  /// Sensor device addresss and name

  UserData(this.weight, this.height, this.gender, this.age, this.sensorLocation,
      this.sensorAddress, this.sensorName);

  Map<String, String> get asMap {
    return {
      'weight': '$weight',
      'height': '$height',
      'age': '$age',
      'gender': '$gender',
      'sensor_location': '$sensorLocation',
      'sensor_address': '$sensorAddress',
      'sensor_name': '$sensorName'
    };
  }
}

/// Keys for Movisens data points
const String TAP_MARKER = 'tap_marker',
    BATTERY_LEVEL = 'battery_level',
    STEP_COUNT = 'step_count',
    MET = 'met',
    MET_LEVEL = 'met_level',
    BODY_POSITION = 'body_position',
    MOVEMENT_ACCELERATION = 'movement_acceleration',
    CONNECTION_STATUS = 'connection_status';

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

  MovisensMetLevel(String metLevelString) {
    String metLevelJson = metLevelString.replaceAllMapped(
        new RegExp(r'([a-z]+)\=([\d.]+)'), (g) => '"${g[1]}":"${g[2]}"');
    Map<String, dynamic> metLevel = jsonDecode(metLevelJson);

    _sedentary = double.parse(metLevel['sedentary']);
    _light = double.parse(metLevel['light']);
    _moderate = double.parse(metLevel['moderate']);
    _vigorous = double.parse(metLevel['vigorous']);
  }

  double get sedentary => _sedentary;

  double get light => _light;

  double get moderate => _moderate;

  double get vigorous => _vigorous;

  @override
  String toString() {
    return 'MetLevel: {'
        'time: $timeStamp, '
        'sedentary: $sedentary, '
        'light: $light, '
        'moderate: $moderate, '
        'vigorous: $vigorous'
        '}';
  }
}

/// Battery level of the Movisens device, in percent (%)
class MovisensBatteryLevel extends MovisensDataPoint {
  double _batteryLevel;

  MovisensBatteryLevel(String batteryString) {
    _batteryLevel = double.parse(batteryString);
  }

  double get batteryLevel => _batteryLevel;

  @override
  String toString() {
    return 'BatteryLevel: {'
        'time: $timeStamp, '
        'battery_level: $batteryLevel'
        '}';
  }
}

/// Step count monitored by the Movisens device
class MovisensStepCount extends MovisensDataPoint {
  int _stepCount;

  MovisensStepCount(String value) {
    _stepCount = int.parse(value);
  }

  int get stepCount => _stepCount;

  @override
  String toString() {
    return 'StepCount: {'
        'time: $timeStamp, '
        'step_count: $stepCount'
        '}';
  }
}

/// A generic class which only contains a timestamp, for when the movisens device was tapped.
class MovisensTapMarker extends MovisensDataPoint {
  @override
  String toString() {
    return 'TapMarker: {'
        'time: $timeStamp'
        '}';
  }
}

class MovisensMet extends MovisensDataPoint {
  double _met;

  MovisensMet(dynamic value) {
    String met = value;
    _met = double.parse(met.split(',').removeLast());
  }

  double get met => _met;

  @override
  String toString() {
    return 'MET: {'
        'time: $timeStamp, '
        'met: $met'
        '}';
  }
}

/// Movisens body-position, which depends on the sensor location
class MovisensBodyPosition extends MovisensDataPoint {
  String _bodyPosition;

  MovisensBodyPosition(this._bodyPosition);

  String get bodyPosition => _bodyPosition;

  @override
  String toString() {
    return 'BodyPosition: {'
        'time: $timeStamp, '
        'body_position: $bodyPosition'
        '}';
  }
}

/// Accelerometer measure of the Movisens device
class MovisensMovementAcceleration extends MovisensDataPoint {
  double _movementAcceleration;

  MovisensMovementAcceleration(String value) {
    _movementAcceleration = double.parse(value);
  }

  double get met => _movementAcceleration;

  @override
  String toString() {
    return 'MovementAcceleration: {'
        'time: $timeStamp, '
        'movement_acceleration: $_movementAcceleration'
        '}';
  }
}

/// Accelerometer measure of the Movisens device
class MovisensStatus extends MovisensDataPoint {
  String _connectionStatus;

  MovisensStatus(String _connectionStatus);

  String get connectionStatus => _connectionStatus;

  @override
  String toString() {
    return 'ConnectionStatus: {'
        'time: $timeStamp, '
        'connection_status: $_connectionStatus'
        '}';
  }
}

/// Factory function for converting a generic object sent through the platform channel into a concrete [MovisensDataPoint] object.
MovisensDataPoint parseDataPoint(dynamic javaMap) {
  Map<String, dynamic> data = Map<String, dynamic>.from(javaMap);
  String _batteryLevel =
      data.containsKey(BATTERY_LEVEL) ? data[BATTERY_LEVEL] : null;
  String _tapMarker = data.containsKey(TAP_MARKER) ? data[TAP_MARKER] : null;
  String _stepCount = data.containsKey(STEP_COUNT) ? data[STEP_COUNT] : null;
  String _met = data.containsKey(MET) ? data[MET] : null;
  String _metLevel = data.containsKey(MET_LEVEL) ? data[MET_LEVEL] : null;
  String _bodyPosition =
      data.containsKey(BODY_POSITION) ? data[BODY_POSITION] : null;
  String _movementAcceleration = data.containsKey(MOVEMENT_ACCELERATION)
      ? data[MOVEMENT_ACCELERATION]
      : null;
  String _connectionStatus =
      data.containsKey(CONNECTION_STATUS) ? data[CONNECTION_STATUS] : null;

  if (_batteryLevel != null) return new MovisensBatteryLevel(_batteryLevel);
  if (_tapMarker != null) return new MovisensTapMarker();
  if (_stepCount != null) return new MovisensStepCount(_stepCount);
  if (_met != null) return new MovisensMet(_met);
  if (_metLevel != null) return new MovisensMetLevel(_metLevel);
  if (_bodyPosition != null) return new MovisensBodyPosition(_bodyPosition);
  if (_movementAcceleration != null)
    return new MovisensMovementAcceleration(_movementAcceleration);
  if (_connectionStatus != null) return new MovisensStatus(_connectionStatus);

  return null;
}

/// The main plugin class which establishes a [MethodChannel] and an [EventChannel].
class Movisens {
  MethodChannel _methodChannel = MethodChannel('movisens.method_channel');
  EventChannel _eventChannel = EventChannel('movisens.event_channel');
  Stream<MovisensDataPoint> _movisensStream;

  /// Starts listening to incoming data sent over the [EventChannel]
  Stream<MovisensDataPoint> get movisensStream {
    _movisensStream =
        _eventChannel.receiveBroadcastStream().map(parseDataPoint);
    return _movisensStream;
  }

  /// Sends data used for starting the Movisens device.
  /// The sampling will begin once the data is received on the other end of the [MethodChannel].
  void startSensing(UserData userData) {
    Map<String, dynamic> args = {'user_data': userData.asMap};
    _methodChannel.invokeMethod('userData', args);
  }
}
