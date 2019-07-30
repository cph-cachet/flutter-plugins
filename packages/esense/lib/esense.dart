/*
 * Copyright 2019 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

library esense;

import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

part 'events.dart';

class PlatformVersion {
  static const MethodChannel _channel = const MethodChannel('esense');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class ESenseManager {
  static const String ESenseManagerMethodChannelName = 'esense.io/esense_manager';
  static const String ESenseConnectionEventChannelName = 'esense.io/esense_connection';
  static const String ESenseEventChannelName = 'esense.io/esense_events';
  static const String ESenseSensorEventChannelName = 'esense.io/esense_sensor';

  static const MethodChannel _eSenseManagerMethodChannel = MethodChannel(ESenseManagerMethodChannelName);
  static const EventChannel _eSenseConnectionEventChannel = EventChannel(ESenseConnectionEventChannelName);
  static const EventChannel _eSenseEventChannel = EventChannel(ESenseEventChannelName);
  static const EventChannel _eSenseSensorEventChannel = EventChannel(ESenseSensorEventChannelName);

  static Stream<ConnectionEvent> _connectionEventStream;
  static Stream<ESenseEvent> _eSenseEventStream;
  static Stream<SensorEvent> _sensorEventStream;

  /// Is this manager connected to an eSense device?
  static bool connected;

  /// The name of the connected eSense device
  static String eSenseDeviceName;

  /// The sampling rate of the eSense sensors.
  ///
  /// Default sampling rate is 10 Hz.
  static int samplingRate = 10;

  static Future<bool> connect(String name) async {
    assert(name != null, 'Must provide a name of the eSense device to connect to.');
    assert(Platform.isAndroid, 'Currently the eSense API is only available on Android.');
    eSenseDeviceName = name;
    connected = await _eSenseManagerMethodChannel.invokeMethod('connect', <String, dynamic>{'name': name});
    return connected;
  }

  /// Disconnects device.
  ///
  /// The [ConnectionEvent] with type [ConnectionType.disconnected] is fired after the disconnection has taken place.
  /// Returns [true] if the disconnection was successfully made, [false] otherwise
  static Future<bool> disconnect() async {
    connected = await _eSenseManagerMethodChannel.invokeMethod('disconnect');
    return connected;
  }

  /// Set the sampling rate for sensor sampling in Hz (min: 1 - max: 100)
  ///
  /// Default sampling rate is 10 Hz.
  static Future<bool> setSamplingRate(int rate) async {
    assert(
        rate != null && samplingRate > 0 && samplingRate <= 100, 'Must provide a sampling rate between 1 and 100 Hz.');
    samplingRate = rate;
    return await _eSenseManagerMethodChannel.invokeMethod('setSamplingRate', <String, dynamic>{'rate': rate});
  }

  static Future<bool> getDeviceName() async {
    final bool success = await _eSenseManagerMethodChannel.invokeMethod('getDeviceName');
    return success;
  }

  /// Requests a read of the battery voltage of the connected device.
  ///
  /// The event [BatteryRead] is fired when the voltage has been read.
  /// Returns [true] if the request was successfully made, [false] otherwise
  static Future<bool> getBatteryVoltage() async {
    final bool success = await _eSenseManagerMethodChannel.invokeMethod('getBatteryVoltage');
    return success;
  }

  /// Get a stream of [ConnectionEvent]s.
  ///
  /// If you want to get connection events when connecting to the eSense device,
  /// remember to start listening to this stream __before__ attempting to connect.
  ///
  /// For example.
  ///
  /// ````
  ///     ESenseManager.connectionEvents.listen((event) => print('Connection event: $event'));
  ///     bool success = await ESenseManager.connect(eSenseName);
  /// ````
  static Stream<ConnectionEvent> get connectionEvents {
    if (_connectionEventStream == null) {
      _connectionEventStream =
          _eSenseConnectionEventChannel.receiveBroadcastStream().map((type) => ConnectionEvent.fromString(type));

      // listen to the connection event in order to set the [connection] status
      _connectionEventStream.listen((ConnectionEvent event) {
        switch (event.type) {
          case ConnectionType.connected:
            connected = true;
            break;
          case ConnectionType.disconnected:
          case ConnectionType.unknown:
          case ConnectionType.device_found:
          case ConnectionType.device_not_found:
            connected = false;
            break;
        }
        print('setting connected : $connected');
      });
    }
    return _connectionEventStream;
  }

  static Stream<ESenseEvent> get eSenseEvents {
    if (_eSenseEventStream == null) {
      _eSenseEventStream = _eSenseEventChannel.receiveBroadcastStream().map((event) => ESenseEvent.fromMap(event));
    }
    return _eSenseEventStream;
  }

  static Stream<SensorEvent> get sensorEvents {
    if (_sensorEventStream == null) {
      _sensorEventStream =
          _eSenseSensorEventChannel.receiveBroadcastStream().map((event) => SensorEvent.fromMap(event));
    }
    return _sensorEventStream;
  }
}
