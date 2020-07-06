library mobility_test;

import 'dart:async';
import 'dart:collection';

import 'package:mobility_features/mobility_features.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:async/async.dart';

part 'test_utils.dart';

const String LOCATION_SAMPLES = 'location_samples',
    STOPS = 'stops',
    MOVES = 'moves';

const String datasetPath = 'lib/data/example-multi.json';
const String testDataDir = 'test/testdata';

Duration takeTime(DateTime start, DateTime end) {
  int ms = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
  return Duration(milliseconds: ms);
}

void flushFiles() async {
  File samples = new File('$testDataDir/$LOCATION_SAMPLES.json');
  File stops = new File('$testDataDir/$STOPS.json');
  File moves = new File('$testDataDir/$MOVES.json');

  samples.writeAsStringSync('');
  stops.writeAsStringSync('');
  moves.writeAsStringSync('');
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
      MobilityContext context =
          await mf.computeFeatures(date: jan01);

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

      await MobilityFactory.instance.saveSamples(samples);

      /// Calculate and save context
      MobilityContext context =
          await MobilityFactory.instance.computeFeatures(date: jan01);

      final loaded = await MobilityFactory.instance.loadSamples();
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

    test('Stream from location plugin', () async {
      final streamedData = [];

      // Handle stream data
      void onData(dynamic x) {
        streamedData.add(x);
      }

      // Create mock location plugin.
      final plugin = MockLocationPlugin<int>();

      // Data to be streamed
      final data = [1, 2, 3, 4];

      // Set up a mock stream by feeding it the data
      when(plugin.stream).thenAnswer((_) => Stream.fromIterable(data));

      // Stream the provided data
      plugin.stream.listen(onData);
      print(streamedData);
    });

    test('Stream listen test', () {
      DateTime date = jan01;

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

      List<Map<String, dynamic>> data =
          locationSamples.map((x) => x.toJson()).toList();

      final s = Stream.fromIterable(data);
    });

    test('Stream listen test', () async {
      List<LocationDTO> samples = [
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
        LocationDTO(123.123, 123.123),
      ];

      Stream<LocationDTO> locationStream = Stream.fromIterable(samples);

      MobilityFactory mf = MobilityFactory.instance;

      mf.locationStream = locationStream.map((dto) =>
          LocationSample(GeoPosition(dto.lat, dto.lon), DateTime.now()));

      final loaded = await mf.loadSamples();

      printList(loaded);
    });
  });

//  test('Simulate everything', () async {
//    List<MobilityContext> contexts = [];
//    MobilitySerializer<LocationSample> dataSerializer =
//        await ContextGenerator.locationSampleSerializer;
//
//    /// Reset file content
//    dataSerializer.flush();
//
//    /// Init data
//    List<SingleLocationPoint> data = await Dataset().loadDataset(datasetPath);
//    List<SingleLocationPoint> buffer = [];
//    int bufferSize = 100;
//
//    /// Simulate going through the dates
//    for (DateTime today in dates) {
//      List dataOnDate =
//          data.where((d) => d.datetime.midnight == today.midnight).toList();
//
//      /// Simulate data points coming in one at a time
//      for (SingleLocationPoint x in dataOnDate) {
//        buffer.add(x);
//
//        /// Fill up buffer. When full: write data to file.
//        if (buffer.length >= bufferSize) {
//          await dataSerializer.save(buffer);
//          buffer = [];
//        }
//      }
//
//      /// Pre-process today's data
//      DataPreprocessor preprocessor = DataPreprocessor(today);
//
//      /// Time passes, and we now need the data
//      List<SingleLocationPoint> loadedData = await dataSerializer.load();
//
//      /// Filter out data points NOT from today which may be stored in the file,
//      /// from a previous day
//      List<SingleLocationPoint> loadedDataFromToday =
//          preprocessor.pointsToday(loadedData);
//
//      /// Remember to add the remaining buffer to the loaded data as well.
//      List<SingleLocationPoint> pointsAll = loadedDataFromToday + buffer;
//
//      /// Find new stops and moves
//      List<Stop> stopsToday = preprocessor.findStops(pointsAll);
//      List<Move> movesToday = preprocessor.findMoves(pointsAll, stopsToday);
//
//      /// Load old stops and moves
//      List<Stop> stopsLoaded = await stopSerializer.load();
//      List<Move> movesLoaded = await moveSerializer.load();
//
//      /// Set a breakpoint for which older stops/moves will be disregarded
//      /// and thrown away
//      DateTime fourWeeksAgo = today.subtract(Duration(days: 28));
//
//      /// Filter out stops and moves which were computed today,
//      /// which were just loaded as well as stops older than 28 days
//      List<Stop> stopsOld = stopsLoaded
//          .where((s) =>
//              s.arrival.midnight != today.midnight &&
//              fourWeeksAgo.leq(s.arrival.midnight))
//          .toList();
//
//      List<Move> movesOld = movesLoaded
//          .where((m) =>
//              m.stopFrom.arrival.midnight != today.midnight &&
//              fourWeeksAgo.leq(m.stopFrom.arrival.midnight))
//          .toList();
//
//      /// Concatenate old and and new
//      List<Stop> stopsAll = stopsOld + stopsToday;
//      List<Move> movesAll = movesOld + movesToday;
//
//      /// Find all places, both historic and today
//      List<Place> placesAll = preprocessor.findPlaces(stopsAll);
//
//      /// Save today's stops and moves.
//      /// Naive approach, is to just append - but this
//      /// assumes this processing is done 23:59:59
//      /// and that it hasn't been done previously on this day.
//      /// By flushing the file and writing ALL stops and moves,
//      /// the issue is avoided, albeit by using more compute power.
//      stopSerializer.flush();
//      moveSerializer.flush();
//      stopSerializer.save(stopsAll);
//      moveSerializer.save(movesAll);
//
//      /// Calculate features
//      MobilityContext mc = MobilityContext(stopsAll, placesAll, movesAll,
//          contexts: contexts, date: today);
//      contexts.add(mc);
//
//      print("Routine index daily: ${mc.routineIndex}");
//      print(mc.hourMatrix);
//      print('-' * 40);
//    }
//  });
///////

//  test('Serialization of stops and moves', () async {
//    /// Create a [SingleLocationPoint] manually
//    SingleLocationPoint p1 =
//        SingleLocationPoint(Location(12.345, 98.765), DateTime(2020, 02, 16));
//
//    /// Serialize it
//    var toJson = p1.toJson();
//    print(toJson);
//
//    /// Deserialize it
//    SingleLocationPoint fromJson = SingleLocationPoint.fromJson(toJson);
//    print(fromJson);
//
//    /// Create a [Stop] manually
//    Stop s1 = Stop.fromPoints([p1, p1, p1], placeId: 2);
//    print(s1);
//
//    /// Serialize it
//    var jsonStop = s1.toJson();
//
//    /// Deserialize it
//    Stop stopFromJson = Stop.fromJson(jsonStop);
//
//    /// Make a [List] of stops
//    List jsonStops = [stopFromJson, stopFromJson, stopFromJson]
//        .map((s) => s.toJson())
//        .toList();
//
//    /// Serialize it
//    String jsonStringStops = json.encode(jsonStops);
//
//    /// Deserialize it
//    List decoded = json.decode(jsonStringStops);
//    List<Stop> stopsDecoded = decoded.map((d) => Stop.fromJson(d)).toList();
//    printList(decoded);
//    printList(stopsDecoded);
//
//    /// Move serialization
//    SingleLocationPoint p2 =
//        SingleLocationPoint(Location(13.345, 95.765), DateTime(2020, 02, 17));
//    Stop s2 = Stop.fromPoints([p2, p2, p2], placeId: 1);
//
//    Move m = Move.fromPath(s1, s2, [p1, p2]);
//    print(m);
//
//    var jsonMove = m.toJson();
//    print(jsonMove);
//
//    Move moveFromJson = Move.fromJson(jsonMove);
//
//    print(moveFromJson);
//
//    /// Make a [List] of stops
//    List jsonMoves = [moveFromJson, moveFromJson, moveFromJson]
//        .map((m) => m.toJson())
//        .toList();
//
//    /// Serialize it
//    String jsonStringMoves = json.encode(jsonMoves);
//
//    /// Deserialize it
//    List decodedMovesMaps = json.decode(jsonStringMoves);
//    printList(decodedMovesMaps);
//
//    List<Move> decodedMoves =
//        decodedMovesMaps.map((d) => Move.fromJson(d)).toList();
//    printList(decodedMoves);
//  });
//
//  test('Incremental RI', () async {
//    List<SingleLocationPoint> data = await Dataset().loadDataset(datasetPath);
//    List<MobilityContext> contexts;
//
//    /// Equivalent to storing stops & moves on device, with a date attached
//    Map<DateTime, List<Stop>> stopsDict = {};
//    Map<DateTime, List<Move>> movesDict = {};
//
//    for (DateTime today in dates) {
//      DataPreprocessor dp = DataPreprocessor(today);
//
//      List<SingleLocationPoint> dataOnDate =
//          data.where((x) => (x.datetime.midnight == today)).toList();
//
//      /// Compute stops and moves today
//      List<Stop> stopsOnDate = dp.findStops(dataOnDate);
//      List<Move> movesOnDate = dp.findMoves(dataOnDate, stopsOnDate);
//
//      /// Save them
//      stopsDict[today] = stopsOnDate;
//      movesDict[today] = movesOnDate;
//
//      /// Get ALL the stored stops, in order to find ALL places
//      List<Stop> allStops = stopsDict.values.expand((l) => l).toList();
//      List<Place> allPlaces = dp.findPlaces(allStops);
//
//      /// Create the new contexts, from the previous stops and moves and ALL places
//      contexts = stopsDict.keys
//          .map((date) => MobilityContext(
//              stopsDict[date], allPlaces, movesDict[date],
//              contexts: contexts, date: date))
//          .toList();
//
//      /// Create the Mobility Context (MC) today.
//      /// It doesn't matter that we feed it today's MC as well (in the contexts array),
//      /// since this will be filtered out in the routine index calculation anyways.
//      MobilityContext mc = MobilityContext(stopsOnDate, allPlaces, movesOnDate,
//          contexts: contexts, date: today);
//      print(stopsOnDate.length);
//      print(contexts);
//      print('$today | RoutineIndex: ${mc.routineIndex}');
//    }
//  });
//
//  test('write to file', () async {
//    File f = new File('test/data/test_file.txt');
//    await f.writeAsString('test 123 123 123');
//
//    String res = await f.readAsString();
//
//    print(res);
//  });
//
//  test('Serialization to file', () async {
//    /// Single data points
//    List<SingleLocationPoint> data = await Dataset().loadDataset(datasetPath);
//
//    Serializer<SingleLocationPoint> dataSerializer =
//        Serializer(new File('$testDataDir/munich_points.json'));
//    List<SingleLocationPoint> subset = data.sublist(0, 5);
//    printList(subset);
//
//    /// Serialize the subset of 5 points
//    await dataSerializer.save(subset);
//
//    /// De-serialize the subset from file
//    List<SingleLocationPoint> dataFromFile = await dataSerializer.load();
//    printList(dataFromFile);
//
//    List<Stop> stops = [
//      Stop.fromPoints(data.sublist(0, 10), placeId: 1),
//      Stop.fromPoints(data.sublist(10, 20), placeId: 2),
//      Stop.fromPoints(data.sublist(20, 30), placeId: 3),
//      Stop.fromPoints(data.sublist(30, 40), placeId: 4)
//    ];
//
//    printList(stops);
//
//    /// Serialize stops
//    Serializer<Stop> stopSerializer =
//        Serializer(new File('$testDataDir/munich_stops.json'));
//    stopSerializer.save(stops);
//
//    /// De-serialize stops
//    List<Stop> stopsFromFile = await stopSerializer.load();
//    print('Stops deserialized:');
//    printList(stopsFromFile);
//
//    List<Move> moves = [
//      Move.fromPath(stops[0], stops[1], data.sublist(0, 20)),
//      Move.fromPath(stops[1], stops[2], data.sublist(10, 30)),
//      Move.fromPath(stops[2], stops[3], data.sublist(20, 40))
//    ];
//
//    printList(moves);
//
//    /// Serialize moves
//    Serializer<Move> moveSerializer =
//        Serializer(new File('$testDataDir/munich_moves.json'));
//    moveSerializer.save(moves);
//
//    /// Deserialize moves
//    List<Move> movesFromFile = await moveSerializer.load();
//    print('Moves deserialized:');
//    printList(movesFromFile);
//  });
//
//  test('Serialize all Data points', () async {
//    /// Single data points
//    List<SingleLocationPoint> data = await Dataset().loadDataset(datasetPath);
//
//    Serializer dataSerializer =
//        Serializer(new File('$testDataDir/all_points.json'));
//
//    /// Serialize the dataset
//    dataSerializer.save(data);
//  });
//
//  test('De-serialize all Data points', () async {
//    /// Single data points
//    List<SingleLocationPoint> data = await Dataset().loadDataset(datasetPath);
//
//    Serializer<SingleLocationPoint> dataSerializer =
//        Serializer(new File('$testDataDir/all_points.json'));
//
//    /// Serialize the dataset
//    List<SingleLocationPoint> dataFromFile = await dataSerializer.load();
//    assert(dataFromFile.length == data.length);
//  });
//
//  test('Serialize Stops and Moves', () async {
//    Serializer<Stop> stopSerializer =
//        Serializer(new File('$testDataDir/all_stopxs.json'));
//    Serializer<Move> moveSerializer =
//        Serializer(new File('$testDataDir/all_moves.json'));
//
//    stopSerializer.flush();
//    moveSerializer.flush();
//
//    /// Single data points
//    List<SingleLocationPoint> data = await Dataset().loadDataset(datasetPath);
//
//    for (DateTime date in dates) {
//      List<SingleLocationPoint> dataOnDate =
//          data.where((x) => x.datetime.midnight == date).toList();
//      DataPreprocessor preprocessor = DataPreprocessor(date);
//      List<Stop> newStops = preprocessor.findStops(dataOnDate);
//      List<Move> newMoves = preprocessor.findMoves(dataOnDate, newStops);
//
//      /// Save to file  by reading the content, appending it, and then writing
//      List<Stop> stops = await stopSerializer.load();
//      List<Move> moves = await moveSerializer.load();
//      stops.addAll(newStops);
//      moves.addAll(newMoves);
//
//      List<Place> places = preprocessor.findPlaces(stops);
//
//      ///  Do something with places
//
//      /// Write new stops and moves
//      stopSerializer.save(newStops);
//      moveSerializer.save(newMoves);
//    }
//
//    List<Stop> stops = await stopSerializer.load();
//    List<Move> moves = await moveSerializer.load();
//    print("Number of stops: ${stops.length}");
//    print("Number of moves: ${moves.length}");
//  });
//
//  test('Load stops and moves', () async {
//    Serializer<Stop> stopSerializer =
//        Serializer(new File('$testDataDir/all_stops.json'));
//    Serializer<Move> moveSerializer =
//        Serializer(new File('$testDataDir/all_moves.json'));
//
//    List<Stop> stops = await stopSerializer.load();
//    List<Move> moves = await moveSerializer.load();
//
//    print("Number of stops: ${stops.length}");
//    print("Number of moves: ${moves.length}");
//  });
//
//  test('Serialize empty Stops and Moves', () async {
//    Serializer<SingleLocationPoint> dataSerializer =
//        Serializer(new File('$testDataDir/empty_data.json'));
//    Serializer<Stop> stopSerializer =
//        Serializer(new File('$testDataDir/empty_stops.json'));
//    Serializer<Move> moveSerializer =
//        Serializer(new File('$testDataDir/empty_moves.json'));
//
//    List<SingleLocationPoint> points = await dataSerializer.load();
//    List<Stop> stops = await stopSerializer.load();
//    List<Move> moves = await moveSerializer.load();
//
//    print('Loaded ${points.length} points');
//    print('Loaded ${stops.length} stops');
//    print('Loaded ${moves.length} moves');
//    print("Ran test without errors!");
//  });
//

//
//  test('Test a single date from Bornholm', () async {
//    List<MobilityContext> contexts = [];
//
//    Serializer<SingleLocationPoint> pointSerializer =
//        Serializer(new File('$testDataDir/points-april.json'));
//    Serializer<Stop> stopSerializer =
//        Serializer(new File('$testDataDir/stops-april.json'));
//    Serializer<Move> moveSerializer =
//        Serializer(new File('$testDataDir/moves-april.json'));
//
//    List<DateTime> aprilDates = [
//      DateTime(2020, 04, 10),
//      DateTime(2020, 04, 11),
//    ];
//
//    List<Stop> stops = [];
//    List<Move> moves = [];
//
//    List<SingleLocationPoint> points = await pointSerializer.load();
//    List<Place> places;
//    for (DateTime today in aprilDates) {
//      DataPreprocessor preprocessor = DataPreprocessor(today);
//      List<SingleLocationPoint> pointsToday = preprocessor.pointsToday(points);
//      stops.addAll(preprocessor.findStops(pointsToday));
//      moves.addAll(preprocessor.findMoves(pointsToday, stops));
//      places = preprocessor.findPlaces(stops);
//
//      MobilityContext mc = MobilityContext(stops, places, moves,
//          contexts: contexts, date: today);
//      contexts.add(mc);
//    }
//
//    printList(stops);
//    printList(moves);
//    printList(places);
//  });
}
