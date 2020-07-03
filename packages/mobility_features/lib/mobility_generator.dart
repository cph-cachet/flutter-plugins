part of mobility_features;

class MobilityGenerator {
  static const String LOCATION_SAMPLES = 'location_samples',
      STOPS = 'stops',
      MOVES = 'moves';

  static Future<File> _file(String type) async {
    bool isMobile = Platform.isAndroid || Platform.isIOS;

    /// If on a mobile device, use the path_provider plugin to access the
    /// file system
    String path;
    if (isMobile) {
      path = (await getApplicationDocumentsDirectory()).path;
    } else {
      path = 'test/testdata';
    }
    return new File('$path/$type.json');
  }

  static Future<_MobilitySerializer<LocationSample>>
      get _locationSampleSerializer async =>
          _MobilitySerializer<LocationSample>._(await _file(LOCATION_SAMPLES));

  static Future<void> saveSamples(List<LocationSample> samples) async {
    (await _locationSampleSerializer).save(samples);
  }

  static Future<List<LocationSample>> loadSamples() async {
    List<LocationSample> samples =
        await (await _locationSampleSerializer).load();
    return samples;
  }

  static Future<MobilityContext> computeFeatures(
      {bool usePriorContexts: false,
      DateTime today,
      double placeRadius: 50,
      double stopRadius: 25,
      Duration stopDuration: const Duration(minutes: 3)}) async {
    /// Init serializers
    _MobilitySerializer<LocationSample> sampleSerializer =
        await _locationSampleSerializer;
    _MobilitySerializer<Stop> stopSerializer =
        _MobilitySerializer<Stop>._(await _file(STOPS));
    _MobilitySerializer<Move> moveSerializer =
        _MobilitySerializer<Move>._(await _file(MOVES));

    // Define today as today if it is not defined
    today = today ?? DateTime.now();

    // Set date to midnight 00:00
    today = today.midnight;

    // Filter out stops/moves older than 28 days
    List<Stop> stops = await stopSerializer.load();
    List<Move> moves = await moveSerializer.load();
    stops = _filterStops(stops, today);
    moves = _filterMoves(moves, today);

    /// Load samples from disk, sort by datetime
    List<LocationSample> samples = await sampleSerializer.load();
    samples.sort((a, b) => a.datetime.compareTo(b.datetime));

    // Find the dates of the stored samples
    List<DateTime> sampleDates =
        samples.map((e) => e.datetime.midnight).toSet().toList();

    // Group the samples by date
    List<List<LocationSample>> groupedSamples = sampleDates
        .map((date) =>
            samples.where((e) => e.datetime.midnight == date).toList())
        .toList();

    // Find stops and moves for each date
    for (List<LocationSample> samplesOnDate in groupedSamples) {
      List<Stop> stopsOnDate = _findStops(samplesOnDate,
          stopRadius: stopRadius, stopDuration: stopDuration);
      List<Move> movesOnDate = _findMoves(samplesOnDate, stopsOnDate);
      stops += stopsOnDate;
      moves += movesOnDate;
    }

    /// Find places for the period
    List<Place> places = _findPlaces(stops, placeRadius: placeRadius);

    /// Save Stops and Moves to disk
    stopSerializer.flush();
    moveSerializer.flush();
    sampleSerializer.flush();

    // Extract stops and moves from today
    List<Stop> stopsToday = _stopsForDate(stops, today);
    List<Move> movesToday = _movesForDate(moves, today);
    List<LocationSample> samplesToday = _samplesForDate(samples, today);

    // Save
    sampleSerializer.save(samplesToday);
    stopSerializer.save(stops);
    moveSerializer.save(moves);

    /// Find prior contexts, if prior is not chosen just leave empty
    List<MobilityContext> priorContexts = [];

    /// If Prior is chosen, compute mobility contexts for each previous date.
    if (usePriorContexts) {
      // Get the dates of the stored stops, exclude today
      Set<DateTime> dates = stops.map((s) => s.arrival.midnight).toSet();
      dates.remove(today);

      // Get the stops and moves for each date
      for (DateTime date in dates) {
        List<Stop> stopsOnDate = _stopsForDate(stops, date);
        List<Move> movesOnDate = _movesForDate(moves, date);

        // If there are any stops, make a MobilityContext object with no prior contexts
        if (stopsOnDate.length > 0) {
          MobilityContext mc =
              MobilityContext._(stopsOnDate, places, movesOnDate, [], date);
          priorContexts.add(mc);
        }
      }
    }

    // Make a MobilityContext for today, use the prior Contexts
    // (the array may be empty)
    return MobilityContext._(
        stopsToday, places, movesToday, priorContexts, today);
  }

  static List<Stop> _stopsForDate(List<Stop> stops, DateTime date) {
    return stops.where((x) => x.datetime.midnight == date).toList();
  }

  static List<Move> _movesForDate(List<Move> moves, DateTime date) {
    return moves.where((x) => x.datetime.midnight == date).toList();
  }

  static List<LocationSample> _samplesForDate(
      List<LocationSample> samples, DateTime date) {
    return samples.where((x) => x.datetime.midnight == date).toList();
  }

  static List<Stop> _filterStops(List<Stop> stops, DateTime date) {
    DateTime fourWeeksPrior = date.subtract(Duration(days: 28));
    return stops
        .where((x) =>
            x.arrival.midnight.isAfter(fourWeeksPrior) &&
            x.arrival.midnight.isBefore(date))
        .toList();
  }

  static List<Move> _filterMoves(List<Move> moves, DateTime date) {
    DateTime fourWeeksPrior = date.subtract(Duration(days: 28));
    return moves
        .where((x) =>
            x.stopFrom.arrival.midnight.isAfter(fourWeeksPrior) &&
            x.stopFrom.arrival.midnight.isBefore(date))
        .toList();
  }
}
