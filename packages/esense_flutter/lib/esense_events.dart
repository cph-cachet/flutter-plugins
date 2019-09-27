/*
 * Copyright 2019 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of esense;

enum ConnectionType {
  unknown,
  connected,
  disconnected,
  device_found,
  device_not_found,
}

class ConnectionEvent {
  ConnectionType type;

  ConnectionEvent(this.type) : super();

  factory ConnectionEvent.fromString(String type) {
    switch (type) {
      case 'connected':
        return ConnectionEvent(ConnectionType.connected);
      case 'disconnected':
        return ConnectionEvent(ConnectionType.disconnected);
      case 'device_found':
        return ConnectionEvent(ConnectionType.device_found);
      case 'device_not_found':
        return ConnectionEvent(ConnectionType.device_not_found);
      default:
        return ConnectionEvent(ConnectionType.unknown);
    }
  }

  String toString() => 'ConnectionEvent - type: $type';
}

/// Contains data from a sensor event.
///
/// In the eSense Android API, this event is called an [`ESenseEvent`]().
/// But this is confusing, since these event arise from a [`ESenseSensorListener`]().
/// Hence, in Flutter we have chosen to call these sensor events for [SensorEvent].
class SensorEvent {
  /// Phone timestamp
  DateTime timestamp;

  /// Sequential number of sensor packet
  ///
  /// The eSense device don't have a clock, so this index reflect the order of reading.
  /// The index is reset to zero when listening is started. Hence, the index is __only__
  /// unique within each listening session.
  int packetIndex;

  /// 3-elements array with X, Y and Z axis for accelerometer
  List<int> accel;

  /// 3-elements array with X, Y and Z axis for gyroscope
  List<int> gyro;

  SensorEvent({this.timestamp, this.packetIndex, this.accel, this.gyro});

  factory SensorEvent.fromMap(Map<dynamic, dynamic> map) {
    //map.forEach((key, value) => print(' > map[$key] = $value'));
    DateTime time = DateTime.fromMillisecondsSinceEpoch(map['timestamp']);
    int index = map['packetIndex'];
    List<int> accl = [map['accel.x'], map['accel.y'], map['accel.z']];
    List<int> gyro = [map['gyro.x'], map['gyro.y'], map['gyro.z']];

    return SensorEvent(timestamp: time, packetIndex: index, accel: accl, gyro: gyro);
  }

  String toString() =>
      'SensorEvent - timestamp: $timestamp, packetIndex: $packetIndex, accl: [${accel[0]},${accel[1]},${accel[2]}], gyro: [${gyro[0]},${gyro[1]},${gyro[2]}]';
}

/// Default eSense event class.
class ESenseEvent {
  String type;
  ESenseEvent([this.type]);

  factory ESenseEvent.fromMap(Map<dynamic, dynamic> map) {
    final String type = map['type'];
    switch (type) {
      case 'Listen':
        return RegisterEventListener(map['success']);
      case 'DeviceNameRead':
        return DeviceNameRead.fromMap(map);
      case 'BatteryRead':
        return BatteryRead.fromMap(map);
      case 'AccelerometerOffsetRead':
        return AccelerometerOffsetRead.fromMap(map);
      case 'AdvertisementAndConnectionIntervalRead':
        return AdvertisementAndConnectionIntervalRead.fromMap(map);
      case 'ButtonEventChanged':
        return ButtonEventChanged.fromMap(map);
      case 'SensorConfigRead':
        return SensorConfigRead.fromMap(map);
      default:
        return ESenseEvent(type);
    }
  }

  String toString() => 'ESenseEvent - type: $type';
}

/// Called when an event listener is registered to the eSense device.
class RegisterEventListener extends ESenseEvent {
  /// was registration successful?
  bool success;
  RegisterEventListener(this.success) : super();
  String toString() => 'RegisterEventListener - success: $success';
}

/// Called when the information on accelerometer offset has been received
class AccelerometerOffsetRead extends ESenseEvent {
  /// x-axis factory offset
  int offsetX;

  /// y-axis factory offset
  int offsetY;

  /// z-axis factory offset
  int offsetZ;

  AccelerometerOffsetRead(this.offsetX, this.offsetY, this.offsetZ) : super();
  factory AccelerometerOffsetRead.fromMap(Map<dynamic, dynamic> map) =>
      AccelerometerOffsetRead(map['offsetX'], map['offsetY'], map['offsetZ']);
  //AccelerometerOffsetRead(int.tryParse(map['offsetX']), int.tryParse(map['offsetY']), int.tryParse(map['offsetZ']));

  String toString() => 'AccelerometerOffsetRead - '
      'offsetX: $offsetX, '
      'offsetY: $offsetY, '
      'offsetZ: $offsetZ';
}

/// Called when the information on advertisement and connection interval has been received.
class AdvertisementAndConnectionIntervalRead extends ESenseEvent {
  /// minimum advertisement interval in milliseconds
  int minAdvertisementInterval;

  /// maximum advertisement interval in milliseconds
  int maxAdvertisementInterval;

  /// minimum connection interval in milliseconds
  int minConnectionInterval;

  /// maximum connection interval in milliseconds
  int maxConnectionInterval;

  AdvertisementAndConnectionIntervalRead(this.minAdvertisementInterval, this.maxAdvertisementInterval,
      this.minConnectionInterval, this.maxConnectionInterval)
      : super();
  factory AdvertisementAndConnectionIntervalRead.fromMap(Map<dynamic, dynamic> map) =>
      AdvertisementAndConnectionIntervalRead(
        map['minAdvertisementInterval'],
        map['maxAdvertisementInterval'],
        map['minConnectionInterval'],
        map['maxConnectionInterval'],
      );
//          int.tryParse(map['minAdvertisementInterval']),
//          int.tryParse(map['maxAdvertisementInterval']),
//          int.tryParse(map['minConnectionInterval']),
//          int.tryParse(map['maxConnectionInterval']));

  String toString() => 'AdvertisementAndConnectionIntervalRead - '
      'minAdvertisementInterval: $minAdvertisementInterval, '
      'maxAdvertisementInterval: $maxAdvertisementInterval, '
      'minConnectionInterval: $minConnectionInterval, '
      'maxConnectionInterval: $maxConnectionInterval';
}

/// Called when the information on battery voltage has been received
class BatteryRead extends ESenseEvent {
  /// eSense battery voltage in Volts
  double voltage;

  BatteryRead(this.voltage) : super();
  //factory BatteryRead.fromMap(Map<dynamic, dynamic> map) => BatteryRead(int.tryParse(map['voltage']));
  factory BatteryRead.fromMap(Map<dynamic, dynamic> map) => BatteryRead(map['voltage']);

  String toString() => 'BatteryRead - voltage: $voltage';
}

/// Called when the button event has changed
class ButtonEventChanged extends ESenseEvent {
  /// true if the button is pressed, false if it is released
  bool pressed;

  ButtonEventChanged(this.pressed) : super();
  factory ButtonEventChanged.fromMap(Map<dynamic, dynamic> map) => ButtonEventChanged(map['pressed']);

  String toString() => 'ButtonEventChanged - pressed: $pressed';
}

/// Called when the information on the device name has been received
class DeviceNameRead extends ESenseEvent {
  /// Name of the eSense device
  String deviceName;

  DeviceNameRead(this.deviceName) : super();
  factory DeviceNameRead.fromMap(Map<dynamic, dynamic> map) => DeviceNameRead(map['deviceName']);

  String toString() => 'DeviceNameRead - name: $deviceName';
}

/// Called when the information on sensor configuration has been received
///
/// Currently __not__ implemented in this Flutter Plugin, i.e. the [ESenseConfig] class is empty.
class SensorConfigRead extends ESenseEvent {
  ESenseConfig config;

  SensorConfigRead() : super();
  factory SensorConfigRead.fromMap(Map<dynamic, dynamic> map) => SensorConfigRead()..config = ESenseConfig();

  String toString() => 'SensorConfigRead - config: $config';
}
