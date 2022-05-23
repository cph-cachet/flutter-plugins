part of empaticae4;

class EmpaticaDataEvent {
  EmpaticaDataEvent();

  factory EmpaticaDataEvent.fromMap(Map<dynamic, dynamic> map) {
    final String type = map['type'];
    switch (type) {
      case 'ReceiveBVP':
        return ReceieveBVP.fromMap(map);
      case 'ReceiveGSR':
        return ReceiveGSR.fromMap(map);
      case 'ReceiveIBI':
        return ReceiveIBI.fromMap(map);
      case 'ReceiveTemperature':
        return ReceiveTemperature.fromMap(map);
      case 'ReceiveAcceleration':
        return ReceiveAcceleration.fromMap(map);
      case 'ReceiveBatteryLevel':
        return ReceieveBatteryLevel.fromMap(map);
      case 'ReceiveTag':
        return ReceiveTag.fromMap(map);
      case 'UpdateOnWristStatus':
        return UpdateOnWristStatus.fromMap(map);
      default:
        return EmpaticaDataEvent();
    }
  }

  @override
  String toString() => '$runtimeType';
}

class ReceieveBVP extends EmpaticaDataEvent {
  final double bvp;
  final double timestamp;

  ReceieveBVP(this.timestamp, this.bvp);

  factory ReceieveBVP.fromMap(Map<dynamic, dynamic> map) {
    final double timestamp = map['timestamp'];
    final double bvp = map['bvp'];
    return ReceieveBVP(timestamp, bvp);
  }

  @override
  String toString() => 'ReceieveBVP{bvp: $bvp}';
}

class ReceiveGSR extends EmpaticaDataEvent {
  final double gsr;
  final double timestamp;

  ReceiveGSR(this.timestamp, this.gsr);

  factory ReceiveGSR.fromMap(Map<dynamic, dynamic> map) {
    final double timestamp = map['timestamp'];
    final double gsr = map['gsr'];
    return ReceiveGSR(timestamp, gsr);
  }

  @override
  String toString() => 'ReceiveGSR{gsr: $gsr}';
}

class ReceiveIBI extends EmpaticaDataEvent {
  final double ibi;
  final double timestamp;

  ReceiveIBI(this.timestamp, this.ibi);

  factory ReceiveIBI.fromMap(Map<dynamic, dynamic> map) {
    final double timestamp = map['timestamp'];
    final double ibi = map['ibi'];
    return ReceiveIBI(timestamp, ibi);
  }

  @override
  String toString() => 'ReceiveIBI{ibi: $ibi}';
}

class ReceiveTemperature extends EmpaticaDataEvent {
  final double temperature;
  final double timestamp;

  ReceiveTemperature(this.timestamp, this.temperature);

  factory ReceiveTemperature.fromMap(Map<dynamic, dynamic> map) {
    final double timestamp = map['timestamp'];
    final double temperature = map['temperature'];
    return ReceiveTemperature(timestamp, temperature);
  }

  @override
  String toString() => 'ReceiveTemperature{temperature: $temperature}';
}

class ReceiveAcceleration extends EmpaticaDataEvent {
  final int x;
  final int y;
  final int z;
  final double timestamp;

  ReceiveAcceleration(this.timestamp, this.x, this.y, this.z);

  factory ReceiveAcceleration.fromMap(Map<dynamic, dynamic> map) {
    final double timestamp = map['timestamp'];
    final int x = map['x'];
    final int y = map['y'];
    final int z = map['z'];
    return ReceiveAcceleration(timestamp, x, y, z);
  }

  @override
  String toString() => 'ReceiveAcceleration{x: $x, y: $y, z: $z}';
}

class ReceieveBatteryLevel extends EmpaticaDataEvent {
  final double batteryLevel;
  final double timestamp;

  ReceieveBatteryLevel(this.timestamp, this.batteryLevel);

  factory ReceieveBatteryLevel.fromMap(Map<dynamic, dynamic> map) {
    final double timestamp = map['timestamp'];
    final double batteryLevel = map['batteryLevel'];
    return ReceieveBatteryLevel(timestamp, batteryLevel);
  }

  @override
  String toString() => 'ReceieveBatteryLevel{batteryLevel: $batteryLevel}';
}

class ReceiveTag extends EmpaticaDataEvent {
  final double timestamp;

  ReceiveTag(this.timestamp);

  factory ReceiveTag.fromMap(Map<dynamic, dynamic> map) {
    return ReceiveTag(map['timestamp']);
  }

  @override
  String toString() => 'ReceiveTag{}';
}

class UpdateOnWristStatus extends EmpaticaDataEvent {
  final int status;
  String type;

  UpdateOnWristStatus(this.type, this.status);

  factory UpdateOnWristStatus.fromMap(Map<dynamic, dynamic> map) {
    final String type = map['type'];
    final int status = map['status'];
    return UpdateOnWristStatus(type, status);
  }
}
