import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:carp_serializable/carp_serializable.dart';

import 'mocks/device_info_mock.dart'; 

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HealthDataPoint fromJson Tests', () {

    //Instantiate Health class with the Mock
    final health = Health(deviceInfo: MockDeviceInfoPlugin());
    setUpAll(() async {
      await health.configure();
    });
    test('Test WorkoutHealthValue', () async {
      var entry = {
        "uuid": "A91A2F10-3D7B-486A-B140-5ADCD3C9C6D0",
        "value": {
          "__type": "WorkoutHealthValue",
          "workoutActivityType": "AMERICAN_FOOTBALL",
          "totalEnergyBurned": 100,
          "totalEnergyBurnedUnit": "KILOCALORIE",
          "totalDistance": 2000,
          "totalDistanceUnit": "METER"
        },
        "type": "WORKOUT",
        "unit": "NO_UNIT",
        "dateFrom": "2024-09-24T17:34:00.000",
        "dateTo": "2024-09-24T17:57:00.000",
        "sourcePlatform": "appleHealth",
        "sourceDeviceId": "756B1A7A-C972-4BDB-9748-0D4749CF299C",
        "sourceId": "com.apple.Health",
        "sourceName": "Salud",
        "recordingMethod": "manual",
        "workoutSummary": {
          "workoutType": "AMERICAN_FOOTBALL",
          "totalDistance": 2000,
          "totalEnergyBurned": 100,
          "totalSteps": 0
        }
      };

      var hdp = HealthDataPoint.fromJson(entry);

      expect(hdp.uuid, "A91A2F10-3D7B-486A-B140-5ADCD3C9C6D0");
      expect(hdp.type, HealthDataType.WORKOUT);
      expect(hdp.unit, HealthDataUnit.NO_UNIT);
      expect(hdp.sourcePlatform, HealthPlatformType.appleHealth);
      expect(hdp.sourceDeviceId, "756B1A7A-C972-4BDB-9748-0D4749CF299C");
      expect(hdp.sourceId, "com.apple.Health");
      expect(hdp.sourceName, "Salud");
      expect(hdp.recordingMethod, RecordingMethod.manual);

      expect(hdp.value, isA<WorkoutHealthValue>());
      expect((hdp.value as WorkoutHealthValue).workoutActivityType,
          HealthWorkoutActivityType.AMERICAN_FOOTBALL);
      expect((hdp.value as WorkoutHealthValue).totalEnergyBurned, 100);
      expect((hdp.value as WorkoutHealthValue).totalEnergyBurnedUnit,
          HealthDataUnit.KILOCALORIE);
      expect((hdp.value as WorkoutHealthValue).totalDistance, 2000);
      expect((hdp.value as WorkoutHealthValue).totalDistanceUnit,
          HealthDataUnit.METER);

      // debugPrint(toJsonString(hdp));
      expect(toJsonString(hdp), isA<String>());


    });
    test('Test NumericHealthValue', () {
      final json = {
        "uuid": "some-uuid-1",
        "value": {"__type": "NumericHealthValue", "numericValue": 123.45},
        "type": "HEART_RATE",
        "unit": "COUNT",
        "dateFrom": "2024-09-24T17:34:00.000",
        "dateTo": "2024-09-24T17:57:00.000",
        "sourcePlatform": "googleHealthConnect",
        "sourceDeviceId": "some-device-id",
        "sourceId": "some-source-id",
        "sourceName": "some-source-name",
        "recordingMethod": "automatic"
      };

      final hdp = HealthDataPoint.fromJson(json);

      expect(hdp.uuid, "some-uuid-1");
      expect(hdp.type, HealthDataType.HEART_RATE);
      expect(hdp.unit, HealthDataUnit.COUNT);
      expect(hdp.sourcePlatform, HealthPlatformType.googleHealthConnect);
      expect(hdp.sourceDeviceId, "some-device-id");
      expect(hdp.sourceId, "some-source-id");
      expect(hdp.sourceName, "some-source-name");
      expect(hdp.recordingMethod, RecordingMethod.automatic);

      expect(hdp.value, isA<NumericHealthValue>());
      expect((hdp.value as NumericHealthValue).numericValue, 123.45);

      // debugPrint(toJsonString(hdp));
      expect(toJsonString(hdp), isA<String>());
    });
    test('Test AudiogramHealthValue', () {
      final json = {
        "uuid": "some-uuid-2",
        "value": {
          "__type": "AudiogramHealthValue",
          "frequencies": [1000.0, 2000.0, 3000.0],
          "leftEarSensitivities": [20.0, 25.0, 30.0],
          "rightEarSensitivities": [15.0, 20.0, 25.0]
        },
        "type": "AUDIOGRAM",
        "unit": "DECIBEL_HEARING_LEVEL",
        "dateFrom": "2024-09-24T17:34:00.000",
        "dateTo": "2024-09-24T17:57:00.000",
        "sourcePlatform": "appleHealth",
        "sourceDeviceId": "some-device-id",
        "sourceId": "some-source-id",
        "sourceName": "some-source-name",
        "recordingMethod": "manual"
      };
      final hdp = HealthDataPoint.fromJson(json);

      expect(hdp.uuid, "some-uuid-2");
      expect(hdp.type, HealthDataType.AUDIOGRAM);
      expect(hdp.unit, HealthDataUnit.DECIBEL_HEARING_LEVEL);
      expect(hdp.sourcePlatform, HealthPlatformType.appleHealth);
      expect(hdp.sourceDeviceId, "some-device-id");
      expect(hdp.sourceId, "some-source-id");
      expect(hdp.sourceName, "some-source-name");
      expect(hdp.recordingMethod, RecordingMethod.manual);
      expect(hdp.value, isA<AudiogramHealthValue>());

      final audiogramValue = hdp.value as AudiogramHealthValue;
      expect(audiogramValue.frequencies, [1000.0, 2000.0, 3000.0]);
      expect(audiogramValue.leftEarSensitivities, [20.0, 25.0, 30.0]);
      expect(audiogramValue.rightEarSensitivities, [15.0, 20.0, 25.0]);
      
      // debugPrint(toJsonString(hdp));
      expect(toJsonString(hdp), isA<String>());
    });
    test('Test ElectrocardiogramHealthValue', () {
      final json = {
        "uuid": "some-uuid-3",
        "value": {
          "__type": "ElectrocardiogramHealthValue",
          "voltageValues": [
            {
              "__type": "ElectrocardiogramVoltageValue",
              "voltage": 0.1,
              "timeSinceSampleStart": 0.01
            },
            {
              "__type": "ElectrocardiogramVoltageValue",
              "voltage": 0.2,
              "timeSinceSampleStart": 0.02
            },
            {
              "__type": "ElectrocardiogramVoltageValue",
              "voltage": 0.3,
              "timeSinceSampleStart": 0.03
            }
          ],
        },
        "type": "ELECTROCARDIOGRAM",
        "unit": "VOLT",
        "dateFrom": "2024-09-24T17:34:00.000",
        "dateTo": "2024-09-24T17:57:00.000",
        "sourcePlatform": "appleHealth",
        "sourceDeviceId": "some-device-id",
        "sourceId": "some-source-id",
        "sourceName": "some-source-name",
        "recordingMethod": "active"
      };

      final hdp = HealthDataPoint.fromJson(json);

      expect(hdp.uuid, "some-uuid-3");
      expect(hdp.type, HealthDataType.ELECTROCARDIOGRAM);
      expect(hdp.unit, HealthDataUnit.VOLT);
      expect(hdp.sourcePlatform, HealthPlatformType.appleHealth);
      expect(hdp.sourceDeviceId, "some-device-id");
      expect(hdp.sourceId, "some-source-id");
      expect(hdp.sourceName, "some-source-name");
      expect(hdp.recordingMethod, RecordingMethod.active);
      expect(hdp.value, isA<ElectrocardiogramHealthValue>());

      final ecgValue = hdp.value as ElectrocardiogramHealthValue;
      expect(ecgValue.voltageValues.length, 3);
      expect(ecgValue.voltageValues[0], isA<ElectrocardiogramVoltageValue>());
      expect(ecgValue.voltageValues[0].voltage, 0.1);
      expect(ecgValue.voltageValues[0].timeSinceSampleStart, 0.01);
      expect(ecgValue.voltageValues[1].voltage, 0.2);
      expect(ecgValue.voltageValues[1].timeSinceSampleStart, 0.02);
      expect(ecgValue.voltageValues[2].voltage, 0.3);
      expect(ecgValue.voltageValues[2].timeSinceSampleStart, 0.03);
      // debugPrint(toJsonString(hdp));
      expect(toJsonString(hdp), isA<String>());
    });
    test('Test NutritionHealthValue', () {
      final json = {
        "uuid": "some-uuid-4",
        "value": {
          "__type": "NutritionHealthValue",
          "calories": 500.0,
          "carbs": 60.0,
          "protein": 20.0,
          "fat": 30.0,
          "caffeine": 100.0,
          "vitaminA": 20.0,
          "b1Thiamine": 20.0,
          "b2Riboflavin": 20.0,
          "b3Niacin": 20.0,
          "b5PantothenicAcid": 20.0,
          "b6Pyridoxine": 20.0,
          "b7Biotin": 20.0,
          "b9Folate": 20.0,
          "b12Cobalamin": 20.0,
          "vitaminC": 20.0,
          "vitaminD": 20.0,
          "vitaminE": 20.0,
          "vitaminK": 20.0,
          "calcium": 20.0,
          "cholesterol": 20.0,
          "chloride": 20.0,
          "chromium": 20.0,
          "copper": 20.0,
          "fatUnsaturated": 20.0,
          "fatMonounsaturated": 20.0,
          "fatPolyunsaturated": 20.0,
          "fatSaturated": 20.0,
          "fatTransMonoenoic": 20.0,
          "fiber": 20.0,
          "iodine": 20.0,
          "iron": 20.0,
          "magnesium": 20.0,
          "manganese": 20.0,
          "molybdenum": 20.0,
          "phosphorus": 20.0,
          "potassium": 20.0,
          "selenium": 20.0,
          "sodium": 20.0,
          "sugar": 20.0,
          "water": 20.0,
          "zinc": 20.0
        },
        "type": "NUTRITION",
        "unit": "NO_UNIT",
        "dateFrom": "2024-09-24T17:34:00.000",
        "dateTo": "2024-09-24T17:57:00.000",
        "sourcePlatform": "googleHealthConnect",
        "sourceDeviceId": "some-device-id",
        "sourceId": "some-source-id",
        "sourceName": "some-source-name",
        "recordingMethod": "manual"
      };

      final hdp = HealthDataPoint.fromJson(json);
      expect(hdp.uuid, "some-uuid-4");
      expect(hdp.type, HealthDataType.NUTRITION);
      expect(hdp.unit, HealthDataUnit.NO_UNIT);
      expect(hdp.sourcePlatform, HealthPlatformType.googleHealthConnect);
      expect(hdp.sourceDeviceId, "some-device-id");
      expect(hdp.sourceId, "some-source-id");
      expect(hdp.sourceName, "some-source-name");
      expect(hdp.recordingMethod, RecordingMethod.manual);
      expect(hdp.value, isA<NutritionHealthValue>());

      final nutritionValue = hdp.value as NutritionHealthValue;
      expect(nutritionValue.calories, 500.0);
      expect(nutritionValue.carbs, 60.0);
      expect(nutritionValue.protein, 20.0);
      expect(nutritionValue.fat, 30.0);
      expect(nutritionValue.caffeine, 100.0);
      expect(nutritionValue.vitaminA, 20.0);
      expect(nutritionValue.b1Thiamine, 20.0);
      expect(nutritionValue.b2Riboflavin, 20.0);
      expect(nutritionValue.b3Niacin, 20.0);
      expect(nutritionValue.b5PantothenicAcid, 20.0);
      expect(nutritionValue.b6Pyridoxine, 20.0);
      expect(nutritionValue.b7Biotin, 20.0);
      expect(nutritionValue.b9Folate, 20.0);
      expect(nutritionValue.b12Cobalamin, 20.0);
      expect(nutritionValue.vitaminC, 20.0);
      expect(nutritionValue.vitaminD, 20.0);
      expect(nutritionValue.vitaminE, 20.0);
      expect(nutritionValue.vitaminK, 20.0);
      expect(nutritionValue.calcium, 20.0);
      expect(nutritionValue.cholesterol, 20.0);
      expect(nutritionValue.chloride, 20.0);
      expect(nutritionValue.chromium, 20.0);
      expect(nutritionValue.copper, 20.0);
      expect(nutritionValue.fatUnsaturated, 20.0);
      expect(nutritionValue.fatMonounsaturated, 20.0);
      expect(nutritionValue.fatPolyunsaturated, 20.0);
      expect(nutritionValue.fatSaturated, 20.0);
      expect(nutritionValue.fatTransMonoenoic, 20.0);
      expect(nutritionValue.fiber, 20.0);
      expect(nutritionValue.iodine, 20.0);
      expect(nutritionValue.iron, 20.0);
      expect(nutritionValue.magnesium, 20.0);
      expect(nutritionValue.manganese, 20.0);
      expect(nutritionValue.molybdenum, 20.0);
      expect(nutritionValue.phosphorus, 20.0);
      expect(nutritionValue.potassium, 20.0);
      expect(nutritionValue.selenium, 20.0);
      expect(nutritionValue.sodium, 20.0);
      expect(nutritionValue.sugar, 20.0);
      expect(nutritionValue.water, 20.0);
      expect(nutritionValue.zinc, 20.0);
      // debugPrint(toJsonString(hdp));
      expect(toJsonString(hdp), isA<String>());
    });
    test('Test HealthValue error handling', () {
      final json = {
        "uuid": "some-uuid-error",
        "value": {
          "__type": "UnknownHealthValue", // This should throw an error
          "numericValue": 123.45
        },
        "type": "HEART_RATE",
        "unit": "COUNT_PER_MINUTE",
        "dateFrom": "2024-09-24T17:34:00.000",
        "dateTo": "2024-09-24T17:57:00.000",
        "sourcePlatform": "googleHealthConnect",
        "sourceDeviceId": "some-device-id",
        "sourceId": "some-source-id",
        "sourceName": "some-source-name",
        "recordingMethod": "automatic"
      };
      expect(
          () => HealthDataPoint.fromJson(json),
          throwsA(
              isA<SerializationException>())); //Expect SerializationException
    });
  });
}
