/*
 * Copyright 2022 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
part of movisens_flutter;

/// Map for Characteristics UUID and the corresponding [MovisensBluetoothCharacteristics] enum
Map<String, MovisensBluetoothCharacteristics>
    characteristicUUIDToMovisensBluetoothCharacteristics = {
  "375bf82c-41e8-4ca1-9b95-f8634b1ba2f8":
      MovisensBluetoothCharacteristics.light,
  "7e5dd77b-67b7-42dd-be7a-822373391b2f":
      MovisensBluetoothCharacteristics.lightBuffered,
  "db32d0ca-fda0-4298-9d2f-1b109eb95a2f":
      MovisensBluetoothCharacteristics.lightRGB,
  "2c4abbf8-8da6-4e47-afcd-18034d67c5ee":
      MovisensBluetoothCharacteristics.lightRGBBuffered,
  "c758f5a6-516d-4125-b8de-ae3ebcabeabc":
      MovisensBluetoothCharacteristics.lightRGBWaiting,
  "d166790b-9531-44fd-8314-14f303280de1":
      MovisensBluetoothCharacteristics.lightWaiting,
  "2c007893-37a4-473d-8c07-09c41324eea5":
      MovisensBluetoothCharacteristics.sensorTemperature,
  "869c06de-f52a-4a90-9a3a-ca5fd35d6707":
      MovisensBluetoothCharacteristics.sensorTemperatureBuffered,
  "433a8af8-9839-4057-94aa-ef02fa0af106":
      MovisensBluetoothCharacteristics.sensorTemperatureWaiting,
  "a884dc4b-62d6-44ee-bcbf-d0f725d95213":
      MovisensBluetoothCharacteristics.edaSclMean,
  "663af1bc-2fa0-43c0-b452-2b8c1efb7f9d":
      MovisensBluetoothCharacteristics.edaSclMeanBuffered,
  "47755955-966e-4b75-b79b-ef5c839cb191":
      MovisensBluetoothCharacteristics.edaSclMeanWaiting,
  "3b999d71-751b-48fa-8817-b7131f47c2da":
      MovisensBluetoothCharacteristics.hrMean,
  "1d9533d1-8c6e-4b6a-b242-d0713be204f0":
      MovisensBluetoothCharacteristics.hrMeanBuffered,
  "c806ec67-00be-490a-aa79-1011396f38e8":
      MovisensBluetoothCharacteristics.hrMeanWaiting,
  "5d9724de-501e-475f-b8e6-d0e77ea4d0c1":
      MovisensBluetoothCharacteristics.hrvIsValid,
  "0524f2f1-d8da-4ef6-9e3b-43d6ed0ec518":
      MovisensBluetoothCharacteristics.hrvIsValidBuffered,
  "b2734e22-5c9e-476c-a317-d3fb706df00c":
      MovisensBluetoothCharacteristics.hrvIsValidWaiting,
  "f89edec1-9fea-e145-f614-8ff69aa7da66":
      MovisensBluetoothCharacteristics.rmssd,
  "1bc36d57-595b-499e-8f2a-fa2275bcabc3":
      MovisensBluetoothCharacteristics.rmssdBuffered,
  "f89edec0-b569-ee0d-9589-e4abd1f42693":
      MovisensBluetoothCharacteristics.rmssdWaiting,
  "207b171c-d7a5-48ef-8e60-6ccb5f0993f4":
      MovisensBluetoothCharacteristics.tapMarker,
  "c7538ae7-b2ec-4905-8ebc-4a0581df4335":
      MovisensBluetoothCharacteristics.batteryLevelBuffered,
  "f84adb7d-a503-44d4-88ba-8583b981b5b2":
      MovisensBluetoothCharacteristics.batteryLevelWaiting,
  "d34f2d52-5fcd-491c-b782-6b84e439687e":
      MovisensBluetoothCharacteristics.charging,
  "601d030e-b067-4f80-9a36-09aa9fb21670":
      MovisensBluetoothCharacteristics.chargingBuffered,
  "c1432e2e-aa2e-456b-9c4f-c16ddc449371":
      MovisensBluetoothCharacteristics.chargingWaiting,
  "7562060b-4aff-4422-aec7-77770d2a0530":
      MovisensBluetoothCharacteristics.ageFloat,
  "1ffb6b9d-52a7-4de2-a3bb-58ee97facd59":
      MovisensBluetoothCharacteristics.sensorLocation,
  "2abf95be-7496-4e72-b880-f9f00aad553b":
      MovisensBluetoothCharacteristics.bodyPosition,
  "fda6f11e-a1d0-41da-b611-5ab3ec34f6ca":
      MovisensBluetoothCharacteristics.bodyPositionBuffered,
  "8fbffb12-23ed-498b-b19c-9c9a67f14b75":
      MovisensBluetoothCharacteristics.bodyPositionWaiting,
  "e165b5d0-d83f-4a5c-86a6-306ca1ddf0ef":
      MovisensBluetoothCharacteristics.inclination,
  "f89edebf-9b5b-486d-054f-b3ce3e226d49":
      MovisensBluetoothCharacteristics.inclinationBuffered,
  "f89edeb8-dda5-770a-e42d-005ed49f5e29":
      MovisensBluetoothCharacteristics.inclinationWaiting,
  "088133e4-bf36-4c10-943a-17e07734d4ba": MovisensBluetoothCharacteristics.met,
  "82e947c3-48a2-4106-8536-b3bdc6b10453":
      MovisensBluetoothCharacteristics.metBuffered,
  "114dc370-a5d0-4d86-a701-030282a0a271":
      MovisensBluetoothCharacteristics.metLevel,
  "7ba991c9-dfa6-4776-9002-6c9696f90e14":
      MovisensBluetoothCharacteristics.metLevelBuffered,
  "547729db-1f9b-422f-a581-ea377ffcadf9":
      MovisensBluetoothCharacteristics.metLevelWaiting,
  "e19aa0f5-da3d-4dbf-a4a2-6e8ad6c4d0ce":
      MovisensBluetoothCharacteristics.metWaiting,
  "d48d48e3-318f-4a11-8dd2-cb4a9051534f":
      MovisensBluetoothCharacteristics.movementAcceleration,
  "9e2da811-041a-43ce-b703-013277f19ae6":
      MovisensBluetoothCharacteristics.movementAccelerationBuffered,
  "20b6f034-50e5-4fad-92c8-fa20ee4203c6":
      MovisensBluetoothCharacteristics.movementAccelerationWaiting,
  "8ba3207b-6a87-424d-bde0-4f665f500f04":
      MovisensBluetoothCharacteristics.steps,
  "58c6374e-9927-414a-b90e-475014af65ba":
      MovisensBluetoothCharacteristics.stepsBuffered,
  "9b72b459-d1e5-48fe-9c91-2fb168261b21":
      MovisensBluetoothCharacteristics.stepsWaiting,
  "aaabeb9a-abed-4a17-a764-0aaf0ac808fe":
      MovisensBluetoothCharacteristics.respiratoryMovement,
  "f1cc0780-95e8-4a93-a1d1-6cfac6641b24":
      MovisensBluetoothCharacteristics.activatedBufferedCharacteristics,
  "3cd05e3a-4e2c-4d6c-bee8-f02ffdbc32ea":
      MovisensBluetoothCharacteristics.commandResult,
  "8f717cee-030c-4628-9d76-4e3fd9d74fb6":
      MovisensBluetoothCharacteristics.currentTimeMs,
  "0086b101-7f7d-4249-bfae-1999065a68c2":
      MovisensBluetoothCharacteristics.customData,
  "10847e7a-d43f-4b9e-b2f2-3e8546215c3c":
      MovisensBluetoothCharacteristics.dataAvailable,
  "f89edec2-9fc2-c29e-ff29-da323b327e44":
      MovisensBluetoothCharacteristics.deleteData,
  "f89edec7-f7e0-94f2-747d-ee7acaa6d412":
      MovisensBluetoothCharacteristics.measurementEnabled,
  "2d81487d-08f7-47e1-a060-0659d9b4b766":
      MovisensBluetoothCharacteristics.measurementStartTime,
  "66f1e70e-54ab-489c-8f5d-0008b67553c7":
      MovisensBluetoothCharacteristics.measurementStatus,
  "f89edebf-9b5b-486d-054f-b3ce3e226d42":
      MovisensBluetoothCharacteristics.saveEnergy,
  "8b7446a0-372a-4841-aa5e-3b97d30a45b3":
      MovisensBluetoothCharacteristics.sendBufferedData,
  "5936ef92-62e4-4759-9041-d3461130a4b5":
      MovisensBluetoothCharacteristics.startMeasurement,
  "f89edec9-b0e0-d44f-45e8-d125177194d5":
      MovisensBluetoothCharacteristics.status,
  "8be8b5f3-03fe-4598-96b8-994e41f33979":
      MovisensBluetoothCharacteristics.storageLevel,
  "8c3adbfa-9218-419e-b809-6de9918ba8d5":
      MovisensBluetoothCharacteristics.timeZoneId,
  "b9b5bd3a-475c-43a6-b25e-bc706eb016ca":
      MovisensBluetoothCharacteristics.timeZoneOffset,
  "f89edec6-a336-5262-448d-400ca97a1c57":
      MovisensBluetoothCharacteristics.skinTemperature,
  "99ebde23-1b3e-4084-85c2-18bca6eb5a1a":
      MovisensBluetoothCharacteristics.skinTemperature1sBuffered,
  "78663ddf-83c3-4665-9d04-003c990acf78":
      MovisensBluetoothCharacteristics.skinTemperatureBuffered,
  "f89edeb7-0d8c-b529-baef-2f9ab82f6cc6":
      MovisensBluetoothCharacteristics.skinTemperatureWaiting,

  // Characteristics implemented in Bluetooth general format.
  // https://btprodspecificationrefs.blob.core.windows.net/assigned-numbers/Assigned%20Number%20Types/Assigned%20Numbers.pdf
  "00002a19-0000-1000-8000-00805f9b34fb":
      MovisensBluetoothCharacteristics.batteryLevel,
  "00002a26-0000-1000-8000-00805f9b34fb":
      MovisensBluetoothCharacteristics.firmwareRevisionString,
  "00002a29-0000-1000-8000-00805f9b34fb":
      MovisensBluetoothCharacteristics.manufacturerNameString,
  "00002a24-0000-1000-8000-00805f9b34fb":
      MovisensBluetoothCharacteristics.modelNumberString,
  "00002a25-0000-1000-8000-00805f9b34fb":
      MovisensBluetoothCharacteristics.serialNumberString,
  "00002a37-0000-1000-8000-00805f9b34fb":
      MovisensBluetoothCharacteristics.heartRateMeasurement,
  "00002a8c-0000-1000-8000-00805f9b34fb":
      MovisensBluetoothCharacteristics.gender,
  "00002a8e-0000-1000-8000-00805f9b34fb":
      MovisensBluetoothCharacteristics.height,
  "00002a98-0000-1000-8000-00805f9b34fb":
      MovisensBluetoothCharacteristics.weight,

  // TODO: Investigate use for future release.
  // "8d9fb9cb-861c-4328-b42d-075efe8fa19f": "Stop Measurement",
  // "8738ddd8-7937-43a0-848a-3a91b264e3b5": "Evaluation Expire Time",
  // "f89edec4-d590-764d-530f-8fff5c181606": "Current Time", --- DEPRECATED
  // "de1d3039-69a3-4e4b-bfe2-6ffd4b46c8cb": "Disable Encryption",
  // "4d2ac3ec-5ae7-4d15-8f7c-3c1bd052c7a1": "Encryption Enabled",
  // "d18cbddc-270c-4e6c-a53f-528636034187": "Sensor Sealed",
  // "c0a8dff0-bdcd-4497-8b32-706b23e8db99": "Seal Sensor",
  // "bfb1a5c1-bbf0-4278-a7bd-dc366c4b8fb7": "Unseal Sensor",
  // "aa040e1b-5b57-486f-afd9-d4edc48a2f1e": "Login",
  // "5bdea581-d3da-421e-8e2c-99d10c227b79": "Key Exchange Request 1",
  // "a613ee21-61f8-42e4-b82c-95b5a20f4eab": "Key Exchange Request 2",
  // "43aafc84-8866-45fa-8dff-ff94935e82bd": "Key Exchange Response 1",
  // "783e0b3c-7ad2-4e2e-bfb3-2e246c4e63d9": "Key Exchange Response 2",
};

/// Reversed map of [MovisensBluetoothCharacteristics] enum to uuid
var charToUuid = Map.fromEntries(
    characteristicUUIDToMovisensBluetoothCharacteristics.entries
        .map((e) => MapEntry(e.value, e.key)));

/// Map of service UUIDs and the corresponding [MovisensServiceTypes] enum
Map<String, MovisensServiceTypes> serviceUUIDToName = {
  "d0f0f790-66c9-4e1f-bf48-1628a7ad89f9": MovisensServiceTypes.ambient,
  "eb08670d-f244-4511-b43e-04bba968b693": MovisensServiceTypes.eda,
  "0bd51666-e7cb-469b-8e4d-2742f1ba77cd": MovisensServiceTypes.hrv,
  "32062bba-7843-4ad6-94ea-95c66909edcf": MovisensServiceTypes.marker,
  "27b66685-62e5-4e76-8c02-d625600ed2c6": MovisensServiceTypes.battery,
  "17e28d0f-5f44-421f-97d5-667655e24460": MovisensServiceTypes.userData,
  "0302c2b2-ce64-4542-b819-666d20d415bd": MovisensServiceTypes.physicalActivity,
  "da87d1a7-749c-4711-bd54-c625043ecd83": MovisensServiceTypes.respiration,
  "f89edeb6-e4e8-928b-4cfa-ebc07fce1768": MovisensServiceTypes.sensorControl,
  "247af432-444c-4211-8b9d-2c8512cfdf4a": MovisensServiceTypes.skinTemperature,
  "0000180a-0000-1000-8000-00805f9b34fb":
      MovisensServiceTypes.deviceInformation,
};

/// Reversed map of [MovisensServiceTypes] enum to uuid
var serviceToUuid = Map.fromEntries(
    serviceUUIDToName.entries.map((e) => MapEntry(e.value, e.key)));

// secondary services
List<String> _secondaryServices = [
  "0000180f-0000-1000-8000-00805f9b34fb",
  "0000180d-0000-1000-8000-00805f9b34fb",
  "0000181c-0000-1000-8000-00805f9b34fb",
];

/// Gender of the user
enum Gender { male, female, unspecified, invalid }

/// The numerical value of the [Gender] enum.
extension GenderValue on Gender {
  int get value {
    switch (this) {
      case Gender.male:
        return 0;
      case Gender.female:
        return 1;
      case Gender.unspecified:
        return 2;
      case Gender.invalid:
        return 3;
    }
  }
}

/// Converts enum to a readable string with spaces and in lower case.
String enumToReadableString(Enum e) {
  return e.name
      .splitMapJoin(RegExp(r"(?=[A-Z])"),
          onMatch: (m) => ' ${m.group(0)}', onNonMatch: (n) => n)
      .toLowerCase();
}
