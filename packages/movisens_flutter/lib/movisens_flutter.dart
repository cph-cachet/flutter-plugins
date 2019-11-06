/*
 * Copyright 2019 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io' show Platform;

/// Custom Exception for the plugin. Thrown whenever the plugin is used on platforms other than Android
class MovisensException implements Exception {
  String _cause;
  MovisensException(this._cause);

  String toString() => '${this.runtimeType} - $_cause';
}

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
  /// Weight of the person wearing the Movisens device in kg.
  int weight;

  /// Height of the person wearing the Movisens device in cm.
  int height;

  /// Age of the person wearing the Movisens device in years.
  int age;

  /// Gender of the person wearing the Movisens device, male or female.
  Gender gender;

  /// Sensor placement on body
  SensorLocation sensorLocation;

  /// The MAC address of the sensor.
  String sensorAddress;

  /// The user-friendly name of the sensor.
  String sensorName;

  UserData(this.weight, this.height, this.gender, this.age, this.sensorLocation, this.sensorAddress, this.sensorName);

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

String timeStampHHMMSS(DateTime timeStamp) => timeStamp.toIso8601String();

/// Keys for Movisens data points
const String TAP_MARKER = 'tap_marker',
    BATTERY_LEVEL = 'battery_level',
    TIMESTAMP = 'timestamp',
    STEP_COUNT = 'step_count',
    MET = 'met',
    MET_LEVEL = 'met_level',
    BODY_POSITION = 'body_position',
    MOVEMENT_ACCELERATION = 'movement_acceleration',
    CONNECTION_STATUS = 'connection_status',
    HR = 'hr',
    IS_HRV_VALID = 'is_hrv_valid',
    HRV = 'hrv';

/// The main plugin class which establishes a [MethodChannel] and an [EventChannel].
class Movisens {
  MethodChannel _methodChannel = MethodChannel('movisens.method_channel');
  EventChannel _eventChannel = EventChannel('movisens.event_channel');
  Stream<Map<String, dynamic>> _movisensStream;
  UserData _userData;

  Movisens(this._userData);

  Stream<Map<String, dynamic>> get movisensStream {
    if (Platform.isAndroid) {
      if (_movisensStream == null) {
        Map<String, dynamic> args = {'user_data': _userData.asMap};
        _methodChannel.invokeMethod('userData', args);
        _movisensStream = _eventChannel.receiveBroadcastStream().map(_parseDataPoint);
      }
      return _movisensStream;
    }
    throw MovisensException('Movisens API exclusively available on Android!');
  }
}

/*
   Below are private factory functions for converting a generic object sent through the platform channel
   into a concrete [MovisensDataPoint] object.
 */
Map<String, dynamic> _parseDataPoint(dynamic javaMap) {
  Map<String, dynamic> data = Map<String, dynamic>.from(javaMap);

  String _hr = data.containsKey(HR) ? data[HR] : null;
  String _isHrvValid = data.containsKey(IS_HRV_VALID) ? data[IS_HRV_VALID] : null;
  String _hrv = data.containsKey(HRV) ? data[HRV] : null;
  String _batteryLevel = data.containsKey(BATTERY_LEVEL) ? data[BATTERY_LEVEL] : null;
  String _tapMarker = data.containsKey(TAP_MARKER) ? data[TAP_MARKER] : null;
  String _stepCount = data.containsKey(STEP_COUNT) ? data[STEP_COUNT] : null;
  String _met = data.containsKey(MET) ? data[MET] : null;
  String _metLevel = data.containsKey(MET_LEVEL) ? data[MET_LEVEL] : null;
  String _bodyPosition = data.containsKey(BODY_POSITION) ? data[BODY_POSITION] : null;
  String _movementAcceleration = data.containsKey(MOVEMENT_ACCELERATION) ? data[MOVEMENT_ACCELERATION] : null;
  String _connectionStatus = data.containsKey(CONNECTION_STATUS) ? data[CONNECTION_STATUS] : null;

  print(_connectionStatus);

  if (_hr != null) return _movisensHR(_hr);

  if (_hrv != null) return _movisensHRV(_hrv);

  if (_batteryLevel != null) {
    return _movisensBatteryLevel(_batteryLevel);
  }
  if (_tapMarker != null) {
    return _movisensTapMarker(_tapMarker);
  }

  if (_stepCount != null) {
    return _movisensStepCount(_stepCount);
  }

  if (_movementAcceleration != null) {
    return _movisensMovementAcceleration(_movementAcceleration);
  }

  if (_bodyPosition != null) {
    return _movisensBodyPosition(_bodyPosition);
  }

  if (_isHrvValid != null) return _movisensIsHrvValid(_isHrvValid);

  if (_metLevel != null) {
    return _movisensMetLevel(_metLevel);
  }

  if (_met != null) {
    return _movisensMet(_met);
  }
  if (_connectionStatus != null && _connectionStatus != 'null') {
    return _movisensStatus(_connectionStatus);
  }
  return null;
}

Map<String, dynamic> _movisensStatus(String connectionStatus) {
  String _connectionStatusJson;
  _connectionStatusJson =
      connectionStatus.replaceAllMapped(new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:\_-]+)'), (g) => '"${g[1]}":"${g[2]}"');

  Map<String, dynamic> statusMap = new Map();

  statusMap["ConnectionStatus"] = _connectionStatusJson;

  return statusMap;
}

Map<String, dynamic> _movisensMet(String met) {
  String _metJson;
  _metJson = met.replaceAllMapped(new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');

  Map<String, dynamic> metMap = new Map();

  metMap["Met"] = _metJson;

  return metMap;
}

Map<String, dynamic> _movisensMetLevel(String metLevel) {
  String _metLevelJson;
  _metLevelJson =
      metLevel.replaceAllMapped(new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');

  Map<String, dynamic> metLevelMap = new Map();

  metLevelMap["MetLevel"] = _metLevelJson;

  return metLevelMap;
}

Map<String, dynamic> _movisensIsHrvValid(String isHrvValid) {
  String _isHrvValidJson;
  _isHrvValidJson =
      isHrvValid.replaceAllMapped(new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');

  Map<String, dynamic> isHrvValidMap = new Map();

  isHrvValidMap["IsHrvValid"] = _isHrvValidJson;

  return isHrvValidMap;
}

Map<String, dynamic> _movisensBodyPosition(String bodyPosition) {
  String _bodyPositionJson;
  _bodyPositionJson =
      bodyPosition.replaceAllMapped(new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:\_-]+)'), (g) => '"${g[1]}":"${g[2]}"');

  Map<String, dynamic> bodyPositionMap = new Map();

  bodyPositionMap["BodyPosition"] = _bodyPositionJson;

  return bodyPositionMap;
}

Map<String, dynamic> _movisensMovementAcceleration(String movementAcceleration) {
  String _movementAccelerationJson;
  _movementAccelerationJson = movementAcceleration.replaceAllMapped(
      new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');

  Map<String, dynamic> movementAccelerationMap = new Map();

  movementAccelerationMap["MovementAcceleration"] = _movementAccelerationJson;
  return movementAccelerationMap;
}

Map<String, dynamic> _movisensStepCount(String stepCount) {
  String _stepCountJson;
  _stepCountJson =
      stepCount.replaceAllMapped(new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');

  Map<String, dynamic> stepCountMap = new Map();

  stepCountMap["StepCount"] = _stepCountJson;
  return stepCountMap;
}

Map<String, dynamic> _movisensTapMarker(String tapMarker) {
  String _tapMarkerJson;
  _tapMarkerJson =
      tapMarker.replaceAllMapped(new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');

  Map<String, dynamic> tapMarkerMap = new Map();

  tapMarkerMap["TapMarker"] = _tapMarkerJson;
  return tapMarkerMap;
}

Map<String, dynamic> _movisensBatteryLevel(String batteryLevel) {
  String _batteryLevelJson;
  _batteryLevelJson =
      batteryLevel.replaceAllMapped(new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');

  Map<String, dynamic> batteryLevelMap = new Map();

  batteryLevelMap["BatteryLevel"] = _batteryLevelJson;
  return batteryLevelMap;
}

Map<String, dynamic> _movisensHR(String hr) {
  String _hrJson = hr.replaceAllMapped(new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');

  Map<String, dynamic> hrMap = new Map();

  hrMap["HR"] = _hrJson;
  return hrMap;
}

Map<String, dynamic> _movisensHRV(String hrv) {
  String _hrvJson;
  _hrvJson = hrv.replaceAllMapped(new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');

  Map<String, dynamic> hrvMap = new Map();

  hrvMap["HRV"] = _hrvJson;
  return hrvMap;
}
