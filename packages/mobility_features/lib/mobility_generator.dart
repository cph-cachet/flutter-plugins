part of mobility_features;

class MobilityFactory {
  static const String _LOCATION_SAMPLES_FILE = 'location_samples',
      _STOPS_FILE = 'stops',
      _MOVES_FILE = 'moves';

  bool _usePriorContexts = false;
  double _placeRadius = 50;
  double _stopRadius = 25;
  Duration _stopDuration = const Duration(minutes: 3);

  MobilityFactory._();

  static final MobilityFactory _instance = MobilityFactory._();

  static MobilityFactory get instance => _instance;

  Stream<LocationSample> _stream;

  set locationStream(Stream<LocationSample> stream) {
    _stream = stream;
    _stream.listen(_onData);
  }

  void _onData(LocationSample sample) {
    saveSamples([sample]);
  }

  set usePriorContexts(bool value) {
    _usePriorContexts = value;
  }

  set placeRadius(double value) {
    _placeRadius = value;
  }

  set stopDuration(Duration value) {
    _stopDuration = value;
  }

  set stopRadius(double value) {
    _stopRadius = value;
  }

  Future<File> _file(String type) async {
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

  Future<_MobilitySerializer<LocationSample>>
      get _locationSampleSerializer async =>
          _MobilitySerializer<LocationSample>._(
              await _file(_LOCATION_SAMPLES_FILE));

  Future<void> saveSamples(List<LocationSample> samples) async {
    (await _locationSampleSerializer).save(samples);
  }

  Future<List<LocationSample>> loadSamples() async {
    List<LocationSample> samples =
        await (await _locationSampleSerializer).load();
    return samples;
  }

  Future<MobilityContext> computeFeatures({DateTime date}) async {
    /// Init serializers
    _MobilitySerializer<LocationSample> sampleSerializer =
        await _locationSampleSerializer;
    _MobilitySerializer<Stop> stopSerializer =
        _MobilitySerializer<Stop>._(await _file(_STOPS_FILE));
    _MobilitySerializer<Move> moveSerializer =
        _MobilitySerializer<Move>._(await _file(_MOVES_FILE));

    // Define today as today if it is not defined
    date = date ?? DateTime.now();

    // Set date to midnight 00:00
    date = date.midnight;

    // Filter out stops/moves older than 28 days
    List<Stop> stops = await stopSerializer.load();
    List<Move> moves = await moveSerializer.load();
    stops = _filterStops(stops, date);
    moves = _filterMoves(moves, date);

    /// Load samples from disk, sort by datetime
    List<LocationSample> samples = await sampleSerializer.load();
    samples.sort((a, b) => a.datetime.compareTo(b.datetime));

    // Find the dates of the stored samples
    List<DateTime> sampleDates =
        samples.map((e) => e.datetime.midnight).toSet().toList();

    // Group the samples by date
    List<List<LocationSample>> groupedSamples = sampleDates
        .map((d) => samples.where((e) => e.datetime.midnight == d).toList())
        .toList();

    // Find stops and moves for each date
    for (List<LocationSample> samplesOnDate in groupedSamples) {
      List<Stop> stopsOnDate = _findStops(samplesOnDate,
          stopRadius: _stopRadius, stopDuration: _stopDuration);
      List<Move> movesOnDate = _findMoves(samplesOnDate, stopsOnDate);
      stops += stopsOnDate;
      moves += movesOnDate;
    }

    /// Find places for the period
    List<Place> places = _findPlaces(stops, placeRadius: _placeRadius);

    /// Save Stops and Moves to disk
    stopSerializer.flush();
    moveSerializer.flush();
    sampleSerializer.flush();

    // Extract stops and moves from today
    List<Stop> stopsToday = _stopsForDate(stops, date);
    List<Move> movesToday = _movesForDate(moves, date);
    List<LocationSample> samplesToday = _samplesForDate(samples, date);

    // Save
    sampleSerializer.save(samplesToday);
    stopSerializer.save(stops);
    moveSerializer.save(moves);

    /// Find prior contexts, if prior is not chosen just leave empty
    List<MobilityContext> priorContexts = [];

    /// If Prior is chosen, compute mobility contexts for each previous date.
    if (_usePriorContexts) {
      // Get the dates of the stored stops, exclude today
      Set<DateTime> dates = stops.map((s) => s.arrival.midnight).toSet();
      dates.remove(date);

      // Get the stops and moves for each date
      for (DateTime dateHist in dates) {
        List<Stop> stopsOnDate = _stopsForDate(stops, dateHist);
        List<Move> movesOnDate = _movesForDate(moves, dateHist);

        // If there are any stops, make a MobilityContext object with no prior contexts
        if (stopsOnDate.length > 0) {
          MobilityContext mc =
              MobilityContext._(stopsOnDate, places, movesOnDate, [], dateHist);
          priorContexts.add(mc);
        }
      }
    }

    // Make a MobilityContext for today, use the prior Contexts
    // (the array may be empty)
    return MobilityContext._(
        stopsToday, places, movesToday, priorContexts, date);
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
