part of mobility_features;

class MobilityFactory {
  bool _usePriorContexts = false;
  double _placeRadius = 50;
  double _stopRadius = 25;
  Duration _stopDuration = const Duration(minutes: 3);
  Duration _moveDuration = const Duration(seconds: 1);
  int _saveEvery = 10;
  List<LocationSample> _buffer = [];
  StreamSubscription<LocationSample> _subscription;
  _MobilitySerializer<LocationSample> _serializerSamples;
  _MobilitySerializer<Stop> _serializerStops;
  _MobilitySerializer<Move> _serializerMoves;

  /// Private constructor
  MobilityFactory._();

  /// Private Singleton field
  static final MobilityFactory _instance = MobilityFactory._();

  /// Public getter for the Singleton instance
  static MobilityFactory get instance => _instance;

  /// Listen to a Stream of [LocationSample]
  /// The subscription will be stored as a [StreamSubscription]
  /// which may be cancelled later
  Future startListening(Stream<LocationSample> stream) async {
    if (_subscription != null) {
      await _subscription.cancel();
    }
    _subscription = stream.listen(_onData);
  }

  /// Cancel the [StreamSubscription]
  Future stopListening() async {
    if (_subscription != null) {
      await _subscription.cancel();
    }
  }

  /// Call-back method for handling incoming [LocationSample]s
  void _onData(LocationSample sample) async {
    _buffer.add(sample);
    // If buffer is exceeded, store it to disk and empty it
    if (_buffer.length >= _saveEvery) {
      await saveSamples(_buffer);
      _buffer = [];
    }
  }

  /// Configure whether or not to use prior contexts
  /// Prior contexts are necessary to compute the Routine Index feature
  set usePriorContexts(bool value) {
    _usePriorContexts = value;
  }

  /// Configure the Place-radius for the Place algorithm
  set placeRadius(double value) {
    _placeRadius = value;
  }

  /// Configure the Stop-duration for the Stop algorithm
  set stopDuration(Duration value) {
    _stopDuration = value;
  }

  /// Configure the Stop-radius for the Stop algorithm
  set stopRadius(double value) {
    _stopRadius = value;
  }

  set moveDuration(Duration value) {
    _moveDuration = value;
  }

  /// Configure the buffer size for the streamed data.
  /// When the buffer is full the buffer is stored to disk.
  /// A smaller buffer size means data is stored more frequently,
  /// which decreases the chance of losing data. However this comes at
  /// the cost of an increased compute-overhead used for storing data.
  set saveEvery(int value) {
    _saveEvery = value;
  }

  Future<_MobilitySerializer<LocationSample>>
      get _locationSampleSerializer async {
    if (_serializerSamples == null) {
      _serializerSamples = _MobilitySerializer<LocationSample>();
    }
    return _serializerSamples;
  }

  Future<_MobilitySerializer<Stop>> get _stopSerializer async {
    if (_serializerStops == null) {
      _serializerStops = _MobilitySerializer<Stop>();
    }
    return _serializerStops;
  }

  Future<_MobilitySerializer<Move>> get _moveSerializer async {
    if (_serializerMoves == null) {
      _serializerMoves = _MobilitySerializer<Move>();
    }
    return _serializerMoves;
  }

  Future<void> saveSamples(List<LocationSample> samples) async {
    final serializer = await _locationSampleSerializer;
    serializer.save(samples);
  }

  Future<List<LocationSample>> loadSamples() async {
    final serializer = await _locationSampleSerializer;
    return await serializer.load();
  }

  static List<MobilityContext> _priorContexts(bool usePriorContexts,
      DateTime date, List<Stop> stops, List<Move> moves, List<Place> places) {
    // Find prior contexts, if prior is not chosen just leave empty
    List<MobilityContext> priorContexts = [];

    /// If Prior is chosen, compute mobility contexts for each previous date.
    if (usePriorContexts) {
      // Get the dates of the stored stops, exclude today
      Set<DateTime> dates = stops.map((s) => s.arrival.midnight).toSet();
      dates.remove(date);

      // Get the stops and moves for each date
      for (DateTime d in dates) {
        List<Stop> stopsOnDate = _getElementsForDate(stops, d);
        List<Move> movesOnDate = _getElementsForDate(moves, d);

        // If there are any stops, make a MobilityContext object with no prior contexts
        if (stopsOnDate.length > 0) {
          MobilityContext mc =
              MobilityContext._(stopsOnDate, places, movesOnDate, [], d);
          priorContexts.add(mc);
        }
      }
    }
    return priorContexts;
  }

  /// Async computation using isolates
  Future<MobilityContext> computeFeatures({DateTime date}) async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_asyncComputation, receivePort.sendPort);
    SendPort sendPort = await receivePort.first;

    /// Init serializers
    final sampleSerializer = await _locationSampleSerializer;
    final stopSerializer = await _stopSerializer;
    final moveSerializer = await _moveSerializer;

    /// Define today as today if it is not defined
    date = date ?? DateTime.now();

    /// Set date to midnight 00:00
    date = date.midnight;

    /// Load saved stops and moves
    List<Stop> loadedStops = await stopSerializer.load();
    List<Move> loadedMoves = await moveSerializer.load();

    /// Filter out stops/moves older than 28 days as well as
    /// elements on the current date, if current date is the most recent date,
    /// i.e. data is still being collected on that date
    final filteredStops = _getRecentHistoricalElements(loadedStops, date);
    final filteredMoves = _getRecentHistoricalElements(loadedMoves, date);

    /// Load samples from disk, sort by datetime
    List<LocationSample> samples = await sampleSerializer.load();
    samples.sort((a, b) => a.datetime.compareTo(b.datetime));

    /// Find the dates of the stored samples from today or earlier
    /// Not in the future (only relevant if computed old features)
    List<DateTime> sampleDates =
        samples.map((e) => e.datetime.midnight).toSet().toList();

    List<List<LocationSample>> groupedSamples = sampleDates
        .map((d) => samples.where((e) => e.datetime.midnight == d).toList())
        .toList();

    /// Prepare arguments for async computation
    Map arguments = {
      'groupedSamples': groupedSamples,
      'stops': filteredStops,
      'moves': filteredMoves,
      '_stopRadius': _stopRadius,
      '_stopDuration': _stopDuration,
      '_moveDuration': _moveDuration,
      '_placeRadius': _placeRadius,
      '_usePriorContexts': _usePriorContexts,
      'date': date,
    };

    /// Off-load computation to background and await results
    List results = await offloadToBackground(sendPort, arguments);

    /// Extract results from async computation
    MobilityContext context = results[0];
    List<Stop> allStops = results[1];
    List<Move> allMoves = results[2];

    /// Keep the location data from the last known date
    /// since more data may be coming in later
    List<LocationSample> samplesToKeep =
        groupedSamples.isNotEmpty ? groupedSamples.last : [];
    sampleSerializer.flush();
    sampleSerializer.save(samplesToKeep);

    /// Save Stops and Moves to disk
    stopSerializer.flush();
    moveSerializer.flush();

    /// Save stops and moves
    stopSerializer.save(allStops);
    moveSerializer.save(allMoves);

    /// Make a MobilityContext for today, use the prior MobilityContexts
    return context;
  }

  /// Off-loads the arguments to background
  Future offloadToBackground(SendPort sendPort, Map args) {
    ReceivePort receivePort = ReceivePort();
    args['replyPort'] = receivePort.sendPort;
    sendPort.send(args);
    return receivePort.first;
  }

  static void _asyncComputation(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    Map args = await receivePort.first;
    SendPort replyPort = args['replyPort'];
    final groupedSamples = args['groupedSamples'];
    List<Stop> stops = args['stops'];
    List<Move> moves = args['moves'];
    double _stopRadius = args['_stopRadius'];
    Duration _stopDuration = args['_stopDuration'];
    Duration _moveDuration = args['_moveDuration'];
    double _placeRadius = args['_placeRadius'];
    bool _usePriorContexts = args['_usePriorContexts'];
    DateTime date = args['date'];

    // Find stops and moves for each date
    for (List<LocationSample> samplesOnDate in groupedSamples) {
      final stopsOnDate = _findStops(samplesOnDate,
          stopRadius: _stopRadius, stopDuration: _stopDuration);
      final movesOnDate =
          _findMoves(samplesOnDate, stopsOnDate, moveDuration: _moveDuration);
      stops += stopsOnDate;
      moves += movesOnDate;
    }

    List<Stop> uniqueStops = timestampSet(stops);
    List<Move> uniqueMoves = timestampSet(moves);

    /// Find places for the period
    List<Place> places = _findPlaces(stops, placeRadius: _placeRadius);

    // Find prior contexts, if prior is not chosen just leave empty
    List<MobilityContext> priorContexts = _priorContexts(
        _usePriorContexts, date, uniqueStops, uniqueMoves, places);

    List<Stop> stopsToday = _getElementsForDate(uniqueStops, date);
    List<Move> movesToday = _getElementsForDate(uniqueMoves, date);

    MobilityContext mc =
        MobilityContext._(stopsToday, places, movesToday, priorContexts, date);

    replyPort.send([mc, uniqueStops, uniqueMoves, places]);
  }

  static List<_Timestamped> _getElementsForDate(
      List<_Timestamped> elements, DateTime date) {
    return elements.where((e) => e.datetime.midnight == date).toList();
  }

  static List<_Timestamped> _getRecentHistoricalElements(
      List<_Timestamped> elements, DateTime date) {
    DateTime fourWeeksPrior = date.subtract(Duration(days: 28));
    List<DateTime> dates =
        elements.map((e) => e.datetime.midnight).toSet().toList();

    List<_Timestamped> filtered = elements
        .where((e) => e.datetime.midnight.isAfter(fourWeeksPrior))
        .toList();

    /// If we are generating features from a previous date,
    /// don't filter dates out after it.
    if (dates.isNotEmpty && date == dates.last) {
      filtered =
          filtered.where((e) => e.datetime.midnight.isBefore(date)).toList();
    }

    return filtered;
  }

  static List<_Timestamped> timestampSet(List<_Timestamped> elements) {
    List<int> seen = [];

    elements.sort((a, b) => a.datetime.compareTo(b.datetime));

    return elements.where((e) {
      int ms = e.datetime.millisecondsSinceEpoch;
      if (!seen.contains(ms)) {
        seen.add(ms);
        return true;
      }
      return false;
    }).toList();
  }
}
