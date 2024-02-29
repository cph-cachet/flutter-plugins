/*
 * Copyright 2022 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

library esense;

import 'dart:async';
import 'package:flutter/services.dart';

part 'esense_events.dart';
part 'esense_config.dart';

class ESenseManager {
  static const String ESenseManagerMethodChannelName =
      'esense.io/esense_manager';
  static const String ESenseConnectionEventChannelName =
      'esense.io/esense_connection';
  static const String ESenseEventChannelName = 'esense.io/esense_events';
  static const String ESenseSensorEventChannelName = 'esense.io/esense_sensor';

  final MethodChannel _eSenseManagerMethodChannel =
      const MethodChannel(ESenseManagerMethodChannelName);
  final EventChannel _eSenseConnectionEventChannel =
      const EventChannel(ESenseConnectionEventChannelName);
  final EventChannel _eSenseEventChannel =
      const EventChannel(ESenseEventChannelName);
  final EventChannel _eSenseSensorEventChannel =
      const EventChannel(ESenseSensorEventChannelName);

  Stream<ConnectionEvent>? _connectionEventStream;
  Stream<ESenseEvent>? _eventStream;
  Stream<SensorEvent>? _sensorStream;

  /// Is this manager connected to an eSense device?
  bool connected = false;

  /// The name of the connected eSense device
  String deviceName;

  int _samplingRate = 10;

  /// The sampling rate of the eSense sensors (default sampling rate is 10 Hz.)
  int get samplingRate => _samplingRate;

  /// Constructs an eSense manager for a device with name [deviceName].
  ESenseManager(this.deviceName) {
    assert(deviceName.isNotEmpty,
        'Must provide a valid name of the eSense device to connect to.');
  }

  // ------------    METHOD HANDLERS --------------------

  /// Initiates a connection scanning procedure.
  ///
  /// The phone will first scan for the device with the given [deviceName].
  /// Then, if found, it will try to connect.
  /// Different [ConnectionEvent] events of type
  ///
  ///   * [ConnectionType.device_found]
  ///   * [ConnectionType.device_not_found]
  ///   * [ConnectionType.connected]
  ///
  /// are fired at different stages of the procedure.
  ///
  /// Returns `true` if scanning is started is successful, ´false` otherwise.
  ///
  /// Always make sure to [disconnect] the device when you don’t need it anymore.
  /// Failing to do so can drain the battery significantly.
  Future<bool> connect() async {
    _eventStream = null;
    _sensorStream = null;

    return await _eSenseManagerMethodChannel.invokeMethod<bool?>(
            'connect', <String, dynamic>{'name': deviceName}) ??
        false;
  }

  /// Disconnects the device (if connected).
  ///
  /// The [ConnectionEvent] with type [ConnectionType.disconnected] is fired
  /// after the disconnection has taken place.
  /// Returns `true` if the disconnection was successfully made, `false`
  /// otherwise.
  Future<bool> disconnect() async {
    _eventStream = null;
    _sensorStream = null;

    return (connected)
        ? await _eSenseManagerMethodChannel.invokeMethod<bool?>('disconnect') ??
            false
        : false;
  }

  /// Checks the BTLE connection if the device is connected or not.
  ///
  /// Returns `true` if a device is connected `false` otherwise
  Future<bool> isConnected() async => connected =
      await _eSenseManagerMethodChannel.invokeMethod('isConnected') ?? false;

  /// Set the sampling rate for sensor sampling in Hz (min: 1 - max: 100)
  /// Default sampling rate is 10 Hz.
  ///
  /// Returns `true` if the request was successfully made, `false` otherwise.
  ///
  /// Sampling rate must be set **before** listening is started.
  ///
  /// Note that the sampling rate is only a hint to the system.
  /// Sensor events may be received faster or slower than the specified rate,
  /// depending on the Bluetooth communication status and parameter values.
  Future<bool> setSamplingRate(int rate) async {
    assert(rate > 0 && rate <= 100,
        'Must provide a sampling rate between 1 and 100 Hz.');
    _samplingRate = rate;
    // for some strange reason, iOS does not accept an int as argument
    // hence, [rate] is converted to a string
    return await _eSenseManagerMethodChannel.invokeMethod<bool?>(
            'setSamplingRate', <String, dynamic>{'rate': '$rate'}) ??
        false;
  }

  /// Requests a read of the name of the connected device.
  ///
  /// The event [DeviceNameRead] is fired when the name has been read.
  /// Returns `true` if the request was successfully made, `false` otherwise.
  Future<bool> getDeviceName() async {
    if (!connected) {
      throw ESenseException('Not connected to any eSense device.');
    }
    return await _eSenseManagerMethodChannel
            .invokeMethod<bool?>('getDeviceName') ??
        false;
  }

  /// Requests a change of the name of the connected device.
  ///
  /// Maximum size is 22 characters.
  /// Returns `true` if the request was successfully made, `false` otherwise.
  Future<bool?> setDeviceName(String deviceName) async {
    assert(deviceName.isNotEmpty && deviceName.length < 22,
        'The device name must be more that zero and less than 22 characters long.');
    if (!connected) {
      throw ESenseException('Not connected to any eSense device.');
    }
    return await _eSenseManagerMethodChannel.invokeMethod(
            'setDeviceName', <String, dynamic>{'deviceName': deviceName}) ??
        false;
  }

  /// Requests a read of the battery voltage of the connected device.
  ///
  /// The event [BatteryRead] is fired when the voltage has been read.
  /// Returns `true` if the request was successfully made, `false` otherwise.
  Future<bool> getBatteryVoltage() async {
    if (!connected) {
      throw ESenseException('Not connected to any eSense device.');
    }
    return await _eSenseManagerMethodChannel
            .invokeMethod<bool?>('getBatteryVoltage') ??
        false;
  }

  /// Requests a read of the factory accelerometer offset values of the connected
  /// device.
  ///
  /// The event [AccelerometerOffsetRead] is fired when the offset has been read.
  /// Returns `true` if the request was successfully made, `false` otherwise.
  Future<bool> getAccelerometerOffset() async {
    if (!connected) {
      throw ESenseException('Not connected to any eSense device.');
    }
    return await _eSenseManagerMethodChannel
            .invokeMethod<bool?>('getAccelerometerOffset') ??
        false;
  }

  /// Requests a read of the parameter values of advertisement and connection
  /// interval of the connected device.
  ///
  /// The event [AdvertisementAndConnectionIntervalRead] is fired when the
  /// parameter values has been read.
  /// Returns `true` if the request was successfully made, `false` otherwise.
  Future<bool> getAdvertisementAndConnectionInterval() async {
    if (!connected) {
      throw ESenseException('Not connected to any eSense device.');
    }
    return await _eSenseManagerMethodChannel
            .invokeMethod<bool?>('getAdvertisementAndConnectionInterval') ??
        false;
  }

  /// Requests a change of the advertisement and connection intervals on the
  /// connected device.
  ///
  /// Condition for advertisement interval:
  ///    * the minimum interval should be greater than or equal to 100
  ///    * the maximum interval should be less than or equal to 2000
  ///    * the maximum interval should be greater than or equal to the minimum
  ///      interval.
  ///
  /// Condition for connection interval:
  ///    * the minimum interval should be greater than or equal to 20
  ///    * the maximum interval should be less than or equal to 2000
  ///    * the difference between the maximum and minimum intervals should be
  ///      greater than or equal to 20.
  ///
  /// Returns `true` if the request was successfully made, `false` otherwise.
  Future<bool> setAdvertisementAndConnectionInterval(int advMinInterval,
      int advMaxInterval, int connMinInterval, int connMaxInterval) async {
    if (!connected) {
      throw ESenseException('Not connected to any eSense device.');
    }
    return await _eSenseManagerMethodChannel.invokeMethod<bool?>(
            'setAdvertisementAndConnectiontInterval', <String, dynamic>{
          'advMinInterval': advMinInterval,
          'advMaxInterval': advMaxInterval,
          'connMinInterval': connMinInterval,
          'connMaxInterval': connMaxInterval,
        }) ??
        false;
  }

  /// Requests a read of the sensor configuration of the connected device.
  /// Right now not implemented on the Flutter side, i.e. the [ESenseConfig]
  /// class is empty.
  ///
  /// The event [SensorConfigRead] is fired when the offset has been read.
  /// Returns `true` if the request was successfully made, `false` otherwise.
  Future<bool> getSensorConfig() async {
    if (!connected) {
      throw ESenseException('Not connected to any eSense device.');
    }
    return await _eSenseManagerMethodChannel
            .invokeMethod<bool?>('getSensorConfig') ??
        false;
  }

  /// Requests a change of the sensor configuration on the connected device.
  ///
  /// Returns `true` if the request was successfully made, `false` otherwise.
  Future<bool> setSensorConfig(ESenseConfig config) async {
    if (!connected) {
      throw ESenseException('Not connected to any eSense device.');
    }
    return await _eSenseManagerMethodChannel.invokeMethod<bool?>(
            'setSensorConfig', config.toMap()) ??
        false;
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
  Stream<ConnectionEvent> get connectionEvents {
    if (_connectionEventStream == null) {
      _connectionEventStream = _eSenseConnectionEventChannel
          .receiveBroadcastStream()
          .map((type) => ConnectionEvent.fromString('$type'));

      // listen to the connection event in order to set the [connection] status
      _connectionEventStream?.listen((ConnectionEvent event) {
        print('$runtimeType - event: $event');

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
    return _connectionEventStream!;
  }

  /// Get the stream of events from the eSense device, once connected.
  ///
  /// Throws an [ESenseException] if not connected to an eSense device.
  /// Wait until [connected] before using this stream.
  Stream<ESenseEvent> get eSenseEvents {
    if (!connected) {
      throw ESenseException('Not connected to any eSense device.');
    }

    return _eventStream ??= _eSenseEventChannel.receiveBroadcastStream().map(
        (event) => event is Map ? ESenseEvent.fromMap(event) : ESenseEvent());
  }

  /// Get the stream of sensor events.
  ///
  /// Use the [setSamplingRate] method to set the sampling rate.
  /// Note that the sampling rate must be set **before** listening is started.
  ///
  /// Throws an [ESenseException] if not connected to an eSense device.
  /// Wait until [connected] before using this stream.
  Stream<SensorEvent> get sensorEvents {
    if (!connected) {
      throw ESenseException('Not connected to any eSense device.');
    }

    return _sensorStream ??= _eSenseSensorEventChannel
        .receiveBroadcastStream()
        .map((event) =>
            event is Map ? SensorEvent.fromMap(event) : SensorEvent.empty());
  }
}

/// A custom exception for eSense operations.
class ESenseException implements Exception {
  final String message;
  ESenseException(this.message);
  @override
  String toString() => '$runtimeType - $message';
}
