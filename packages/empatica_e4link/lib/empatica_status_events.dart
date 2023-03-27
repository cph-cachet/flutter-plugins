part of empaticae4;

enum EmpaSensorType {
  bvp,
  gsr,
  acc,
  temp,
}

enum StatusType {
  updateStatus,
  establishConnection,
  updateSensorStatus,
  discoverDevice,
  failedScanning,
  requestEnableBluetooth,
  bluetoothStateChanged,
  updateOnWristStatus,
  listen,
}

class EmpaticaStatusEvent {
  EmpaticaStatusEvent();

  factory EmpaticaStatusEvent.fromMap(Map<dynamic, dynamic> map) {
    final String type = map['type'];
    switch (type) {
      case 'Listen':
        return Listen.fromMap(map);
      case 'UpdateStatus':
        return UpdateStatus.fromMap(map);
      case 'EstablishConnection':
        return EstablishConnection.fromMap(map);
      case 'UpdateSensorStatus':
        return UpdateSensorStatus.fromMap(map);
      case 'DiscoverDevice':
        return DiscoverDevice.fromMap(map);
      case 'FailedScanning':
        return FailedScanning.fromMap(map);
      case 'RequestEnableBluetooth':
        return RequestEnableBluetooth.fromMap(map);
      case 'bluetoothStateChanged':
        return BluetoothStateChanged.fromMap(map);
      default:
        return EmpaticaStatusEvent();
    }
  }

  @override
  String toString() => '$runtimeType';
}

enum EmpaStatus {
  initial,
  connected,
  connecting,
  disconnected,
  disconnecting,
  discovering,
  ready,
  unknown,
}

class StatusFactory {
  EmpaStatus status;

  StatusFactory(this.status);
  factory StatusFactory.fromString(String type) {
    switch (type.toLowerCase()) {
      case 'connected':
        return StatusFactory(EmpaStatus.connected);
      case 'connecting':
        return StatusFactory(EmpaStatus.connecting);
      case 'disconnected':
        return StatusFactory(EmpaStatus.disconnected);
      case 'disconnecting':
        return StatusFactory(EmpaStatus.disconnecting);
      case 'discovering':
        return StatusFactory(EmpaStatus.discovering);
      case 'ready':
        return StatusFactory(EmpaStatus.ready);
      default:
        return StatusFactory(EmpaStatus.unknown);
    }
  }
}

class UpdateStatus extends EmpaticaStatusEvent {
  final EmpaStatus status;
  String type;

  UpdateStatus(this.type, this.status);

  factory UpdateStatus.fromMap(Map<dynamic, dynamic> map) {
    final String type = map['type'];
    final EmpaStatus status = StatusFactory.fromString(map['status']).status;
    return UpdateStatus(type, status);
  }
}

class EstablishConnection extends EmpaticaStatusEvent {
  String type;

  EstablishConnection(this.type);

  factory EstablishConnection.fromMap(Map<dynamic, dynamic> map) {
    final String type = map['type'];
    return EstablishConnection(type);
  }
}

class UpdateSensorStatus extends EmpaticaStatusEvent {
  final String sensorType;
  final int status;
  String type;

  UpdateSensorStatus(this.type, this.sensorType, this.status);

  factory UpdateSensorStatus.fromMap(Map<dynamic, dynamic> map) {
    final String type = map['type'];
    final String sensorType = map['empaSensorType'];
    final int status = map['status'];
    return UpdateSensorStatus(type, sensorType, status);
  }
}

class DiscoverDevice extends EmpaticaStatusEvent {
  final String device;
  final String label;
  final int rssi;
  String type;

  DiscoverDevice(this.type, this.device, this.label, this.rssi);

  factory DiscoverDevice.fromMap(Map<dynamic, dynamic> map) {
    final String type = map['type'];
    final String device = map['device'];
    final String label = map['deviceLabel'];
    final int rssi = map['rssi'];
    return DiscoverDevice(type, device, label, rssi);
  }
}

class FailedScanning extends EmpaticaStatusEvent {
  final dynamic errorCode;
  String type;

  FailedScanning(this.type, this.errorCode);

  factory FailedScanning.fromMap(Map<dynamic, dynamic> map) {
    final String type = map['type'];
    final dynamic errorCode = map['errorCode'];
    return FailedScanning(type, errorCode);
  }
}

class RequestEnableBluetooth extends EmpaticaStatusEvent {
  String type;

  RequestEnableBluetooth(this.type);

  factory RequestEnableBluetooth.fromMap(Map<dynamic, dynamic> map) {
    final String type = map['type'];
    return RequestEnableBluetooth(type);
  }
}

class BluetoothStateChanged extends EmpaticaStatusEvent {
  String type;

  BluetoothStateChanged(this.type);

  factory BluetoothStateChanged.fromMap(Map<dynamic, dynamic> map) {
    final String type = map['type'];
    return BluetoothStateChanged(type);
  }
}

class Listen extends EmpaticaStatusEvent {
  String type;

  Listen(this.type);

  factory Listen.fromMap(Map<dynamic, dynamic> map) {
    final String type = map['type'];
    return Listen(type);
  }
}
