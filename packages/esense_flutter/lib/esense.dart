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

part 'esense_events.dart';
part 'esense_config.dart';

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
  static bool connected = false;

  /// The name of the connected eSense device
  static String eSenseDeviceName;

  static int _samplingRate = 10;

  /// The sampling rate of the eSense sensors (default sampling rate is 10 Hz.)
  static int get samplingRate => _samplingRate;

  // ------------    METHOD HANDLERS --------------------

  static Future<bool> connect(String name) async {
    assert(name != null && name.length > 0, 'Must provide a name of the eSense device to connect to.');
    eSenseDeviceName = name;
    return await _eSenseManagerMethodChannel.invokeMethod('connect', <String, dynamic>{'name': name});
  }

  /// Disconnects the device (if connected).
  ///
  /// The [ConnectionEvent] with type [ConnectionType.disconnected] is fired after the disconnection has taken place.
  /// Returns [true] if the disconnection was successfully made, [false] otherwise
  static Future<bool> disconnect() async {
    if (connected)
      return await _eSenseManagerMethodChannel.invokeMethod('disconnect');
    else
      return false;
  }

  /// Checks the BTLE connection if the device is connected or not.
  ///
  /// Returns [true] if a device is connected [false] otherwise
  static Future<bool> isConnected() async {
    connected = await _eSenseManagerMethodChannel.invokeMethod('isConnected');
    return connected;
  }

  /// Set the sampling rate for sensor sampling in Hz (min: 1 - max: 100)
  ///
  /// Default sampling rate is 10 Hz.
  static Future<bool> setSamplingRate(int rate) async {
    assert(rate != null && _samplingRate > 0 && _samplingRate <= 100,
        'Must provide a sampling rate between 1 and 100 Hz.');
    _samplingRate = rate;
    return await _eSenseManagerMethodChannel.invokeMethod('setSamplingRate', <String, dynamic>{'rate': rate});
  }

  /// Requests a read of the name of the connected device.
  ///
  /// The event [DeviceNameRead] is fired when the name has been read.
  /// Returns [true] if the request was successfully made, [false] otherwise.
  static Future<bool> getDeviceName() async {
    if (!connected) throw ESenseException('Not connected to any eSense device.');
    return await _eSenseManagerMethodChannel.invokeMethod('getDeviceName');
  }

  /// Requests a change of the name of the connected device.
  ///
  /// Maximum size is 22 characters.
  /// Returns [true] if the request was successfully made, [false] otherwise
  static Future<bool> setDeviceName(String deviceName) async {
    assert(deviceName != null && deviceName.length < 22,
        'A non-null device name less than 22 characteres must be specified.');
    if (!connected) throw ESenseException('Not connected to any eSense device.');
    return await _eSenseManagerMethodChannel.invokeMethod('setDeviceName', <String, dynamic>{'deviceName': deviceName});
  }

  /// Requests a read of the battery voltage of the connected device.
  ///
  /// The event [BatteryRead] is fired when the voltage has been read.
  /// Returns [true] if the request was successfully made, [false] otherwise
  static Future<bool> getBatteryVoltage() async {
    if (!connected) throw ESenseException('Not connected to any eSense device.');
    return await _eSenseManagerMethodChannel.invokeMethod('getBatteryVoltage');
  }

  /// Requests a read of the factory accelerometer offset values of the connected device.
  ///
  /// The event [AccelerometerOffsetRead] is fired when the offset has been read.
  /// Returns [true] if the request was successfully made, [false] otherwise
  static Future<bool> getAccelerometerOffset() async {
    if (!connected) throw ESenseException('Not connected to any eSense device.');
    return await _eSenseManagerMethodChannel.invokeMethod('getAccelerometerOffset');
  }

  /// Requests a read of the parameter values of advertisement and connection interval of the connected device.
  ///
  /// The event [AdvertisementAndConnectionIntervalRead] is fired when the parameter values has been read.
  /// Returns [true] if the request was successfully made, [false] otherwise
  static Future<bool> getAdvertisementAndConnectionInterval() async {
    if (!connected) throw ESenseException('Not connected to any eSense device.');
    return await _eSenseManagerMethodChannel.invokeMethod('getAdvertisementAndConnectionInterval');
  }

  /// Requests a change of the advertisement and connection intervals on the connected device.
  ///
  /// Condition for advertisement interval:
  ///    * the minimum interval should be greater than or equal to 100
  ///    * the maximum interval should be less than or equal to 2000
  ///    * the maximum interval should be greater than or equal to the minimum interval.
  ///
  /// Condition for connection interval:
  ///    * the minimum interval should be greater than or equal to 20
  ///    * the maximum interval should be less than or equal to 2000
  ///    * the difference between the maximum and minimum intervals should be greater than or equal to 20.
  ///
  /// Returns [true] if the request was successfully made, [false] otherwise
  static Future<bool> setAdvertisementAndConnectiontInterval(
      int advMinInterval, int advMaxInterval, int connMinInterval, int connMaxInterval) async {
    assert(advMinInterval != null && advMaxInterval != null && connMinInterval != null && connMaxInterval != null,
        'Non-null advertisement and connection intervals must be specified.');
    if (!connected) throw ESenseException('Not connected to any eSense device.');
    return await _eSenseManagerMethodChannel.invokeMethod('setAdvertisementAndConnectiontInterval', <String, dynamic>{
      'advMinInterval': advMinInterval,
      'advMaxInterval': advMaxInterval,
      'connMinInterval': connMinInterval,
      'connMaxInterval': connMaxInterval,
    });
  }

  /// Requests a read of the sensor configuration of the connected device.
  /// Right now not implemented on the Flutter side, i.e. the [ESenseConfig] class is empty.
  ///
  /// The event [SensorConfigRead] is fired when the offset has been read.
  /// Returns [true] if the request was successfully made, [false] otherwise
  static Future<bool> getSensorConfig() async {
    if (!connected) throw ESenseException('Not connected to any eSense device.');
    return await _eSenseManagerMethodChannel.invokeMethod('getSensorConfig');
  }

  /// Requests a change of the sensor configuration on the connected device.
  ///
  /// Returns [true] if the request was successfully made, [false] otherwise
  static Future<bool> setSensorConfig(ESenseConfig config) async {
    assert(config != null, 'A non-null sensor configuration must be specified.');
    if (!connected) throw ESenseException('Not connected to any eSense device.');
    return await _eSenseManagerMethodChannel.invokeMethod('setSensorConfig', config.toMap());
  }

  // ------------    STREAM HANDLERS --------------------

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
      });
    }
    return _connectionEventStream;
  }

  /// Get the stream of events from the eSense device, once connected.
  ///
  /// Throws an [ESenseException] if not connected to an eSense device.
  /// Wait until [connected] before using this stream.
  static Stream<ESenseEvent> get eSenseEvents {
    if (!connected) throw ESenseException('Not connected to any eSense device.');
    if (_eSenseEventStream == null) {
      _eSenseEventStream = _eSenseEventChannel.receiveBroadcastStream().map((event) => ESenseEvent.fromMap(event));
    }
    return _eSenseEventStream;
  }

  /// Get the stream of sensor events.
  ///
  /// Use the [setSamplingRate] method to set the sampling rate.
  ///
  /// Throws an [ESenseException] if not connected to an eSense device.
  /// Wait until [connected] before using this stream.
  static Stream<SensorEvent> get sensorEvents {
    if (!connected) throw ESenseException('Not connected to any eSense device.');
    if (_sensorEventStream == null) {
      _sensorEventStream =
          _eSenseSensorEventChannel.receiveBroadcastStream().map((event) => SensorEvent.fromMap(event));
    }
    return _sensorEventStream;
  }
}

/// A custom exception for eSense operations.
class ESenseException implements Exception {
  final String message;
  ESenseException(this.message);
  String toString() => 'ESenseException - $message';
}
