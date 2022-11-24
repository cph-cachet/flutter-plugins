part of movisens_flutter;

enum MovisensBluetoothCharacteristics {
  light,
  lightBuffered,
  lightRGB,
  lightRGBBuffered,
  lightRGBWaiting,
  lightWaiting,
  sensorTemperature,
  sensorTemperatureBuffered,
  sensorTemperatureWaiting,
  edaSclMean,
  edaSclMeanBuffered,
  edaSclMeanWaiting,
  hrMean,
  hrMeanBuffered,
  hrMeanWaiting,
  hrvIsValid,
  hrvIsValidBuffered,
  hrvIsValidWaiting,
  rmssd,
  rmssdBuffered,
  rmssdWaiting,
  tapMarker,
  batteryLevelBuffered,
  batteryLevelWaiting,
  charging,
  chargingBuffered,
  chargingWaiting,
  ageFloat,
  sensorLocation,
  bodyPosition,
  bodyPositionBuffered,
  bodyPositionWaiting,
  inclination,
  inclinationBuffered,
  inclinationWaiting,
  met,
  metBuffered,
  metLevel,
  metLevelBuffered,
  metLevelWaiting,
  metWaiting,
  movementAcceleration,
  movementAccelerationBuffered,
  movementAccelerationWaiting,
  steps,
  stepsBuffered,
  stepsWaiting,
  respiratoryMovement,
  activatedBufferedCharacteristics,
  commandResult,
  currentTimeMs,
  customData,
  dataAvailable,
  deleteData,
  measurementEnabled,
  measurementStartTime,
  measurementStatus,
  saveEnergy,
  sendBufferedData,
  startMeasurement,
  status,
  storageLevel,
  timeZoneId,
  timeZoneOffset,
  skinTemperature,
  skinTemperature1sBuffered,
  skinTemperatureBuffered,
  skinTemperatureWaiting
}

// abstract class MovisensCharacteristic {
//   abstract String uuid;
//   late BluetoothCharacteristic _bluetoothCharacteristic;
//   MovisensBluetoothCharacteristics get name =>
//       characteristicUUIDToMovisensBluetoothCharacteristics[uuid]!;
//   // int bytesToValue(List<int> bytes);
//   MovisensEvent _transform(List<int> bytes);
// }

// abstract class StreamingMovisensCharacteristic extends MovisensCharacteristic {
//   // final StreamController<MovisensEvent> _streamController = StreamController();

//   late Stream<MovisensEvent> _events;
//   // Stream<MovisensEvent> get events => _bluetoothCharacteristic.value.

//   StreamingMovisensCharacteristic(
//       {required BluetoothCharacteristic characteristic}) {
//     // _streamController.sink.
//     _events = characteristic.value.map((event) => _transform(event));
//     _bluetoothCharacteristic = characteristic;
//     // _bluetoothCharacteristic.value.listen((event) {
//     //   _characteristic.uuid.toString
//     //   addEventToStream(event);
//     // });
//   }
// }

// class LightCharacteristic extends StreamingMovisensCharacteristic {
//   @override
//   String uuid = charToUuid[MovisensBluetoothCharacteristics.light]!;

//   LightCharacteristic({required BluetoothCharacteristic characteristic})
//       : super(characteristic: characteristic);

//   @override
//   LightEvent _transform(List<int> bytes) => LightEvent(bytes: bytes);
// }

// class LightRGBCharacteristic extends StreamingMovisensCharacteristic {
//   @override
//   String uuid = charToUuid[MovisensBluetoothCharacteristics.lightRGB]!;

//   LightRGBCharacteristic({required BluetoothCharacteristic characteristic})
//       : super(characteristic: characteristic);

//   @override
//   LightRGBEvent _transform(List<int> bytes) => LightEvent(bytes: bytes);
// }

// class LightCharacteristic extends StreamingMovisensCharacteristic {
//   @override
//   String uuid = charToUuid[MovisensBluetoothCharacteristics.light]!;

//   LightCharacteristic({required BluetoothCharacteristic characteristic})
//       : super(characteristic: characteristic);

//   @override
//   LightEvent _transform(List<int> bytes) => LightEvent(bytes: bytes);
// }

// class LightCharacteristic extends StreamingMovisensCharacteristic {
//   @override
//   String uuid = charToUuid[MovisensBluetoothCharacteristics.light]!;

//   LightCharacteristic({required BluetoothCharacteristic characteristic})
//       : super(characteristic: characteristic);

//   @override
//   LightEvent _transform(List<int> bytes) => LightEvent(bytes: bytes);
// }

// class LightCharacteristic extends StreamingMovisensCharacteristic {
//   @override
//   String uuid = charToUuid[MovisensBluetoothCharacteristics.light]!;

//   LightCharacteristic({required BluetoothCharacteristic characteristic})
//       : super(characteristic: characteristic);

//   @override
//   LightEvent _transform(List<int> bytes) => LightEvent(bytes: bytes);
// }

// class LightCharacteristic extends StreamingMovisensCharacteristic {
//   @override
//   String uuid = charToUuid[MovisensBluetoothCharacteristics.light]!;

//   LightCharacteristic({required BluetoothCharacteristic characteristic})
//       : super(characteristic: characteristic);

//   @override
//   LightEvent _transform(List<int> bytes) => LightEvent(bytes: bytes);
// }

// class LightCharacteristic extends StreamingMovisensCharacteristic {
//   @override
//   String uuid = charToUuid[MovisensBluetoothCharacteristics.light]!;

//   LightCharacteristic({required BluetoothCharacteristic characteristic})
//       : super(characteristic: characteristic);

//   @override
//   LightEvent _transform(List<int> bytes) => LightEvent(bytes: bytes);
// }

// class LightCharacteristic extends StreamingMovisensCharacteristic {
//   @override
//   String uuid = charToUuid[MovisensBluetoothCharacteristics.light]!;

//   LightCharacteristic({required BluetoothCharacteristic characteristic})
//       : super(characteristic: characteristic);

//   @override
//   LightEvent _transform(List<int> bytes) => LightEvent(bytes: bytes);
// }
