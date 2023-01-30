/*
 * Copyright 2022 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
part of movisens_flutter;

/// Enumeration of the service types supported by Movisens devices
enum MovisensServiceTypes {
  ambient,
  eda,
  hrv,
  marker,
  battery,
  userData,
  physicalActivity,
  respiration,
  sensorControl,
  skinTemperature,

  // General bluetooth 4.0 services:
  deviceInformation,
}

/// A basic Movisens service interface.
abstract class MovisensService {
  /// UUID of this service.
  abstract final String uuid;

  /// The underlying [BluetoothService] for this service.
  late BluetoothService _bluetoothService;

  /// The list of Bluetooth characteristics for this service.
  abstract List<MovisensBluetoothCharacteristics> characteristics;

  /// The string representation of the service enum.
  String get name => serviceUUIDToName[uuid]!.name;
}

/// A basic Movisens service interface with a stream for streamed events.
abstract class StreamingMovisensService extends MovisensService {
  // Stream of [MovisensEvent]s
  late Stream<MovisensEvent> _events;

  /// A stream of all the [MovisensEvent]s emitted by the characteristics in this service.
  Stream<MovisensEvent> get events => _events;

  /// Enables the notifying of ***every*** bluetooth characteristic in this service.
  ///
  Future<void> enableNotify() async {
    for (BluetoothCharacteristic characteristic
        in _bluetoothService.characteristics) {
      String charUuid = characteristic.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];
      if (characteristics.contains(moviChar) &&
          characteristic.properties.notify) {
        await characteristic.setNotifyValue(true);
        _log.info(
            "Enabling [Notify] for [${enumToReadableString(characteristicUUIDToMovisensBluetoothCharacteristics[characteristic.uuid.toString()]!)}] in service [${enumToReadableString(serviceUUIDToName[uuid]!)}] Movisens device [${_bluetoothService.deviceId.id}]");
      }
    }
  }

  /// Disables the notifying of all bluetooth characteristic in this service.
  Future<void> disableNotify() async {
    for (BluetoothCharacteristic characteristic
        in _bluetoothService.characteristics) {
      String charUuid = characteristic.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];
      if (characteristics.contains(moviChar) &&
          characteristic.properties.notify) {
        await characteristic.setNotifyValue(false);
        _log.info(
            "Disabling [Notify] for [${enumToReadableString(characteristicUUIDToMovisensBluetoothCharacteristics[characteristic.uuid.toString()]!)}] in service [${enumToReadableString(serviceUUIDToName[uuid]!)}] Movisens device [${_bluetoothService.deviceId.id}]");
      }
    }
  }
}

/// A Movisens service containing Ambient data.
///
/// Included characteristics:
/// * [MovisensBluetoothCharacteristics.light]
/// * [MovisensBluetoothCharacteristics.lightRGB]
/// * [MovisensBluetoothCharacteristics.sensorTemperature]
class AmbientService extends StreamingMovisensService {
  @override
  List<MovisensBluetoothCharacteristics> characteristics = [
    MovisensBluetoothCharacteristics.light,
    MovisensBluetoothCharacteristics.lightRGB,
    MovisensBluetoothCharacteristics.sensorTemperature
  ];

  // TODO: Handle buffered values

  Stream<LightEvent>? _lightEvents;
  Stream<LightRGBEvent>? _lightRGBEvents;
  Stream<SensorTemperatureEvent>? _sensorTemperatureEvents;

  /// Stream of [LightEvent]s
  Stream<LightEvent>? get lightEvents => _lightEvents;

  /// Stream of [LightRGBEvent]s
  Stream<LightRGBEvent>? get lightRGBEvents => _lightRGBEvents;

  /// Stream of [SensorTemperatureEvent]s
  Stream<SensorTemperatureEvent>? get sensorTemperatureEvents =>
      _sensorTemperatureEvents;

  /// A Movisens service containing Ambient data.
  AmbientService({required BluetoothService service}) {
    _bluetoothService = service;
    List<Stream<MovisensEvent>> nonNullStreams = [];
    // For each characteristic that is supported in the service
    for (BluetoothCharacteristic char in _bluetoothService.characteristics) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];

      // add light stream
      if (moviChar == MovisensBluetoothCharacteristics.light) {
        _lightEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => LightEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_lightEvents!);
      }
      // add light RGB stream
      else if (moviChar == MovisensBluetoothCharacteristics.lightRGB) {
        _lightRGBEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => LightRGBEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_lightRGBEvents!);
      } // add sensor temperature stream
      else if (moviChar == MovisensBluetoothCharacteristics.sensorTemperature) {
        _sensorTemperatureEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => SensorTemperatureEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_sensorTemperatureEvents!);
      }
    }
    _events = Rx.merge(nonNullStreams);
  }

  @override
  String uuid = serviceToUuid[MovisensServiceTypes.ambient]!;
}

/// A Movisens service containing EDA (Electrodermal Activity) data.
///
/// Included characteristics:
/// * [MovisensBluetoothCharacteristics.edaSclMean]
class EdaService extends StreamingMovisensService {
  @override
  List<MovisensBluetoothCharacteristics> characteristics = [
    MovisensBluetoothCharacteristics.edaSclMean
  ];

  // TODO: Handle buffered values

  Stream<EdaSclMeanEvent>? _edaSclMeanEvents;

  /// Stream of [EdaSclMeanEvent]s
  Stream<EdaSclMeanEvent>? get edaSclMeanEvents => _edaSclMeanEvents;

  /// A Movisens service containing EDA (Electrodermal Activity) data.
  EdaService({required BluetoothService service}) {
    _bluetoothService = service;
    List<Stream<MovisensEvent>> nonNullStreams = [];
    for (BluetoothCharacteristic char in _bluetoothService.characteristics) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];

      // add eda scl stream
      if (moviChar == MovisensBluetoothCharacteristics.edaSclMean) {
        _edaSclMeanEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => EdaSclMeanEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_edaSclMeanEvents!);
      }
    }
    _events = Rx.merge(nonNullStreams);
  }

  @override
  String uuid = serviceToUuid[MovisensServiceTypes.eda]!;
}

/// A Movisens service containing HRV related data.
///
/// Included characteristics:
/// * [MovisensBluetoothCharacteristics.heartRateMeasurement]
/// * [MovisensBluetoothCharacteristics.hrMean]
/// * [MovisensBluetoothCharacteristics.hrvIsValid]
/// * [MovisensBluetoothCharacteristics.rmssd]
class HrvService extends StreamingMovisensService {
  BluetoothService? _heartRateMeasurementService;

  @override
  Future<void> enableNotify() async {
    super.enableNotify();
    for (BluetoothCharacteristic characteristic
        in _heartRateMeasurementService?.characteristics ?? []) {
      if (characteristics.contains(
              characteristicUUIDToMovisensBluetoothCharacteristics[
                  characteristic.uuid.toString()]) &&
          characteristic.properties.notify) {
        await characteristic.setNotifyValue(true);
        _log.info(
            "Enabling [Notify] for [${enumToReadableString(characteristicUUIDToMovisensBluetoothCharacteristics[characteristic.uuid.toString()]!)}] in service [${enumToReadableString(serviceUUIDToName[uuid]!)}] Movisens device [${_bluetoothService.deviceId.id}]");
      }
    }
  }

  @override
  Future<void> disableNotify() async {
    super.disableNotify();
    for (BluetoothCharacteristic characteristic
        in _heartRateMeasurementService?.characteristics ?? []) {
      String charUuid = characteristic.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];
      if (characteristics.contains(moviChar) &&
          characteristic.properties.notify) {
        await characteristic.setNotifyValue(false);
        _log.info(
            "Disabling [Notify] for [${enumToReadableString(characteristicUUIDToMovisensBluetoothCharacteristics[characteristic.uuid.toString()]!)}] in service [${enumToReadableString(serviceUUIDToName[uuid]!)}] Movisens device [${_bluetoothService.deviceId.id}]");
      }
    }
  }

  @override
  List<MovisensBluetoothCharacteristics> characteristics = [
    MovisensBluetoothCharacteristics.heartRateMeasurement,
    MovisensBluetoothCharacteristics.hrMean,
    MovisensBluetoothCharacteristics.hrvIsValid,
    MovisensBluetoothCharacteristics.rmssd
  ];

  // TODO: Handle buffered values

  Stream<HrMeanEvent>? _hrMeanEvents;
  Stream<HrvIsValidEvent>? _hrvIsValidEvents;
  Stream<RmssdEvent>? _rmssdEvents;
  Stream<HeartRateMeasurementEvent>? _heartRateMeasurementEvents;

  /// A stream of [HrMeanEvent]s
  Stream<HrMeanEvent>? get hrMeanEvents => _hrMeanEvents;

  /// A stream of [HrvIsValidEvent]s
  Stream<HrvIsValidEvent>? get hrvIsValidEvents => _hrvIsValidEvents;

  /// A stream of [RmssdEvent]s
  Stream<RmssdEvent>? get rmssd => _rmssdEvents;

  /// A stream of [HeartRateMeasurementEvent]s
  Stream<HeartRateMeasurementEvent>? get heartRateMeasurementEvents =>
      _heartRateMeasurementEvents;

  /// A Movisens service containing HRV related data.
  HrvService(
      {required BluetoothService service, BluetoothService? secondaryService}) {
    _bluetoothService = service;
    List<Stream<MovisensEvent>> nonNullStreams = [];
    // For each characteristic that is supported in the service
    for (BluetoothCharacteristic char in _bluetoothService.characteristics) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];

      // add hrMean stream
      if (moviChar == MovisensBluetoothCharacteristics.hrMean) {
        _hrMeanEvents = char.value
            .skipWhile((element) => (element.isEmpty))
            .map((event) => HrMeanEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_hrMeanEvents!);
      }
      // add hrv is valid stream
      else if (moviChar == MovisensBluetoothCharacteristics.hrvIsValid) {
        _hrvIsValidEvents = char.value
            .skipWhile((element) => (element.isEmpty))
            .map((event) => HrvIsValidEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_hrvIsValidEvents!);
      } // add rmssd stream
      else if (moviChar == MovisensBluetoothCharacteristics.rmssd) {
        _rmssdEvents = char.value
            .skipWhile((element) => (element.isEmpty))
            .map((event) => RmssdEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_rmssdEvents!);
      }
    }
    // Secondary Service
    _heartRateMeasurementService = secondaryService;
    for (BluetoothCharacteristic char
        in _heartRateMeasurementService?.characteristics ?? []) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];
      if (moviChar == MovisensBluetoothCharacteristics.heartRateMeasurement) {
        _heartRateMeasurementEvents = char.value
            .skipWhile((element) => (element.isEmpty))
            .map((event) => HeartRateMeasurementEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_heartRateMeasurementEvents!);
      }
    }
    _events = Rx.merge(nonNullStreams);
  }

  @override
  String uuid = serviceToUuid[MovisensServiceTypes.hrv]!;
}

/// A Movisens service containing marker data from user taps.
///
/// Included characteristics:
/// * [MovisensBluetoothCharacteristics.tapMarker]
class MarkerService extends StreamingMovisensService {
  @override
  List<MovisensBluetoothCharacteristics> characteristics = [
    MovisensBluetoothCharacteristics.tapMarker
  ];

  // TODO: Handle buffered values

  Stream<TapMarkerEvent>? _tapMarkerEvents;

  /// A stream of [TapMarkerEvent]s.
  Stream<TapMarkerEvent>? get tapMarkerEvents => _tapMarkerEvents;

  /// A Movisens service containing marker data from user taps.
  MarkerService({required BluetoothService service}) {
    _bluetoothService = service;
    List<Stream<MovisensEvent>> nonNullStreams = [];
    // For each characteristic that is supported in the service
    for (BluetoothCharacteristic char in _bluetoothService.characteristics) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];

      // add hrMean stream
      if (moviChar == MovisensBluetoothCharacteristics.tapMarker) {
        _tapMarkerEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => TapMarkerEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_tapMarkerEvents!);
      }
    }
    _events = Rx.merge(nonNullStreams);
  }

  @override
  String uuid = serviceToUuid[MovisensServiceTypes.marker]!;
}

/// A Movisens service containing Battery data.
///
/// Included characteristics:
/// * [MovisensBluetoothCharacteristics.batteryLevel]
/// * [MovisensBluetoothCharacteristics.charging]
class BatteryService extends StreamingMovisensService {
  BluetoothService? _batteryService;
  @override
  List<MovisensBluetoothCharacteristics> characteristics = [
    MovisensBluetoothCharacteristics.batteryLevel,
    MovisensBluetoothCharacteristics.charging
  ];

  // TODO: Handle buffered values

  @override
  Future<void> enableNotify() async {
    super.enableNotify();
    for (BluetoothCharacteristic characteristic
        in _batteryService?.characteristics ?? []) {
      if (characteristics.contains(
              characteristicUUIDToMovisensBluetoothCharacteristics[
                  characteristic.uuid.toString()]) &&
          characteristic.properties.notify) {
        await characteristic.setNotifyValue(true);
        _log.info(
            "Enabling [Notify] for [${enumToReadableString(characteristicUUIDToMovisensBluetoothCharacteristics[characteristic.uuid.toString()]!)}] in service [${enumToReadableString(serviceUUIDToName[uuid]!)}] Movisens device [${_bluetoothService.deviceId.id}]");
      }
    }
  }

  @override
  Future<void> disableNotify() async {
    super.disableNotify();
    for (BluetoothCharacteristic characteristic
        in _batteryService?.characteristics ?? []) {
      String charUuid = characteristic.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];
      if (characteristics.contains(moviChar) &&
          characteristic.properties.notify) {
        await characteristic.setNotifyValue(false);
        _log.info(
            "Disabling [Notify] for [${enumToReadableString(characteristicUUIDToMovisensBluetoothCharacteristics[characteristic.uuid.toString()]!)}] in service [${enumToReadableString(serviceUUIDToName[uuid]!)}] Movisens device [${_bluetoothService.deviceId.id}]");
      }
    }
  }

  Stream<ChargingEvent>? _chargingEvents;
  Stream<BatteryLevelEvent>? _batteryLevelEvents;

  /// Stream of [ChargingEvent]s.
  Stream<ChargingEvent>? get chargingEvents => _chargingEvents;

  /// Stream of [BatteryLevelEvent]s.
  Stream<BatteryLevelEvent>? get batteryLevelEvents => _batteryLevelEvents;

  /// A Movisens service containing Battery data.
  BatteryService(
      {required BluetoothService service, BluetoothService? secondaryService}) {
    _bluetoothService = service;
    List<Stream<MovisensEvent>> nonNullStreams = [];
    // For each characteristic that is supported in the service
    for (BluetoothCharacteristic char in _bluetoothService.characteristics) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];

      // add charging stream
      if (moviChar == MovisensBluetoothCharacteristics.charging) {
        _chargingEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => ChargingEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_chargingEvents!);
      }
    }

    // Secondary service
    _batteryService = secondaryService;
    for (BluetoothCharacteristic char
        in _batteryService?.characteristics ?? []) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];

      // add charging stream
      if (moviChar == MovisensBluetoothCharacteristics.batteryLevel) {
        _batteryLevelEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => BatteryLevelEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_batteryLevelEvents!);
      }
    }
    _events = Rx.merge(nonNullStreams);
  }

  @override
  String uuid = serviceToUuid[MovisensServiceTypes.battery]!;
}

/// Enum for sensor location
/// Represents the location on the body where the device is placed
enum SensorLocation {
  rightSideHip,
  chest,
  rightWrist,
  leftWrist,
  leftAnkle,
  rightAnkle,
  rightThigh,
  leftThigh,
  rightUpperArm,
  leftUpperArm,
  leftSideHip
}

/// A Movisens service containing User Data information.
///
/// Included characteristics:
/// * [MovisensBluetoothCharacteristics.ageFloat]
/// * [MovisensBluetoothCharacteristics.sensorLocation]
/// * [MovisensBluetoothCharacteristics.gender]
/// * [MovisensBluetoothCharacteristics.height]
/// * [MovisensBluetoothCharacteristics.weight]
class UserDataService extends MovisensService {
  BluetoothService? _baseUserData;

  @override
  List<MovisensBluetoothCharacteristics> characteristics = [
    MovisensBluetoothCharacteristics.ageFloat,
    MovisensBluetoothCharacteristics.sensorLocation,
    MovisensBluetoothCharacteristics.gender,
    MovisensBluetoothCharacteristics.height,
    MovisensBluetoothCharacteristics.weight,
  ];

  BluetoothCharacteristic? _ageFloat;
  BluetoothCharacteristic? _sensorLocation;
  BluetoothCharacteristic? _gender;
  BluetoothCharacteristic? _height;
  BluetoothCharacteristic? _weight;

  /// Get the age of the user in years.
  /// Uses double format (e.g. 23.1 or 56.4 years old).
  /// Can be null if not set previously.
  Future<double?> getAgeFloat() async {
    if (_ageFloat == null) {
      _log.warning("Age Float characteristic not found on device");
      return null;
    }
    List<int> bytes = await _ageFloat!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    double ageFloat = byteData.getFloat32(0, Endian.little);
    return ageFloat;
  }

  /// Set the age of the user in years.
  /// Uses double format (e.g. 23.1 or 56.4 years old).
  Future<void> setAgeFloat(double ageFloat) async {
    if (_ageFloat == null) {
      _log.warning("Age Float characteristic not found on device");
      return;
    }
    ByteData data = ByteData(4);
    data.setFloat32(0, ageFloat, Endian.little);
    Uint8List byteList = data.buffer.asUint8List();
    await _ageFloat!.write(byteList);
  }

  /// Get the location of the sensor on the user.
  /// Can be null if not set previously.
  Future<SensorLocation?> getSensorLocation() async {
    if (_sensorLocation == null) {
      _log.warning("Sensor Location characteristic not found on device");
      return null;
    }
    List<int> bytes = await _sensorLocation!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int sLoc = byteData.getInt8(0);
    SensorLocation? sensorLoc;
    switch (sLoc) {
      case 1:
        sensorLoc = SensorLocation.rightSideHip;
        break;
      case 2:
        sensorLoc = SensorLocation.chest;
        break;
      case 3:
        sensorLoc = SensorLocation.rightWrist;
        break;
      case 4:
        sensorLoc = SensorLocation.leftWrist;
        break;
      case 5:
        sensorLoc = SensorLocation.leftAnkle;
        break;
      case 6:
        sensorLoc = SensorLocation.rightAnkle;
        break;
      case 7:
        sensorLoc = SensorLocation.rightThigh;
        break;
      case 8:
        sensorLoc = SensorLocation.leftThigh;
        break;
      case 9:
        sensorLoc = SensorLocation.rightUpperArm;
        break;
      case 10:
        sensorLoc = SensorLocation.leftUpperArm;
        break;
      case 11:
        sensorLoc = SensorLocation.leftSideHip;
        break;
    }
    return sensorLoc;
  }

  /// Set the location of the sensor on the user.
  Future<void> setSensorLocation(SensorLocation sensorLocation) async {
    if (_sensorLocation == null) {
      _log.warning("Sensor Location characteristic not found on device");
      return;
    }
    late int sLoc;
    switch (sensorLocation) {
      case SensorLocation.rightSideHip:
        sLoc = 1;
        break;
      case SensorLocation.chest:
        sLoc = 2;
        break;
      case SensorLocation.rightWrist:
        sLoc = 3;
        break;
      case SensorLocation.leftWrist:
        sLoc = 4;
        break;
      case SensorLocation.leftAnkle:
        sLoc = 5;
        break;
      case SensorLocation.rightAnkle:
        sLoc = 6;
        break;
      case SensorLocation.rightThigh:
        sLoc = 7;
        break;
      case SensorLocation.leftThigh:
        sLoc = 8;
        break;
      case SensorLocation.rightUpperArm:
        sLoc = 9;
        break;
      case SensorLocation.leftUpperArm:
        sLoc = 10;
        break;
      case SensorLocation.leftSideHip:
        sLoc = 11;
        break;
    }
    ByteData data = ByteData(1);
    data.setUint8(0, sLoc);
    Uint8List byteList = data.buffer.asUint8List();
    await _sensorLocation!.write(byteList);
  }

  /// Get the height of the user in centimeters
  ///
  /// Can be null if not set previously.
  Future<int?> getHeight() async {
    if (_height == null) {
      _log.warning("Height characteristic not found on device");
      return null;
    }
    List<int> bytes = await _height!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int height = byteData.getUint16(0, Endian.little);
    return height;
  }

  /// Set the height of the user in centimeters
  ///
  Future<void> setHeight(int height) async {
    if (_height == null) {
      _log.warning("Height characteristic not found on device");
      return;
    }
    ByteData data = ByteData(2);
    data.setUint16(0, height, Endian.little);
    Uint8List byteList = data.buffer.asUint8List();
    await _height!.write(byteList);
  }

  /// Get the gender of the user.
  /// Uses enum [Gender]
  ///
  /// Can be null if not set previously.
  Future<Gender?> getGender() async {
    if (_gender == null) {
      _log.warning("Gender characteristic not found on device");
      return null;
    }
    List<int> bytes = await _gender!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int genderInt = byteData.getUint8(0);
    switch (genderInt) {
      case 0:
        return Gender.male;
      case 1:
        return Gender.female;
      case 2:
        return Gender.unspecified;
      case 3:
        return Gender.invalid;
      default:
        return null;
    }
  }

  /// Set the gender of the user.
  /// Uses the [Gender] enum
  Future<void> setGender(Gender gender) async {
    if (_gender == null) {
      _log.warning("Gender characteristic not found on device");
      return;
    }
    ByteData data = ByteData(1);
    data.setUint8(0, gender.value);
    Uint8List byteList = data.buffer.asUint8List();
    await _gender!.write(byteList);
  }

  /// Get the weight of the user in kg with 1 decimal.
  ///
  /// Can be null if not set previously.
  Future<double?> getWeight() async {
    if (_weight == null) {
      _log.warning("Weight characteristic not found on device");
      return null;
    }
    List<int> bytes = await _weight!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int weight = byteData.getUint16(0, Endian.little);
    return weight / 200;
  }

  /// Set the weight of the user in kg with 1 decimal.
  ///
  Future<void> setWeight(double weight) async {
    if (_weight == null) {
      _log.warning("Weight characteristic not found on device");
      return;
    }
    ByteData data = ByteData(2);
    data.setUint16(0, (weight * 200).round(), Endian.little);
    Uint8List byteList = data.buffer.asUint8List();
    await _weight!.write(byteList);
  }

  UserDataService(
      {required BluetoothService service, BluetoothService? secondaryService}) {
    _bluetoothService = service;
    for (BluetoothCharacteristic char in _bluetoothService.characteristics) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];

      // Save as age float characteristic
      if (moviChar == MovisensBluetoothCharacteristics.ageFloat) {
        _ageFloat = char;
      }
      // Save as sensor location characteristic
      if (moviChar == MovisensBluetoothCharacteristics.sensorLocation) {
        _sensorLocation = char;
      }
    }

    // Secondary service
    _baseUserData = secondaryService;
    for (BluetoothCharacteristic char
        in (_baseUserData?.characteristics ?? [])) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];

      // Save as gender characteristic
      if (moviChar == MovisensBluetoothCharacteristics.gender) {
        _gender = char;
      }
      // Save as weight characteristic
      if (moviChar == MovisensBluetoothCharacteristics.weight) {
        _weight = char;
      }
      // Save as height characteristic
      if (moviChar == MovisensBluetoothCharacteristics.height) {
        _height = char;
      }
    }
  }

  @override
  String uuid = serviceToUuid[MovisensServiceTypes.userData]!;
}

/// A Movisens service containing Physical Activity data.
///
/// Several of the characteristics require other data to be set, such as [sensorLocation], [age]
///
/// Included characteristics:
/// * [MovisensBluetoothCharacteristics.bodyPosition]
/// * [MovisensBluetoothCharacteristics.inclination]
/// * [MovisensBluetoothCharacteristics.met]
/// * [MovisensBluetoothCharacteristics.metLevel]
/// * [MovisensBluetoothCharacteristics.movementAcceleration]
/// * [MovisensBluetoothCharacteristics.steps]
class PhysicalActivityService extends StreamingMovisensService {
  @override
  List<MovisensBluetoothCharacteristics> characteristics = [
    MovisensBluetoothCharacteristics.bodyPosition,
    MovisensBluetoothCharacteristics.inclination,
    MovisensBluetoothCharacteristics.met,
    MovisensBluetoothCharacteristics.metLevel,
    MovisensBluetoothCharacteristics.movementAcceleration,
    MovisensBluetoothCharacteristics.steps
  ]; // TODO: Handle buffered values

  Stream<BodyPositionEvent>? _bodyPositionEvents;
  Stream<InclinationEvent>? _inclinationEvents;
  Stream<MetEvent>? _metEvents;
  Stream<MetLevelEvent>? _metLevelEvents;
  Stream<MovementAccelerationEvent>? _movementAccelerationEvents;
  Stream<StepsEvent>? _stepsEvents;

  /// Stream of [BodyPositionEvent]s.
  Stream<BodyPositionEvent>? get bodyPositionEvents => _bodyPositionEvents;

  /// Stream of [InclinationEvent]s.
  Stream<InclinationEvent>? get inclinationEvents => _inclinationEvents;

  /// Stream of [MetEvent]s.
  Stream<MetEvent>? get metEvents => _metEvents;

  /// Stream of [MetLevelEvent]s.
  Stream<MetLevelEvent>? get metLevelEvents => _metLevelEvents;

  /// Stream of [MovementAccelerationEvent]s.
  Stream<MovementAccelerationEvent>? get movementAccelerationEvents =>
      _movementAccelerationEvents;

  /// Stream of [StepsEvent]s.
  Stream<StepsEvent>? get stepsEvents => _stepsEvents;

  PhysicalActivityService({required BluetoothService service}) {
    _bluetoothService = service;
    List<Stream<MovisensEvent>> nonNullStreams = [];
    // For each characteristic that is supported in the service
    for (BluetoothCharacteristic char in _bluetoothService.characteristics) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];

      // add body position stream
      if (moviChar == MovisensBluetoothCharacteristics.bodyPosition) {
        _bodyPositionEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => BodyPositionEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_bodyPositionEvents!);
      } // add inclination stream
      else if (moviChar == MovisensBluetoothCharacteristics.inclination) {
        _inclinationEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => InclinationEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_inclinationEvents!);
      } // add MET stream
      else if (moviChar == MovisensBluetoothCharacteristics.met) {
        _metEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) =>
                MetEvent(bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_metEvents!);
      } // add METLevel stream
      else if (moviChar == MovisensBluetoothCharacteristics.metLevel) {
        _metLevelEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => MetLevelEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_metLevelEvents!);
      } // add movementAcceleration stream
      else if (moviChar ==
          MovisensBluetoothCharacteristics.movementAcceleration) {
        _movementAccelerationEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => MovementAccelerationEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_movementAccelerationEvents!);
      } // add steps stream
      else if (moviChar == MovisensBluetoothCharacteristics.steps) {
        _stepsEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => StepsEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_stepsEvents!);
      }
    }
    _events = Rx.merge(nonNullStreams);
  }

  @override
  String uuid = serviceToUuid[MovisensServiceTypes.physicalActivity]!;
}

/// A Movisens service containing Respiration data.
///
/// Included characteristics:
/// * [MovisensBluetoothCharacteristics.respiratoryMovement]
class RespirationService extends StreamingMovisensService {
  @override
  List<MovisensBluetoothCharacteristics> characteristics = [
    MovisensBluetoothCharacteristics.respiratoryMovement
  ];

  // TODO: Handle buffered values

  Stream<RespiratoryMovementEvent>? _respiratoryMovementEvents;

  /// A stream of [RespiratoryMovementEvent]s.
  Stream<RespiratoryMovementEvent>? get respiratoryMovementEvents =>
      _respiratoryMovementEvents;

  RespirationService({required BluetoothService service}) {
    _bluetoothService = service;
    List<Stream<MovisensEvent>> nonNullStreams = [];
    // For each characteristic that is supported in the service
    for (BluetoothCharacteristic char in _bluetoothService.characteristics) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];

      // add respiratory movement stream
      if (moviChar == MovisensBluetoothCharacteristics.respiratoryMovement) {
        _respiratoryMovementEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => RespiratoryMovementEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_respiratoryMovementEvents!);
      }
    }
    _events = Rx.merge(nonNullStreams);
  }

  @override
  String uuid = serviceToUuid[MovisensServiceTypes.respiration]!;
}

/// A Movisens service containing the Sensor Control interface.
///
/// Included characteristics:
/// * [MovisensBluetoothCharacteristics.commandResult]
/// * [MovisensBluetoothCharacteristics.currentTimeMs]
/// * [MovisensBluetoothCharacteristics.dataAvailable]
/// * [MovisensBluetoothCharacteristics.deleteData]
/// * [MovisensBluetoothCharacteristics.measurementEnabled]
/// * [MovisensBluetoothCharacteristics.measurementStartTime]
/// * [MovisensBluetoothCharacteristics.measurementStatus]
/// * [MovisensBluetoothCharacteristics.saveEnergy]
/// * [MovisensBluetoothCharacteristics.sendBufferedData]
/// * [MovisensBluetoothCharacteristics.startMeasurement]
/// * [MovisensBluetoothCharacteristics.status]
/// * [MovisensBluetoothCharacteristics.storageLevel]
/// * [MovisensBluetoothCharacteristics.timeZoneId]
/// * [MovisensBluetoothCharacteristics.timeZoneOffset]
class SensorControlService extends StreamingMovisensService {
  @override
  List<MovisensBluetoothCharacteristics> characteristics = [
    MovisensBluetoothCharacteristics.commandResult,
    MovisensBluetoothCharacteristics.currentTimeMs,
    MovisensBluetoothCharacteristics.dataAvailable,
    MovisensBluetoothCharacteristics.deleteData,
    MovisensBluetoothCharacteristics.measurementEnabled,
    MovisensBluetoothCharacteristics.measurementStartTime,
    MovisensBluetoothCharacteristics.measurementStatus,
    MovisensBluetoothCharacteristics.saveEnergy,
    MovisensBluetoothCharacteristics.sendBufferedData,
    MovisensBluetoothCharacteristics.startMeasurement,
    MovisensBluetoothCharacteristics.status,
    MovisensBluetoothCharacteristics.storageLevel,
    MovisensBluetoothCharacteristics.timeZoneId,
    MovisensBluetoothCharacteristics.timeZoneOffset
    // MovisensBluetoothCharacteristics.activatedBufferedCharacteristics, TODO: Missing documentation from movisens - request it
    // MovisensBluetoothCharacteristics.customData, TODO: Possibly support in future version
  ]; // TODO: Handle buffered values

  Stream<CommandResultEvent>? _commandResultEvents;
  Stream<DataAvailableEvent>? _dataAvailableEvents;
  Stream<MeasurementEnabledEvent>? _measurementEnabledEvents;
  Stream<MeasurementStatusEvent>? _measurementStatusEvents;
  Stream<StorageLevelEvent>? _storageLevelEvents;

  /// A stream of [CommandResultEvent]s.
  Stream<CommandResultEvent>? get commandResultEvents => _commandResultEvents;

  /// A stream of [DataAvailableEvent]s.
  Stream<DataAvailableEvent>? get dataAvailableEvents => _dataAvailableEvents;

  /// A stream of [MeasurementEnabledEvent]s.
  Stream<MeasurementEnabledEvent>? get measurementEnabledEvents =>
      _measurementEnabledEvents;

  /// A stream of [MeasurementStatusEvent]s.
  Stream<MeasurementStatusEvent>? get measurementStatusEvents =>
      _measurementStatusEvents;

  /// A stream of [StorageLevelEvent]s.
  Stream<StorageLevelEvent>? get storageLevelEvents => _storageLevelEvents;

  BluetoothCharacteristic? _currentTimeMs;
  BluetoothCharacteristic? _dataAvailable;
  BluetoothCharacteristic? _deleteData;
  BluetoothCharacteristic? _measurementEnabled;
  BluetoothCharacteristic? _measurementStartTime;
  BluetoothCharacteristic? _measurementStatus;
  BluetoothCharacteristic? _saveEnergy;
  BluetoothCharacteristic? _sendBufferedData;
  BluetoothCharacteristic? _startMeasurement;
  BluetoothCharacteristic? _status;
  BluetoothCharacteristic? _storageLevel;
  BluetoothCharacteristic? _timeZoneId;
  BluetoothCharacteristic? _timeZoneOffset;
  // BluetoothCharacteristic? _activatedBufferedCharacteristics; TODO: Missing documentation from movisens - request it
  // BluetoothCharacteristic? _customData; TODO: Possibly support in future version

  SensorControlService({required BluetoothService service}) {
    _bluetoothService = service;
    List<Stream<MovisensEvent>> nonNullStreams = [];
    // For each characteristic that is supported in the service
    for (BluetoothCharacteristic char in _bluetoothService.characteristics) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];

      switch (moviChar) {
        // TODO: Future version - Use with buffered values
        // case MovisensBluetoothCharacteristics.activatedBufferedCharacteristics:
        //   _activatedBufferedCharacteristics = char;
        //   break;
        case MovisensBluetoothCharacteristics.commandResult:
          _commandResultEvents = char.value
              .skipWhile((element) => element.isEmpty)
              .map((event) => CommandResultEvent(
                  bytes: event, deviceId: _bluetoothService.deviceId.id))
              .asBroadcastStream();
          nonNullStreams.add(_commandResultEvents!);
          break;
        case MovisensBluetoothCharacteristics.currentTimeMs:
          _currentTimeMs = char;
          break;
        case MovisensBluetoothCharacteristics.dataAvailable:
          _dataAvailable = char;
          _dataAvailableEvents = char.value
              .skipWhile((element) => element.isEmpty)
              .map((event) => DataAvailableEvent(
                  bytes: event, deviceId: _bluetoothService.deviceId.id))
              .asBroadcastStream();
          nonNullStreams.add(_dataAvailableEvents!);
          break;
        case MovisensBluetoothCharacteristics.deleteData:
          _deleteData = char;
          break;
        case MovisensBluetoothCharacteristics.measurementEnabled:
          _measurementEnabledEvents = char.value
              .skipWhile((element) => element.isEmpty)
              .map((event) => MeasurementEnabledEvent(
                  bytes: event, deviceId: _bluetoothService.deviceId.id))
              .asBroadcastStream();
          nonNullStreams.add(_measurementEnabledEvents!);
          _measurementEnabled = char;
          break;
        case MovisensBluetoothCharacteristics.measurementStartTime:
          _measurementStartTime = char;
          break;
        case MovisensBluetoothCharacteristics.measurementStatus:
          _measurementStatus = char;
          _measurementStatusEvents = char.value
              .skipWhile((element) => element.isEmpty)
              .map((event) => MeasurementStatusEvent(
                  bytes: event, deviceId: _bluetoothService.deviceId.id))
              .asBroadcastStream();
          nonNullStreams.add(_measurementStatusEvents!);
          break;
        case MovisensBluetoothCharacteristics.saveEnergy:
          _saveEnergy = char;
          break;
        case MovisensBluetoothCharacteristics.sendBufferedData:
          _sendBufferedData = char;
          break;
        case MovisensBluetoothCharacteristics.startMeasurement:
          _startMeasurement = char;
          break;
        case MovisensBluetoothCharacteristics.status:
          _status = char;
          break;
        case MovisensBluetoothCharacteristics.storageLevel:
          _storageLevel = char;
          _storageLevelEvents = char.value
              .skipWhile((element) => element.isEmpty)
              .map((event) => StorageLevelEvent(
                  bytes: event, deviceId: _bluetoothService.deviceId.id))
              .asBroadcastStream();
          nonNullStreams.add(_storageLevelEvents!);
          break;
        case MovisensBluetoothCharacteristics.timeZoneId:
          _timeZoneId = char;
          break;
        case MovisensBluetoothCharacteristics.timeZoneOffset:
          _timeZoneOffset = char;
          break;
        default:
          _log.warning(
              "Characteristics uuid $charUuid is not recognized on movisens device [${char.deviceId.id}]");
          break;
      }
    }
    _events = Rx.merge(nonNullStreams);
  }

  /// Get the current time in milliseconds since epoch.
  ///
  /// Time is in UTC.
  Future<int?> getCurrentTimeMs() async {
    if (_currentTimeMs == null) {
      _log.warning("Current time ms characteristic not found on device");
      return null;
    }
    List<int> bytes = await _currentTimeMs!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int currentTimeMs = byteData.getInt64(0, Endian.little);
    return currentTimeMs;
  }

  /// Set the current time in milliseconds since epoch.
  ///
  /// Time is in UTC.
  Future<void> setCurrentTimeMs(int currentTimeMs) async {
    if (_currentTimeMs == null) {
      _log.warning("Current time MS characteristic not found on device");
      return;
    }
    ByteData data = ByteData(4);
    data.setInt64(0, currentTimeMs, Endian.little);
    Uint8List byteList = data.buffer.asUint8List();
    await _currentTimeMs!.write(byteList);
  }

  /// Check if the device has data stored.
  ///
  /// `true` if data is available on the device, otherwise `false`.
  Future<bool?> getDataAvailable() async {
    if (_dataAvailable == null) {
      _log.warning("Data Available characteristic not found on device");
      return null;
    }
    List<int> bytes = await _dataAvailable!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    bool dataAvailable = byteData.getUint8(0) == 1;
    return dataAvailable;
  }

  /// Set delete data.
  /// If set to True, then it deletes all data on device.
  ///
  /// **Only works if a measurement is not running.**
  ///
  /// The [commandResultEvents] streams the result of the command.
  Future<void> setDeleteData(bool deleteData) async {
    if (_deleteData == null) {
      _log.warning("Delete Data characteristic not found on device");
      return;
    }
    ByteData data = ByteData(1);
    data.setUint8(0, deleteData ? 1 : 0);
    Uint8List byteList = data.buffer.asUint8List();
    await _deleteData!.write(byteList);
  }

  /// Checks if a measurement is running on the device.
  ///
  /// `true` if a measurement is running otherwise `false`.
  Future<bool?> getMeasurementEnabled() async {
    if (_measurementEnabled == null) {
      _log.warning("Measurement Enabled characteristic not found on device");
      return null;
    }
    List<int> bytes = await _measurementEnabled!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    bool measurementEnabled = byteData.getUint8(0) == 1;
    return measurementEnabled;
  }

  /// Enable or disable a measurement on the device.
  ///
  /// If set to `true` (and no measurement is running), then a measurement is started.
  /// If set to `false` (and a measurement **is** running), then a measurement is stopped.
  ///
  /// If a measurement is stopped and started, it will be split into "parts" once saved with "Sensor Manager".
  ///
  /// The [commandResultEvents] streams the result of the command.
  Future<void> setMeasurementEnabled(bool measurementEnabled) async {
    if (_measurementEnabled == null) {
      _log.warning("Measurement Enabled characteristic not found on device");
      return;
    }
    ByteData data = ByteData(1);
    data.setUint8(0, measurementEnabled ? 1 : 0);
    Uint8List byteList = data.buffer.asUint8List();
    await _measurementEnabled!.write(byteList);
  }

  /// Get the measurement start time. Measured in milliseconds since epoch.
  Future<int?> getMeasurementStartTime() async {
    if (_measurementStartTime == null) {
      _log.warning("Measurement Start Time characteristic not found on device");
      return null;
    }
    List<int> bytes = await _measurementStartTime!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int measurementStartTime = byteData.getUint64(0);
    return measurementStartTime;
  }

  /// Returns the status of the measurement as an enum [MeasurementStatus].
  Future<MeasurementStatus?> getMeasurementStatus() async {
    if (_measurementStatus == null) {
      _log.warning("Measurement Status characteristic not found on device");
      return null;
    }
    List<int> bytes = await _measurementStatus!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int measurementStatus = byteData.getUint8(0);
    late MeasurementStatus mStatus;
    switch (measurementStatus) {
      case 1:
        mStatus = MeasurementStatus.stoppedDurationReached;
        break;
      case 2:
        mStatus = MeasurementStatus.stoppedUserUsb;
        break;
      case 3:
        mStatus = MeasurementStatus.stoppedBatteryEmpty;
        break;
      case 4:
        mStatus = MeasurementStatus.stoppedError;
        break;
      case 5:
        mStatus = MeasurementStatus.stoppedUserBle;
        break;
      case 6:
        mStatus = MeasurementStatus.stoppedStorageFull;
        break;
      case 7:
        mStatus = MeasurementStatus.pausedBatteryLow;
        break;
      case 8:
        mStatus = MeasurementStatus.stoppedEmpty;
        break;
      case 9:
        mStatus = MeasurementStatus.measuring;
        break;
    }
    return mStatus;
  }

  /// Must be set to 1 to put the connection into energy saving mode (Recommended after configuration is done).
  /// As soon as a new connection is established the save energy mode must be enabled again.
  Future<void> setSaveEnergy(bool saveEnergy) async {
    if (_saveEnergy == null) {
      _log.warning("Save Energy characteristic not found on device");
      return;
    }
    ByteData data = ByteData(1);
    data.setUint8(0, saveEnergy ? 1 : 0);
    Uint8List byteList = data.buffer.asUint8List();
    await _saveEnergy!.write(byteList);
  }

  /// If set to True and buffered data is available the sensor sends out the data.
  Future<void> setSendBufferedData(bool sendBufferedData) async {
    if (_sendBufferedData == null) {
      _log.warning("Send Buffered Data characteristic not found on device");
      return;
    }
    ByteData data = ByteData(1);
    data.setUint8(0, sendBufferedData ? 1 : 0);
    Uint8List byteList = data.buffer.asUint8List();
    await _sendBufferedData!.write(byteList);
  }

  /// Start a measurement and with a given duration in seconds.
  ///
  /// If a measurement is stopped and started, it will be split into "parts" once saved with "Sensor Manager".
  ///
  /// The [commandResultEvents] streams the result of the command.
  Future<void> setStartMeasurement(int duration) async {
    if (_startMeasurement == null) {
      _log.warning("Start Measurement characteristic not found on device");
      return;
    }
    ByteData data = ByteData(4);
    data.setUint32(0, duration, Endian.little);
    Uint8List byteList = data.buffer.asUint8List();
    await _startMeasurement!.write(byteList);
  }

  /// <mark>Not documented by Movisens. Null-Characteristic on some devices.</mark>
  ///
  /// Get status of the sensor.
  // TODO: Request more documentation from Movisens.
  Future<int?> getStatus() async {
    if (_status == null) {
      _log.warning("Status characteristic not found on device");
      return null;
    }
    List<int> bytes = await _status!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int status = byteData.getUint8(0);
    return status;
  }

  /// Get storage level of device in percentage of used space.
  ///
  /// <mark>ECG Move 4 did not seem to work with this</mark>
  Future<int?> getStorageLevel() async {
    if (_storageLevel == null) {
      _log.warning("Storage Level characteristic not found on device");
      return null;
    }
    List<int> bytes = await _storageLevel!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int status = byteData.getUint8(0);
    return status;
  }

  // TODO: Missing documentation from Movisens - request it
  /// Get the time zone ID of the time zone.
  Future<int?> getTimeZoneId() async {
    if (_timeZoneId == null) {
      _log.warning("Time Zone Id characteristic not found on device");
      return null;
    }
    List<int> bytes = await _timeZoneId!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int timeZoneId = byteData.getInt64(0, Endian.little);
    return timeZoneId;
  }

  // TODO: Missing documentation from Movisens - request it
  /// Set the time zone ID of the time zone.
  Future<void> setTimeZoneId(int timeZoneId) async {
    if (_timeZoneId == null) {
      _log.warning("Time Zone Id characteristic not found on device");
      return;
    }
    ByteData data = ByteData(4);
    data.setInt64(0, timeZoneId, Endian.little);
    Uint8List byteList = data.buffer.asUint8List();
    await _timeZoneId!.write(byteList);
  }

  /// Time zone offset in seconds from UTC in which the sensor was started.
  Future<int?> getTimeZoneOffset() async {
    if (_timeZoneOffset == null) {
      _log.warning("Time Zone Offset characteristic not found on device");
      return null;
    }
    List<int> bytes = await _timeZoneOffset!.read();
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int timeZoneOffset = byteData.getInt32(0, Endian.little);
    return timeZoneOffset;
  }

  /// Time zone offset in seconds from UTC in which the sensor will be started.
  Future<void> setTimeZoneOffset(int timeZoneOffset) async {
    if (_timeZoneOffset == null) {
      _log.warning("Time Zone Offset characteristic not found on device");
      return;
    }
    ByteData data = ByteData(4);
    data.setInt32(0, timeZoneOffset, Endian.little);
    Uint8List byteList = data.buffer.asUint8List();
    await _timeZoneOffset!.write(byteList);
  }

  @override
  String uuid = serviceToUuid[MovisensServiceTypes.sensorControl]!;
}

/// A Movisens service containing Skin Temperature data.
///
/// Included characteristics:
/// * [MovisensBluetoothCharacteristics.skinTemperature]
class SkinTemperatureService extends StreamingMovisensService {
  @override
  List<MovisensBluetoothCharacteristics> characteristics = [
    MovisensBluetoothCharacteristics.skinTemperature
  ];

  // TODO: Handle buffered values

  Stream<SkinTemperatureEvent>? _skinTemperatureEvents;
  Stream<SkinTemperatureEvent>? get skinTemperatureEvents =>
      _skinTemperatureEvents;

  SkinTemperatureService({required BluetoothService service}) {
    _bluetoothService = service;
    List<Stream<MovisensEvent>> nonNullStreams = [];
    // For each characteristic that is supported in the service
    for (BluetoothCharacteristic char in _bluetoothService.characteristics) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];

      // add Skin Temperature stream
      if (moviChar == MovisensBluetoothCharacteristics.skinTemperature) {
        _skinTemperatureEvents = char.value
            .skipWhile((element) => element.isEmpty)
            .map((event) => SkinTemperatureEvent(
                bytes: event, deviceId: _bluetoothService.deviceId.id))
            .asBroadcastStream();
        nonNullStreams.add(_skinTemperatureEvents!);
      }
    }
    _events = Rx.merge(nonNullStreams);
  }

  @override
  String uuid = serviceToUuid[MovisensServiceTypes.skinTemperature]!;
}

/// A Movisens service containing device information.
///
/// Included characteristics:
/// * [MovisensBluetoothCharacteristics.firmwareRevisionString]
/// * [MovisensBluetoothCharacteristics.manufacturerNameString]
/// * [MovisensBluetoothCharacteristics.modelNumberString]
/// * [MovisensBluetoothCharacteristics.serialNumberString]
class DeviceInformationService extends MovisensService {
  @override
  List<MovisensBluetoothCharacteristics> characteristics = [
    MovisensBluetoothCharacteristics.firmwareRevisionString,
    MovisensBluetoothCharacteristics.manufacturerNameString,
    MovisensBluetoothCharacteristics.modelNumberString,
    MovisensBluetoothCharacteristics.serialNumberString,
  ];

  BluetoothCharacteristic? _firmwareRevisionString;
  BluetoothCharacteristic? _manufacturerNameString;
  BluetoothCharacteristic? _modelNumberString;
  BluetoothCharacteristic? _serialNumberString;

  DeviceInformationService({required BluetoothService service}) {
    _bluetoothService = service;
    // For each characteristic that is supported in the service
    for (BluetoothCharacteristic char in _bluetoothService.characteristics) {
      String charUuid = char.uuid.toString();
      MovisensBluetoothCharacteristics? moviChar =
          characteristicUUIDToMovisensBluetoothCharacteristics[charUuid];

      switch (moviChar) {
        case MovisensBluetoothCharacteristics.firmwareRevisionString:
          _firmwareRevisionString = char;
          break;
        case MovisensBluetoothCharacteristics.manufacturerNameString:
          _manufacturerNameString = char;
          break;
        case MovisensBluetoothCharacteristics.modelNumberString:
          _modelNumberString = char;
          break;
        case MovisensBluetoothCharacteristics.serialNumberString:
          _serialNumberString = char;
          break;
        default:
          _log.warning(
              "Characteristics uuid $charUuid is not recognized on movisens device [${char.deviceId.id}]");
          break;
      }
    }
  }

  /// Get the firmware revision string of the device.
  Future<String?> getFirmwareRevisionString() async {
    if (_firmwareRevisionString == null) {
      _log.warning(
          "Firmware Revision String characteristic not found on device");
      return null;
    }
    List<int> bytes = await _firmwareRevisionString!.read();
    String firmwareRevisionString = String.fromCharCodes(bytes);
    return firmwareRevisionString.toString();
  }

  /// Get the manufacturer name string of the device.
  Future<String?> getManufacturerNameString() async {
    if (_manufacturerNameString == null) {
      _log.warning(
          "Manufacturer Name String characteristic not found on device");
      return null;
    }
    List<int> bytes = await _manufacturerNameString!.read();
    String manufacturerNameString = String.fromCharCodes(bytes);
    return manufacturerNameString.toString();
  }

  /// Get the model number string of the device.
  Future<String?> getModelNumberString() async {
    if (_modelNumberString == null) {
      _log.warning("Model Number String characteristic not found on device");
      return null;
    }
    List<int> bytes = await _modelNumberString!.read();
    String modelNumberString = String.fromCharCodes(bytes);
    return modelNumberString;
  }

  /// Get the serial number string of the device.
  Future<String?> getSerialNumberString() async {
    if (_serialNumberString == null) {
      _log.warning("Serial Number String characteristic not found on device");
      return null;
    }
    List<int> bytes = await _serialNumberString!.read();
    String serialNumberString = String.fromCharCodes(bytes);
    return serialNumberString.toString();
  }

  @override
  String uuid = serviceToUuid[MovisensServiceTypes.deviceInformation]!;
}
