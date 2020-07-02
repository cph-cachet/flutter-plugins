part of mobility_features;

class ContextGenerator {
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
      path = 'test/data';
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
    List<LocationSample> samples = await (await _locationSampleSerializer).load();
    return samples;
  }

  static Future<MobilityContext> generate(
      {bool usePriorContexts: false, DateTime today}) async {
    /// Init serializers
    _MobilitySerializer<LocationSample> sampleSerializer =
    await _locationSampleSerializer;
    _MobilitySerializer<Stop> stopSerializer =
    _MobilitySerializer<Stop>._(await _file(STOPS));
    _MobilitySerializer<Move> moveSerializer =
    _MobilitySerializer<Move>._(await _file(MOVES));

    /// Load data from disk
    List<LocationSample> samplesToday = await sampleSerializer.load();

    // Define today as the midnight time
    today = today ?? DateTime.now();
    today = today.midnight;

    // Filter out old samples
    samplesToday = _filterSamples(samplesToday, today);

    // Filter out todays stops, and stops older than 28 days
    List<Stop> stopsHist = await stopSerializer.load();
    List<Move> movesHist = await moveSerializer.load();
    stopsHist = _stopsHistoric(stopsHist, today);
    movesHist = _movesHistoric(movesHist, today);

    /// Recompute stops and moves today and add them
    List<Stop> stopsToday = _findStops(samplesToday, today);
    List<Move> movesToday = _findMoves(samplesToday, stopsToday);

    List<Stop> stopsAll = stopsHist + stopsToday;
    List<Move> movesAll = movesHist + movesToday;

    /// Find places for the period
    List<Place> placesAll = _findPlaces(stopsAll);

    /// Save Stops and Moves to disk
    stopSerializer.flush();
    moveSerializer.flush();
    stopSerializer.save(stopsAll);
    moveSerializer.save(movesAll);

    /// Find prior contexts, if prior is not chosen just leave empty
    List<MobilityContext> priorContexts = [];

    /// If Prior is chosen, compute mobility contexts for each previous date.
    if (usePriorContexts) {
      Set<DateTime> dates = stopsHist.map((s) => s.arrival.midnight).toSet();
      for (DateTime date in dates) {
        List<Stop> stopsOnDate = _stopsForDate(stopsHist, date);
        List<Move> movesOnDate = _movesForDate(movesHist, date);
        MobilityContext mc =
        MobilityContext._(stopsOnDate, placesAll, movesOnDate, date: date);
        priorContexts.add(mc);
      }
    }

    return MobilityContext._(stopsToday, placesAll, movesToday,
        contexts: priorContexts, date: today);
  }

  static List<LocationSample> _filterSamples(
      List<LocationSample> X, DateTime date) {
    return X.where((x) => x.datetime.midnight == date).toList();
  }

  static List<Stop> _stopsForDate(List<Stop> stops, DateTime date) {
    return stops.where((x) => x.arrival.midnight == date).toList();
  }

  static List<Move> _movesForDate(List<Move> moves, DateTime date) {
    return moves.where((x) => x.stopFrom.arrival.midnight == date).toList();
  }

  static List<Stop> _stopsHistoric(List<Stop> stops, DateTime date) {
    DateTime fourWeeksPrior = date.subtract(Duration(days: 28));
    return stops
        .where((x) =>
    x.arrival.midnight.isBefore(date) &&
        x.arrival.midnight.isAfter(fourWeeksPrior))
        .toList();
  }

  static List<Move> _movesHistoric(List<Move> moves, DateTime date) {
    DateTime fourWeeksPrior = date.subtract(Duration(days: 28));
    return moves
        .where((x) =>
    x.stopFrom.arrival.midnight.isBefore(date) &&
        x.stopFrom.arrival.midnight.isAfter(fourWeeksPrior))
        .toList();
  }
}
