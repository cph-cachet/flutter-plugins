part of movisens_flutter;

/// A basic Movisens Event.
abstract class MovisensEvent {
  /// Get the UUID of this [type].
  String get uuid => charToUuid[type]!;
  late DateTime _time;

  /// The type of characteristic which emitted this event
  /// as enum [MovisensBluetoothCharacteristics].
  abstract MovisensBluetoothCharacteristics type;
  final String _deviceId;

  /// Constructing an event requires an ID of the device.
  MovisensEvent(this._deviceId) {
    _time = DateTime.now();
  }

  /// The time this event happened.
  DateTime get time => _time;

  /// The ID of the device which emitted this event.
  /// Typically uses a MAC address format.
  String get deviceId => _deviceId;

  @override
  String toString() {
    return "Device ID: $deviceId, Type: ${enumToReadableString(type)}, Time: $time";
  }
}

/// A event of type [MovisensBluetoothCharacteristics.light].
///
/// Contains information about the ambient light.
/// [clear] and [ir] values for ambient light
/// TODO: Movisens missing documentation - request it
class LightEvent extends MovisensEvent {
  late int _clear;
  late int _ir;

  LightEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _clear = byteData.getUint32(0, Endian.little);
    _ir = byteData.getUint32(4, Endian.little);
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.light;

  int get clear => _clear;
  int get ir => _ir;

  @override
  String toString() {
    return '${super.toString()}, Clear: $clear, ir: $ir';
  }
}

/// A event of type [MovisensBluetoothCharacteristics.lightRGB].
///
/// Contains information about the ambient light.
/// [red], [green] and [blue] values for ambient light
/// TODO: Movisens missing documentation - request it
class LightRGBEvent extends MovisensEvent {
  late int _red;
  late int _green;
  late int _blue;

  LightRGBEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _red = byteData.getUint32(0, Endian.little);
    _green = byteData.getUint32(4, Endian.little);
    _blue = byteData.getUint32(8, Endian.little);
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.lightRGB;

  int get red => _red;
  int get green => _green;
  int get blue => _blue;

  @override
  String toString() {
    return '${super.toString()}, Red: $red, Green: $green, Blue: $blue';
  }
}

/// A event of type [MovisensBluetoothCharacteristics.sensorTemperature].
///
/// Temperature measured inside the sensor housing
/// [sensorTemperature] is measured in Celsius with accuracy of 0.1 degrees
class SensorTemperatureEvent extends MovisensEvent {
  final double _lsb = 0.1;
  late double _sensorTemperature;

  SensorTemperatureEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _sensorTemperature = byteData.getUint16(0, Endian.little) * _lsb;
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.sensorTemperature;

  double get sensorTemperature => _sensorTemperature;

  @override
  String toString() {
    return '${super.toString()}, Sensor Temperature: $sensorTemperature';
  }
}

/// A event of type [MovisensBluetoothCharacteristics.edaSclMean].
///
/// The Mean Skin Conductance Level (SCL) value in micro Siemens.
///
/// Calculated from Electrodermal Activity (EDA) data.
///
/// Read more at: https://docs.movisens.com/Algorithms/electrodermal_activity/#mean-skin-conductance-level-edasclmean
class EdaSclMeanEvent extends MovisensEvent {
  final double _lsb = 0.0030518509475997192;
  late double _edaSclMean;

  EdaSclMeanEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _edaSclMean = byteData.getUint16(0, Endian.little) * _lsb;
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.edaSclMean;

  /// The Mean Skin Conductance Level (SCL) value in micro Siemens.
  double get edaSclMean => _edaSclMean;

  @override
  String toString() {
    return '${super.toString()}, EdaSclMean: $edaSclMean';
  }
}

class HrMeanEvent extends MovisensEvent {
  late int _hrMean;

  HrMeanEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _hrMean = byteData.getInt16(0, Endian.little);
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.hrMean;

  /// Heart rate mean in beats per minute.
  int get hrMean => _hrMean;

  @override
  String toString() {
    return '${super.toString()}, HrMean: $hrMean';
  }
}

class HrvIsValidEvent extends MovisensEvent {
  late bool _hrvIsValid;

  HrvIsValidEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _hrvIsValid = byteData.getInt8(0) == 1;
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.hrvIsValid;

  /// Indicates if HRV measurements is valid
  bool get hrvIsValid => _hrvIsValid;

  @override
  String toString() {
    return '${super.toString()}, HrvIsValid: $hrvIsValid';
  }
}

class RmssdEvent extends MovisensEvent {
  late int _rmssd;

  RmssdEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _rmssd = byteData.getInt16(0, Endian.little);
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.rmssd;

  /// The Root Mean Square of Successive Differences (RMSSD) of heart beat intervals.
  ///
  /// Unit is milliseconds.
  int get rmssd => _rmssd;

  @override
  String toString() {
    return '${super.toString()}, Rmssd: $rmssd';
  }
}

// TODO: What does the marker value mean?
class TapMarkerEvent extends MovisensEvent {
  late int _tapMarkerValue;

  TapMarkerEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _tapMarkerValue = byteData.getUint32(0, Endian.little);
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.tapMarker;

  int get tapMarkerValue => _tapMarkerValue;

  @override
  String toString() {
    return '${super.toString()}, TapMarkerValue: $tapMarkerValue';
  }
}

class ChargingEvent extends MovisensEvent {
  late bool _charging;

  ChargingEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _charging = byteData.getInt8(0) == 1;
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.charging;

  /// True if the sensor is charging
  bool get charging => _charging;

  @override
  String toString() {
    return '${super.toString()}, Charging: $charging';
  }
}

/// Body position enum
enum BodyPosition {
  unknown,
  lyingSupine,
  lyingLeft,
  lyingProne,
  lyingRight,
  upright,
  sittingUpright,
  standing,
  notWorn
}

class BodyPositionEvent extends MovisensEvent {
  late BodyPosition _bodyPosition;

  BodyPositionEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int bodyPos = byteData.getUint8(0);
    switch (bodyPos) {
      case 0:
        _bodyPosition = BodyPosition.unknown;
        break;
      case 1:
        _bodyPosition = BodyPosition.lyingSupine;
        break;
      case 2:
        _bodyPosition = BodyPosition.lyingLeft;
        break;
      case 3:
        _bodyPosition = BodyPosition.lyingProne;
        break;
      case 4:
        _bodyPosition = BodyPosition.lyingRight;
        break;
      case 5:
        _bodyPosition = BodyPosition.upright;
        break;
      case 6:
        _bodyPosition = BodyPosition.sittingUpright;
        break;
      case 7:
        _bodyPosition = BodyPosition.standing;
        break;
      case 99:
        _bodyPosition = BodyPosition.notWorn;
        break;
    }
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.bodyPosition;

  /// The [BodyPosition] value the user is in.
  BodyPosition get bodyPosition => _bodyPosition;

  @override
  String toString() {
    return '${super.toString()}, BodyPosition: ${enumToReadableString(bodyPosition)}';
  }
}

class InclinationEvent extends MovisensEvent {
  late int _x;
  late int _y;
  late int _z;

  InclinationEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _x = byteData.getUint8(0);
    _y = byteData.getUint8(1);
    _z = byteData.getUint8(2);
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.inclination;

  /// Inclination of the sensor in degrees on the X axis
  int get x => _x;

  /// Inclination of the sensor in degrees on the Y axis
  int get y => _y;

  /// Inclination of the sensor in degrees on the Z axis
  int get z => _z;

  @override
  String toString() {
    return '${super.toString()}, x: $x, y: $y, z: $z';
  }
}

class MetEvent extends MovisensEvent {
  late int _met;

  MetEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _met = byteData.getUint16(0, Endian.little);
  }

  @override
  MovisensBluetoothCharacteristics type = MovisensBluetoothCharacteristics.met;

  /// Current Metabolic Equivalent of Task value
  ///
  /// Requires characteristics age, gender, weight, height and sensor_location to be set in user_data service!
  int get met => _met;

  @override
  String toString() {
    return '${super.toString()}, Met: $met';
  }
}

class MetLevelEvent extends MovisensEvent {
  late int _sedentary;
  late int _light;
  late int _moderate;
  late int _vigorous;

  MetLevelEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _sedentary = byteData.getUint8(0);
    _light = byteData.getUint8(1);
    _moderate = byteData.getUint8(2);
    _vigorous = byteData.getUint8(3);
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.metLevel;

  /// Number of seconds the users MET value was at the MET level sedentary.
  /// Measured in seconds.
  ///
  /// Needs characteristics age, gender, weight, height and sensor_location to be set in user_data service!
  int get sedentary => _sedentary;

  /// Number of seconds the users MET value was at the MET level light.
  /// Measured in seconds.
  ///
  /// Needs characteristics age, gender, weight, height and sensor_location to be set in user_data service!
  int get light => _light;

  /// Number of seconds the users MET value was at the MET level moderate.
  /// Measured in seconds.
  ///
  /// Needs characteristics age, gender, weight, height and sensor_location to be set in user_data service!
  int get moderate => _moderate;

  /// Number of seconds the users MET value was at the MET level vigorous.
  /// Measured in seconds.
  ///
  /// Needs characteristics age, gender, weight, height and sensor_location to be set in user_data service!
  int get vigorous => _vigorous;

  @override
  String toString() {
    return '${super.toString()}, Sedentary: $sedentary, Light: $light, Moderate: $moderate, Vigorous: $vigorous';
  }
}

class MovementAccelerationEvent extends MovisensEvent {
  final double _lsb = 0.00390625;

  late double _movementAcceleration;

  MovementAccelerationEvent(
      {required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _movementAcceleration = byteData.getInt16(0, Endian.little) * _lsb;
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.movementAcceleration;

  /// Movement acceleration value.
  /// Measured in grams (g)
  double get movementAcceleration => _movementAcceleration;

  @override
  String toString() {
    return '${super.toString()}, MovementAcceleration: $movementAcceleration';
  }
}

class StepsEvent extends MovisensEvent {
  late int _steps;

  StepsEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _steps = byteData.getUint16(0, Endian.little);
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.steps;

  /// Number of Steps taken by the user
  int get steps => _steps;

  @override
  String toString() {
    return '${super.toString()}, Steps: $steps';
  }
}

// TODO: Understand the return value of the respiratory movement - awaiting movisens response
class RespiratoryMovementEvent extends MovisensEvent {
  late int _values;

  RespiratoryMovementEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _values = byteData.getInt16(0, Endian.little);
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.respiratoryMovement;

  int get values => _values;

  @override
  String toString() {
    return '${super.toString()}, Values: $values';
  }
}

/// Enum for Command result
enum CommandResult {
  ok,
  notStartedBatteryLow,
  notStartedDataAvailable,
  notStartedProbandInfoMissing,
  notDeletedMeasurementOn,
  notStartedMeasurementOn,
  notStoppedMeasurementOff
}

class CommandResultEvent extends MovisensEvent {
  late CommandResult _commandResult;

  CommandResultEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int comRes = byteData.getUint8(0);
    switch (comRes) {
      case 0:
        _commandResult = CommandResult.ok;
        break;
      case 1:
        _commandResult = CommandResult.notStartedBatteryLow;
        break;
      case 2:
        _commandResult = CommandResult.notStartedDataAvailable;
        break;
      case 3:
        _commandResult = CommandResult.notStartedProbandInfoMissing;
        break;
      case 4:
        _commandResult = CommandResult.notDeletedMeasurementOn;
        break;
      case 5:
        _commandResult = CommandResult.notStartedMeasurementOn;
        break;
      case 6:
        _commandResult = CommandResult.notStoppedMeasurementOff;
        break;
    }
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.commandResult;

  /// The result of the last command.
  CommandResult get commandResult => _commandResult;

  @override
  String toString() {
    return '${super.toString()}, Command Result: ${enumToReadableString(commandResult)}';
  }
}

class DataAvailableEvent extends MovisensEvent {
  late bool _dataAvailable;

  DataAvailableEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _dataAvailable = byteData.getInt8(0) == 1;
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.dataAvailable;

  // True if measurement data is available on the sensor.
  bool get dataAvailable => _dataAvailable;

  @override
  String toString() {
    return '${super.toString()}, Data Available: $dataAvailable';
  }
}

class MeasurementEnabledEvent extends MovisensEvent {
  late bool _measurementEnabled;

  MeasurementEnabledEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _measurementEnabled = byteData.getInt8(0) == 1;
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.measurementEnabled;

  /// True if the measurement is enabled.
  bool get measurementEnabled => _measurementEnabled;

  @override
  String toString() {
    return '${super.toString()}, Measurement Enabled: $measurementEnabled';
  }
}

/// Status of the measurement
enum MeasurementStatus {
  stoppedDurationReached,
  stoppedUserUsb,
  stoppedBatteryEmpty,
  stoppedError,
  stoppedUserBle,
  stoppedStorageFull,
  pausedBatteryLow,
  stoppedEmpty,
  measuring
}

class MeasurementStatusEvent extends MovisensEvent {
  late MeasurementStatus _measurementStatus;

  MeasurementStatusEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    int measStat = byteData.getUint8(0);
    switch (measStat) {
      case 1:
        _measurementStatus = MeasurementStatus.stoppedDurationReached;
        break;
      case 2:
        _measurementStatus = MeasurementStatus.stoppedUserUsb;
        break;
      case 3:
        _measurementStatus = MeasurementStatus.stoppedBatteryEmpty;
        break;
      case 4:
        _measurementStatus = MeasurementStatus.stoppedError;
        break;
      case 5:
        _measurementStatus = MeasurementStatus.stoppedUserBle;
        break;
      case 6:
        _measurementStatus = MeasurementStatus.stoppedStorageFull;
        break;
      case 7:
        _measurementStatus = MeasurementStatus.pausedBatteryLow;
        break;
      case 8:
        _measurementStatus = MeasurementStatus.stoppedEmpty;
        break;
      case 9:
        _measurementStatus = MeasurementStatus.measuring;
        break;
    }
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.measurementStatus;

  /// Status of the measurement
  MeasurementStatus get measurementStatus => _measurementStatus;

  @override
  String toString() {
    return '${super.toString()}, Measurement Status: ${enumToReadableString(measurementStatus)}';
  }
}

class StorageLevelEvent extends MovisensEvent {
  late int _storageLevel;

  StorageLevelEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _storageLevel = byteData.getUint8(0);
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.storageLevel;

  /// The current level of storage used in percentage.
  int get storageLevel => _storageLevel;

  @override
  String toString() {
    return '${super.toString()}, Storage Level: $storageLevel';
  }
}

class SkinTemperatureEvent extends MovisensEvent {
  final double _lsb = 0.01;
  late double _skinTemperature;

  SkinTemperatureEvent({required List<int> bytes, required String deviceId})
      : super(deviceId) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    _skinTemperature = byteData.getInt16(0, Endian.little) * _lsb;
  }

  @override
  MovisensBluetoothCharacteristics type =
      MovisensBluetoothCharacteristics.skinTemperature;

  /// Temperature of the skin.
  /// Measured in Celcius (C)
  double get skinTemperature => _skinTemperature;

  @override
  String toString() {
    return '${super.toString()}, Skin Temperature: $skinTemperature';
  }
}
