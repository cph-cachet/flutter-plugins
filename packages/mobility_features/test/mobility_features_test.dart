library mobility_test;

import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:mobility_features/mobility_features.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:async/async.dart';

part 'test_utils.dart';

const String datasetPath = 'lib/data/example-multi.json';
const String testDataDir = 'test/testdata';

Duration takeTime(DateTime start, DateTime end) {
  int ms = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
  return Duration(milliseconds: ms);
}

void flushFiles() async {
  File samples = new File('$testDataDir/location_samples.json');
  File stops = new File('$testDataDir/stops.json');
  File moves = new File('$testDataDir/moves.json');

  await samples.writeAsString('');
  await stops.writeAsString('');
  await moves.writeAsString('');
}

void main() async {
  List<DateTime> dates = [
    DateTime(2020, 02, 12),
    DateTime(2020, 02, 13),
    DateTime(2020, 02, 14),
    DateTime(2020, 02, 15),
    DateTime(2020, 02, 16),
    DateTime(2020, 02, 17),
  ];

  DateTime jan01 = DateTime(2020, 01, 01);

  // Poppelgade 7, home
  GeoPosition pos1 = GeoPosition(55.692035, 12.558575);

  // Falkoner Alle
  GeoPosition pos2 = GeoPosition(55.685329, 12.538601);

  // Dronning Louises Bro
  GeoPosition pos3 = GeoPosition(55.686723, 12.563769);

  // Assistentens Kirkegaard
  GeoPosition pos4 = GeoPosition(55.690862, 12.549545);

  /// This test  verifies that the 'midnight' extension
  /// works for two DateTime objects on the same date.
  test('Datetime extension', () async {
    DateTime d1 = DateTime.parse('2020-02-12 09:30:00.000');
    DateTime d2 = DateTime.parse('2020-02-12 13:31:00.400');
    expect(d1.midnight, d2.midnight);

    DateTime d3 = DateTime.parse('2020-02-13 09:30:00.000');
    expect(d1.midnight, isNot(d3.midnight));
  });

  group("Mobility Context Tests", () {
    test('Serialize and load three location samples', () async {
      MobilityFactory mf = MobilityFactory.instance;

      LocationSample x =
          LocationSample(GeoPosition(123.456, 123.456), DateTime(2020, 01, 01));

      List<LocationSample> dataset = [x, x, x];

      flushFiles();

      await mf.saveSamples(dataset);

      List<LocationSample> loaded = await mf.loadSamples();
      printList(loaded);
      expect(loaded.length, dataset.length);
    });

    test('Serialize and load and multiple days', () async {
      /// Clean file every time test is run
      flushFiles();

      MobilityFactory mf = MobilityFactory.instance;

      List<LocationSample> dataset = [];

      for (int i = 0; i < 5; i++) {
        DateTime date = jan01.add(Duration(days: i));

        /// Todays data
        List<LocationSample> locationSamples = [
          // 5 hours spent at home
          LocationSample(pos1, date.add(Duration(hours: 0, minutes: 0))),
          LocationSample(pos1, date.add(Duration(hours: 6, minutes: 0))),

          LocationSample(pos2, date.add(Duration(hours: 8, minutes: 0))),
          LocationSample(pos2, date.add(Duration(hours: 9, minutes: 30))),
        ];

        /// Save
        await mf.saveSamples(locationSamples);
        dataset.addAll(locationSamples);

        /// Load, make sure data from previous days is not stored.
        List<LocationSample> loaded = await mf.loadSamples();
        expect(loaded.length, dataset.length);
      }
    });

    test('Features: Single Stop', () async {
      flushFiles();

      MobilityFactory mf = MobilityFactory.instance;
      Duration timeTracked = Duration(hours: 17);

      /// Collect location samples (synthetic data set)
      List<LocationSample> samples = [
        // home from 00 to 17
        LocationSample(pos1, jan01),
        LocationSample(pos1, jan01.add(timeTracked)),
      ];

      /// Save samples to disk
      await mf.saveSamples(samples);

      /// Compute features
      MobilityContext context = await mf.computeFeatures(date: jan01);

      expect(context.homeStay, 1.0);
      expect(context.stops.length, 1);
      expect(context.moves.length, 0);
      expect(context.places.length, 1);
    });

    test('Features: Single day, multiple locations', () async {
      /// Clean file every time test is run
      flushFiles();

      MobilityFactory mf = MobilityFactory.instance;
      mf.usePriorContexts = true;

      List<LocationSample> locationSamples = [
        // 5 hours spent at home
        LocationSample(pos1, jan01.add(Duration(hours: 0, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 6, minutes: 0))),

        LocationSample(pos2, jan01.add(Duration(hours: 8, minutes: 0))),
        LocationSample(pos2, jan01.add(Duration(hours: 9, minutes: 30))),

        LocationSample(pos3, jan01.add(Duration(hours: 10, minutes: 0))),
        LocationSample(pos3, jan01.add(Duration(hours: 11, minutes: 30))),

        /// 1 hour spent at home
        LocationSample(pos1, jan01.add(Duration(hours: 15, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 16, minutes: 0))),

        LocationSample(pos4, jan01.add(Duration(hours: 17, minutes: 0))),
        LocationSample(pos4, jan01.add(Duration(hours: 18, minutes: 0))),

        // 1 hour spent at home
        LocationSample(pos1, jan01.add(Duration(hours: 20, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 21, minutes: 0))),
      ];

      await mf.saveSamples(locationSamples);

      /// Calculate and save context
      MobilityContext context = await mf.computeFeatures(date: jan01);

      Duration homeTime = Duration(hours: 8);
      Duration timeTracked =
          Duration(hours: locationSamples.last.datetime.hour);
      double homeStayTruth =
          homeTime.inMilliseconds / timeTracked.inMilliseconds;

      expect(context.homeStay, homeStayTruth);
      expect(context.routineIndex, -1.0);
      expect(context.stops.length, 6);
      expect(context.moves.length, 5);
      expect(context.places.length, 4);
    });

    test('Features: Multiple days, multiple locations', () async {
      /// Clean file every time test is run
      flushFiles();

      MobilityFactory mf = MobilityFactory.instance;
      mf.usePriorContexts = true;

      for (int i = 0; i < 5; i++) {
        DateTime date = jan01.add(Duration(days: i));

        /// Todays data
        List<LocationSample> locationSamples = [
          // 5 hours spent at home
          LocationSample(pos1, date.add(Duration(hours: 0, minutes: 0))),
          LocationSample(pos1, date.add(Duration(hours: 6, minutes: 0))),

          LocationSample(pos2, date.add(Duration(hours: 8, minutes: 0))),
          LocationSample(pos2, date.add(Duration(hours: 9, minutes: 0))),
        ];

        await mf.saveSamples(locationSamples);

        /// Calculate and save context
        MobilityContext context = await mf.computeFeatures(date: date);

        double routineIndex = context.routineIndex;
        double homeStay = context.homeStay;

        expect(context.stops.length, 2);
        expect(context.places.length, 2);
        expect(context.moves.length, 1);

        expect(homeStay, 6 / 9);

        // The first day the routine index should be -1,
        // otherwise 1 since the days are exactly the same
        if (i == 0) {
          expect(routineIndex, -1);
        } else {
          expect(routineIndex, 1);
        }
      }
    });

    test('Stops: Multiple days, multiple locations, with overlap', () async {
      /// Clean file every time test is run
      flushFiles();

      MobilityFactory mf = MobilityFactory.instance;

      for (int i = 0; i < 5; i++) {
        DateTime date = jan01.add(Duration(days: i));

        /// Todays data
        List<LocationSample> locationSamples = [
          // 5 hours spent at home
          LocationSample(pos1, date.add(Duration(hours: 0, minutes: 0))),
          LocationSample(pos1, date.add(Duration(hours: 6, minutes: 0))),

          LocationSample(pos2, date.add(Duration(hours: 8, minutes: 0))),
          LocationSample(pos2, date.add(Duration(hours: 9, minutes: 0))),

          LocationSample(pos1, date.add(Duration(hours: 21, minutes: 0))),
          LocationSample(
              pos1, date.add(Duration(hours: 23, minutes: 59, seconds: 59))),
        ];

        await mf.saveSamples(locationSamples);

        /// Calculate and save context
        MobilityContext context = await mf.computeFeatures(date: date);

        /// Verify that stops are not shared among days
        /// This should not be the case since samples from
        /// previous days are filtered out.
        expect(context.stops.length, 3);
        expect(context.places.length, 2);
        expect(context.moves.length, 2);
      }
    });

    test('Test that samples persist', () async {
      /// Clean file every time test is run
      await flushFiles();
      MobilityFactory mf = MobilityFactory.instance;

      List<LocationSample> samples = [
        // 5 hours spent at home
        LocationSample(pos1, jan01.add(Duration(hours: 0, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 6, minutes: 0))),

        LocationSample(pos2, jan01.add(Duration(hours: 8, minutes: 0))),
        LocationSample(pos2, jan01.add(Duration(hours: 9, minutes: 0))),

        LocationSample(pos1, jan01.add(Duration(hours: 21, minutes: 0))),
        LocationSample(
            pos1, jan01.add(Duration(hours: 23, minutes: 59, seconds: 59))),
      ];

      await mf.saveSamples(samples);

      /// Calculate and save context
      MobilityContext context = await mf.computeFeatures(date: jan01);

      final loaded = await mf.loadSamples();
      printList(loaded);
    });

    test('Remove duplicate samples', () async {
      /// Clean file every time test is run
      await flushFiles();

      List<LocationSample> samplesNoDuplicates = [
        // 5 hours spent at home
        LocationSample(pos1, jan01.add(Duration(hours: 0, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 6, minutes: 0))),

        LocationSample(pos2, jan01.add(Duration(hours: 8, minutes: 0))),
        LocationSample(pos2, jan01.add(Duration(hours: 9, minutes: 0))),

        LocationSample(pos1, jan01.add(Duration(hours: 21, minutes: 0))),
        LocationSample(
            pos1, jan01.add(Duration(hours: 23, minutes: 59, seconds: 59))),
      ];

      /// Todays data
      List<LocationSample> samplesWithDuplicates = [
        // 5 hours spent at home
        LocationSample(pos1, jan01.add(Duration(hours: 0, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 6, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 6, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 6, minutes: 0))),

        LocationSample(pos2, jan01.add(Duration(hours: 8, minutes: 0))),
        LocationSample(pos2, jan01.add(Duration(hours: 8, minutes: 0))),
        LocationSample(pos2, jan01.add(Duration(hours: 8, minutes: 0))),
        LocationSample(pos2, jan01.add(Duration(hours: 9, minutes: 0))),

        LocationSample(pos1, jan01.add(Duration(hours: 0, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 6, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 6, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 6, minutes: 0))),

        LocationSample(pos1, jan01.add(Duration(hours: 21, minutes: 0))),
        LocationSample(
            pos1, jan01.add(Duration(hours: 23, minutes: 59, seconds: 59))),
      ];

      printList(samplesWithDuplicates.map((e) => e.datetime).toSet().toList());
      await MobilityFactory.instance.saveSamples(samplesNoDuplicates);

      /// Calculate and save context
      MobilityContext context1 =
          await MobilityFactory.instance.computeFeatures(date: jan01);

      /// Verify that stops are not shared among days
      /// This should not be the case since samples from
      /// previous days are filtered out.
      expect(context1.stops.length, 3);
      expect(context1.places.length, 2);
      expect(context1.moves.length, 2);

      flushFiles();

      await MobilityFactory.instance.saveSamples(samplesWithDuplicates);

      /// Calculate and save context
      MobilityContext context2 =
          await MobilityFactory.instance.computeFeatures(date: jan01);

      /// Verify that stops are not shared among days
      /// This should not be the case since samples from
      /// previous days are filtered out.
      expect(context2.stops.length, 3);
      expect(context2.places.length, 2);
      expect(context2.moves.length, 2);
    });

    test('Save samples one at a time', () async {
      flushFiles();

      MobilityFactory mf = MobilityFactory.instance;

      List<LocationSample> samples = [
        LocationSample(pos1, jan01.add(Duration(hours: 0, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 6, minutes: 0))),
        LocationSample(pos2, jan01.add(Duration(hours: 8, minutes: 0))),
        LocationSample(pos2, jan01.add(Duration(hours: 9, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 21, minutes: 0))),
        LocationSample(
            pos1, jan01.add(Duration(hours: 23, minutes: 59, seconds: 59))),
      ];

      // Save samples, one by one
      for (var s in samples) {
        mf.saveSamples([s]);
      }

      // Load samples again, verify that they were all saved
      final loaded = await mf.loadSamples();
      expect(samples.length, loaded.length);
    });

    test('Stream LocationSamples one by one', () async {
      flushFiles();
      DateTime date = jan01;

      List<LocationSample> samples = [
        // 5 hours spent at home
        LocationSample(pos1, date.add(Duration(hours: 0, minutes: 0))),
        LocationSample(pos1, date.add(Duration(hours: 6, minutes: 0))),

        LocationSample(pos2, date.add(Duration(hours: 8, minutes: 0))),
        LocationSample(pos2, date.add(Duration(hours: 9, minutes: 0))),

        LocationSample(pos1, date.add(Duration(hours: 21, minutes: 0))),
        LocationSample(
            pos1, date.add(Duration(hours: 23, minutes: 59, seconds: 59))),
      ];

      MobilityFactory mf = MobilityFactory.instance;
      mf.saveEvery = 1;

      Stream<LocationSample> stream = Stream.fromIterable(samples);

      // Stream all the samples one by one
      await mf.startListening(stream);

      // After all data has been streamed, load the saved data
      final loaded = await mf.loadSamples();

      // Verify that all data was streamed and stored
      expect(loaded.length, samples.length);
    });

    test('Stream Location DTOs one by one', () async {
      flushFiles();

      // Array of location DTOs, mocking DTOs from an external plugin
      List<LocationDTO> dtos = [
        LocationDTO(111.123, 123.123),
        LocationDTO(222.123, 123.123),
        LocationDTO(333.123, 123.123),
      ];

      // Convert DTO array to DTO stream
      Stream<LocationDTO> locationStream = Stream.fromIterable(dtos);

      // Convert DTO stream to LocationSample stream via a mapper function
      Stream<LocationSample> stream = locationStream.map((dto) =>
          LocationSample(GeoPosition(dto.lat, dto.lon), DateTime.now()));

      // Instantiate the MobilityFactory
      MobilityFactory mf = MobilityFactory.instance;
      mf.saveEvery = 1;

      // Stream all the samples one by one
      await mf.startListening(stream);

      // After all data has been streamed, load the saved data
      final loaded = await mf.loadSamples();

      // Verify that all data was streamed and stored
      expect(loaded.length, dtos.length);
    });

    test('Test for isolate', () async {
      /// Clean file every time test is run
      await flushFiles();
      MobilityFactory mf = MobilityFactory.instance;

      List<LocationSample> samples = [
        // 5 hours spent at home
        LocationSample(pos1, jan01.add(Duration(hours: 0, minutes: 0))),
        LocationSample(pos1, jan01.add(Duration(hours: 6, minutes: 0))),

        LocationSample(pos2, jan01.add(Duration(hours: 8, minutes: 0))),
        LocationSample(pos2, jan01.add(Duration(hours: 9, minutes: 0))),

        LocationSample(pos1, jan01.add(Duration(hours: 21, minutes: 0))),
        LocationSample(
            pos1, jan01.add(Duration(hours: 23, minutes: 59, seconds: 59))),
      ];

      await mf.saveSamples(samples);

      /// Calculate and save context
      MobilityContext context = await mf.computeFeatures(date: jan01);

      final loaded = await mf.loadSamples();
      printList(loaded);
    });

    test('Multiple days, stream', () async {
      /// Clean file every time test is run
      flushFiles();

      MobilityFactory mf = MobilityFactory.instance;
      List<LocationSample> data = [];

      for (int i = 0; i < 5; i++) {
        DateTime date = jan01.add(Duration(days: i));

        /// Todays data
        List<LocationSample> locationSamples = [
          // 5 hours spent at home
          LocationSample(pos1, date.add(Duration(hours: 0, minutes: 0))),
          LocationSample(pos1, date.add(Duration(hours: 6, minutes: 0))),

          LocationSample(pos2, date.add(Duration(hours: 8, minutes: 0))),
          LocationSample(pos2, date.add(Duration(hours: 9, minutes: 0))),

          LocationSample(pos1, date.add(Duration(hours: 21, minutes: 0))),
          LocationSample(
              pos1, date.add(Duration(hours: 23, minutes: 59, seconds: 59))),
        ];

        data.addAll(locationSamples);
      }

      Stream<LocationSample> stream = Stream.fromIterable(data);
      mf.startListening(stream);

      List<DateTime> oddOrderedDates = [
        DateTime(2020, 01, 04),
        DateTime(2020, 01, 05),
        DateTime(2020, 01, 03),
        DateTime(2020, 01, 01),
        DateTime(2020, 01, 02)
      ];
      for (var date in oddOrderedDates) {
        MobilityContext context = await mf.computeFeatures(date: date);
        expect(context.stops.length, 3);
        expect(context.places.length, 2);
        expect(context.moves.length, 2);
      }
    });
  });
}
