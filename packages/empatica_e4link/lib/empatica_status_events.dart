part of empaticae4;

enum EmpaStatus {
  initial,
  ready,
  disconnected,
  connecting,
  connected,
  disconnecting,
  discovering,
}

enum EmpaSensorType {
  bvp,
  gsr,
  acc,
  temp,
}

class EmpaticaStatusEvent {
  EmpaticaStatusEvent();

  factory EmpaticaStatusEvent.fromMap(Map<dynamic, dynamic> map) {
    final String type = map['type'];
    switch (type) {
      case 'Listen':
        return RegisterListenerEvent();
      case 'UpdateStatus':
        return UpdateStatusEvent.fromMap(map);
      case 'EstablishConnection':
        return EstablishConnectionEvent();
      case 'UpdateSensorStatus':
        return UpdateSensorStatusEvent.fromMap(map);
      case 'DiscoverDevice':
        return DiscoverDeviceEvent.fromMap(map);
      case 'FailedScanning':
        return FailedScanningEvent.fromMap(map);
      case 'RequestEnableBluetooth':
        return RequestEnableBluetoothEvent();
      case 'bluetoothStateChanged':
        return BluetoothStateChangedEvent();
      case 'UpdateOnWristStatus':
        return UpdateOnWristStatus.fromMap(map);
      default:
        return EmpaticaStatusEvent();
    }
  }

  @override
  String toString() => '$runtimeType';
}

class UpdateOnWristStatus extends EmpaticaStatusEvent {
  final int status;

  UpdateOnWristStatus(this.status);

  factory UpdateOnWristStatus.fromMap(Map<dynamic, dynamic> map) {
    return UpdateOnWristStatus(map['status']);
  }
}

class BluetoothStateChangedEvent extends EmpaticaStatusEvent {
  BluetoothStateChangedEvent();

  @override
  String toString() {
    return 'BluetoothStateChangedEvent';
  }
}

class RequestEnableBluetoothEvent extends EmpaticaStatusEvent {
  RequestEnableBluetoothEvent();

  @override
  String toString() {
    return 'RequestEnableBluetoothEvent';
  }
}

class FailedScanningEvent extends EmpaticaStatusEvent {
  int errorCode;

  FailedScanningEvent(this.errorCode);
  factory FailedScanningEvent.fromMap(Map<dynamic, dynamic> map) {
    return FailedScanningEvent(map['errorCode']);
  }

  @override
  String toString() {
    return 'FailedScanningEvent{errorCode: $errorCode}';
  }
}

class DiscoverDeviceEvent extends EmpaticaStatusEvent {
  String? deviceId;
  String? deviceLabel;
  String? rssi;

  DiscoverDeviceEvent(this.deviceId, this.deviceLabel, this.rssi);
  factory DiscoverDeviceEvent.fromMap(Map<dynamic, dynamic> map) {
    final String deviceId = map['deviceId'];
    final String deviceLabel = map['deviceLabel'];
    final String rssi = map['rssi'];
    return DiscoverDeviceEvent(deviceId, deviceLabel, rssi);
  }

  @override
  String toString() {
    return 'DiscoverDeviceEvent{deviceId: $deviceId, deviceLabel: $deviceLabel, rssi: $rssi}';
  }
}

class EstablishConnectionEvent extends EmpaticaStatusEvent {
  EstablishConnectionEvent();

  @override
  String toString() {
    return 'EstablishConnectionEvent';
  }
}

class UpdateStatusEvent extends EmpaticaStatusEvent {
  final EmpaStatus? status;

  UpdateStatusEvent(this.status);
  factory UpdateStatusEvent.fromMap(Map<dynamic, dynamic> map) {
    return UpdateStatusEvent(EmpaStatus.values[map['status']]);
  }

  @override
  String toString() {
    return 'UpdateStatusEvent{status: $status}';
  }
}

class UpdateSensorStatusEvent extends EmpaticaStatusEvent {
  final EmpaSensorType type;
  final int status;

  UpdateSensorStatusEvent(this.type, this.status);
  factory UpdateSensorStatusEvent.fromMap(Map<dynamic, dynamic> map) {
    return UpdateSensorStatusEvent(map['sensor'], map['status']);
  }

  @override
  String toString() {
    return 'UpdateSensorStatusEvent{sensor: $type, status: $status}';
  }
}

/// Called when an event listener is registered to the eSense device.
class RegisterListenerEvent extends EmpaticaStatusEvent {
  /// Was registration successful?
  RegisterListenerEvent() : super();

  @override
  String toString() => '$runtimeType - success';
}
