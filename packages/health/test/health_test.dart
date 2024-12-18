import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:flutter/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Health Plugin Tests', () {
    late Health health;

    setUp(() {
      health = Health();
    });

    test('getHealthDataFromTypes returns results within the correct date range', () async {
      final startTime = DateTime(2023, 1, 1);
      final endTime = DateTime(2024, 1, 1);
      final types = [HealthDataType.WORKOUT];

      final healthData = await health.getHealthDataFromTypes(
        types: types,
        startTime: startTime,
        endTime: endTime,
      );

      for (var dataPoint in healthData) {

        // print the values time
        print('dateFrom: ${dataPoint.dateFrom} - required: $startTime');
        print('dateTo: ${dataPoint.dateTo} - required: $endTime');
        expect(dataPoint.dateFrom.isAfter(startTime) || dataPoint.dateFrom.isAtSameMomentAs(startTime), isTrue);
        expect(dataPoint.dateTo.isBefore(endTime) || dataPoint.dateTo.isAtSameMomentAs(endTime), isTrue);
      }
    });

    test('getHealthDataFromTypes returns no results outside the specified date range', () async {
      final startTime = DateTime(2023, 1, 1);
      final endTime = DateTime(2024, 1, 1);
      final types = [HealthDataType.WORKOUT];

      final healthData = await health.getHealthDataFromTypes(
        types: types,
        startTime: startTime,
        endTime: endTime,
      );

      for (var dataPoint in healthData) {
        expect(dataPoint.dateFrom.isBefore(startTime), isFalse);
        expect(dataPoint.dateTo.isAfter(endTime), isFalse);
      }
    });
  });
}