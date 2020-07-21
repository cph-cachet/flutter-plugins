library mobility_test;

import 'dart:async';
import 'package:mobility_features/mobility_features.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

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
  DateTime jan01 = DateTime(2020, 01, 01);

  // Poppelgade 7, home
  GeoLocation pos1 = GeoLocation(55.692035, 12.558575);

  // Falkoner Alle
  GeoLocation pos2 = GeoLocation(55.685329, 12.538601);

  // Dronning Louises Bro
  GeoLocation pos3 = GeoLocation(55.686723, 12.563769);

  // Assistentens Kirkegaard
  GeoLocation pos4 = GeoLocation(55.690862, 12.549545);

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
          LocationSample(GeoLocation(123.456, 123.456), DateTime(2020, 01, 01));

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

    test('Test that samples persist', () async {
      /// Clean file every time test is run
      flushFiles();
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
      final loaded = await mf.loadSamples();
      expect(loaded.length, samples.length);
    });

    test('Remove duplicate samples', () async {
      /// Clean file every time test is run
      flushFiles();

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

      final samples = MobilityFactory.uniqueElements(samplesWithDuplicates);
      expect(samples.length, samplesNoDuplicates.length);
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
      void onContext(MobilityContext mc) {
        print(mc.toJson());
      }

      flushFiles();
      DateTime date = jan01;

      List<LocationSample> samples = [
        /// Home
        LocationSample(pos1, date.add(Duration(hours: 0, minutes: 0))),
        LocationSample(pos1, date.add(Duration(hours: 6, minutes: 0))),

        /// Out
        LocationSample(pos2, date.add(Duration(hours: 8, minutes: 0))),
        LocationSample(pos2, date.add(Duration(hours: 12, minutes: 0))),

        /// Home
        LocationSample(pos1, date.add(Duration(hours: 17, minutes: 0))),
        LocationSample(pos1, date.add(Duration(hours: 22, minutes: 0))),

        /// Home, New day
        LocationSample(pos1, date.add(Duration(days: 1, hours: 0, minutes: 2))),
      ];

      /// Create stream controller to stream the individual samples
      /// to the MobilityFactory instance
      StreamController<LocationSample> controller =
          StreamController.broadcast();

      /// Set up stream
      MobilityFactory mf = MobilityFactory.instance;
      await mf.startListening(controller.stream);

      int expectedContexts = 3;

      /// Listen to the Context stream
      Stream<MobilityContext> contextStream = mf.contextStream;
      contextStream.listen(expectAsync1(onContext, count: expectedContexts));

      // Stream all the samples one by one
      for (LocationSample s in samples) {
        controller.add(s);
      }
      controller.close();
    });
  });
}
