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

  int packetIndex;

  /// 3-elements array with X, Y and Z axis for accelerometer
  List<int> accel;

  /// 3-elements array with X, Y and Z axis for gyroscope
  List<int> gyro;

  SensorEvent() : super();

  factory SensorEvent.fromMap(Map<dynamic, dynamic> map) {
    return SensorEvent();
  }
}

/// Default eSense event class.
class ESenseEvent {
  bool success;

  ESenseEvent([this.success]) : super();

  factory ESenseEvent.fromMap(Map<dynamic, dynamic> map) {
    String type = map['type'];
    switch (type) {
      case 'Listen':
        return ESenseEvent(map['success']);
      case 'DeviceNameRead':
        return DeviceNameRead.fromMap(map);
      case 'BatteryRead':
        return BatteryRead.fromMap(map);

      default:
        return ESenseEvent();
    }
  }

  String toString() => 'ESenseEvent - success: $success';
}

/// Called when the information on accelerometer offset has been received
class AccelerometerOffsetRead extends ESenseEvent {
  int offsetX;
  int offsetY;
  int offsetZ;

  AccelerometerOffsetRead(this.offsetX, this.offsetY, this.offsetZ) : super();
  factory AccelerometerOffsetRead.fromMap(Map<dynamic, dynamic> map) {
    return AccelerometerOffsetRead(
        int.tryParse(map['offsetX']), int.tryParse(map['offsetY']), int.tryParse(map['offsetZ']));
  }
}

/// Called when the information on advertisement and connection interval has been received.
class AdvertisementAndConnectionIntervalRead extends ESenseEvent {
  int minAdvertisementInterval;
  int maxAdvertisementInterval;
  int minConnectionInterval;
  int maxConnectionInterval;

  AdvertisementAndConnectionIntervalRead(this.minAdvertisementInterval, this.maxAdvertisementInterval,
      this.minConnectionInterval, this.maxConnectionInterval)
      : super();
  factory AdvertisementAndConnectionIntervalRead.fromMap(Map<dynamic, dynamic> map) {
    return AdvertisementAndConnectionIntervalRead(
        int.tryParse(map['minAdvertisementInterval']),
        int.tryParse(map['maxAdvertisementInterval']),
        int.tryParse(map['minConnectionInterval']),
        int.tryParse(map['maxConnectionInterval']));
  }
}

/// Called when the information on battery voltage has been received
class BatteryRead extends ESenseEvent {
  int voltage;

  BatteryRead(this.voltage) : super();
  factory BatteryRead.fromMap(Map<dynamic, dynamic> map) {
    return BatteryRead(int.tryParse(map['voltage']));
  }

  String toString() => 'BatteryRead - voltage: $voltage';
}

/// Called when the button event has changed
class ButtonEventChanged extends ESenseEvent {
  bool pressed;

  ButtonEventChanged(this.pressed) : super();
  factory ButtonEventChanged.fromMap(Map<dynamic, dynamic> map) {
    return ButtonEventChanged(map['pressed']);
  }

  String toString() => 'ButtonEventChanged - pressed: $pressed';
}

/// Called when the information on the device name has been received
class DeviceNameRead extends ESenseEvent {
  String name;

  DeviceNameRead(this.name) : super();
  factory DeviceNameRead.fromMap(Map<dynamic, dynamic> map) {
    return DeviceNameRead(map['name']);
  }

  String toString() => 'DeviceNameRead - name: $name';
}

/// Called when the information on sensor configuration has been received
///
/// Currently __not__ implemented in this Flutter Plugin.
class SensorConfigRead extends ESenseEvent {
  SensorConfigRead() : super();
  factory SensorConfigRead.fromMap(Map<dynamic, dynamic> map) {
    return SensorConfigRead();
  }
}
