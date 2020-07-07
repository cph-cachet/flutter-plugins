part of mobility_features;

class MobilityFactory {
  bool _usePriorContexts = false;
  double _placeRadius = 50;
  double _stopRadius = 25;
  Duration _stopDuration = const Duration(minutes: 3);
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

  Future<MobilityContext> computeFeatures({DateTime date}) async {
    /// Init serializers
    final sampleSerializer = await _locationSampleSerializer;
    final stopSerializer = await _stopSerializer;
    final moveSerializer = await _moveSerializer;

    // Define today as today if it is not defined
    date = date ?? DateTime.now();

    // Set date to midnight 00:00
    date = date.midnight;

    // Filter out stops/moves older than 28 days
    List<Stop> stops = await stopSerializer.load();
    List<Move> moves = await moveSerializer.load();
    stops = _filterElements(stops, date);
    moves = _filterElements(moves, date);

    /// Load samples from disk, sort by datetime
    List<LocationSample> samples = await sampleSerializer.load();
    samples.sort((a, b) => a.datetime.compareTo(b.datetime));

    // Find the dates of the stored samples
    List<DateTime> sampleDates =
        samples.map((e) => e.datetime.midnight).toSet().toList();

    // Group the samples by date
    final groupedSamples = sampleDates
        .map((d) => samples.where((e) => e.datetime.midnight == d).toList())
        .toList();

    // Find stops and moves for each date
    for (List<LocationSample> samplesOnDate in groupedSamples) {
      final stopsOnDate = _findStops(samplesOnDate,
          stopRadius: _stopRadius, stopDuration: _stopDuration);
      final movesOnDate = _findMoves(samplesOnDate, stopsOnDate);
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
    List<Stop> stopsToday = _elementsForDate(stops, date);
    List<Move> movesToday = _elementsForDate(moves, date);
    List<LocationSample> samplesToday = _elementsForDate(samples, date);

    // Save
    sampleSerializer.save(samplesToday);
    stopSerializer.save(stops);
    moveSerializer.save(moves);

    /// Find prior contexts, if prior is not chosen just leave empty
    List<MobilityContext> contexts =
        _priorContexts(_usePriorContexts, date, stops, moves, places);

    // Make a MobilityContext for today, use the prior MobilityContexts
    return MobilityContext._(stopsToday, places, movesToday, contexts, date);
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
      for (DateTime dateHist in dates) {
        List<Stop> stopsOnDate = _elementsForDate(stops, dateHist);
        List<Move> movesOnDate = _elementsForDate(moves, dateHist);

        // If there are any stops, make a MobilityContext object with no prior contexts
        if (stopsOnDate.length > 0) {
          MobilityContext mc =
              MobilityContext._(stopsOnDate, places, movesOnDate, [], dateHist);
          priorContexts.add(mc);
        }
      }
    }
    return priorContexts;
  }

  Future<MobilityContext> computeStuff({DateTime date}) async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_asyncComputation, receivePort.sendPort);
    SendPort sendPort = await receivePort.first;

    /// Init serializers
    final sampleSerializer = await _locationSampleSerializer;
    final stopSerializer = await _stopSerializer;
    final moveSerializer = await _moveSerializer;

    // Define today as today if it is not defined
    date = date ?? DateTime.now();

    // Set date to midnight 00:00
    date = date.midnight;

    // Filter out stops/moves older than 28 days
    List<Stop> stops = await stopSerializer.load();
    List<Move> moves = await moveSerializer.load();
    stops = _filterElements(stops, date);
    moves = _filterElements(moves, date);

    /// Load samples from disk, sort by datetime
    List<LocationSample> samples = await sampleSerializer.load();
    samples.sort((a, b) => a.datetime.compareTo(b.datetime));

    // Find the dates of the stored samples
    List<DateTime> sampleDates =
        samples.map((e) => e.datetime.midnight).toSet().toList();

    // Group the samples by date
    final groupedSamples = sampleDates
        .map((d) => samples.where((e) => e.datetime.midnight == d).toList())
        .toList();

    // PERFORM ASYNC COMPUTATION
    List args = [
      groupedSamples,
      stops,
      moves,
      _stopRadius,
      _stopDuration,
      _placeRadius,
      _usePriorContexts,
      date
    ];
    List results = await relay(sendPort, args);

    // Extract results from async computation
    List<MobilityContext> contexts = results[0];
    List<Stop> stopsFinal = results[1];
    List<Move> movesFinal = results[2];
    List<Place> places = results[3];

    /// Save Stops and Moves to disk
    stopSerializer.flush();
    moveSerializer.flush();
    sampleSerializer.flush();

    // Extract stops and moves from today
    List<Stop> stopsToday = _elementsForDate(stopsFinal, date);
    List<Move> movesToday = _elementsForDate(movesFinal, date);
    List<LocationSample> samplesToday = _elementsForDate(samples, date);

    // Save
    sampleSerializer.save(samplesToday);
    stopSerializer.save(stopsFinal);
    moveSerializer.save(movesFinal);

    // Make a MobilityContext for today, use the prior MobilityContexts
    return MobilityContext._(stopsToday, places, movesToday, contexts, date);
  }

  Future relay(SendPort sendPort, List args) {
    ReceivePort receivePort = ReceivePort();
    List<dynamic> args2 = [];
    args2.add(receivePort.sendPort);
    args2.addAll(args);
    sendPort.send(args2);
    return receivePort.first;
  }

  static void _asyncComputation(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    List args = await receivePort.first;
    SendPort replyPort = args[0];
    final groupedSamples = args[1];
    List<Stop> stops = args[2];
    List<Move> moves = args[3];
    double _stopRadius = args[4];
    Duration _stopDuration = args[5];
    double _placeRadius = args[6];
    bool _usePriorContexts = args[7];
    DateTime date = args[8];

    // Find stops and moves for each date
    for (List<LocationSample> samplesOnDate in groupedSamples) {
      final stopsOnDate = _findStops(samplesOnDate,
          stopRadius: _stopRadius, stopDuration: _stopDuration);
      final movesOnDate = _findMoves(samplesOnDate, stopsOnDate);
      stops += stopsOnDate;
      moves += movesOnDate;
    }

    /// Find places for the period
    List<Place> places = _findPlaces(stops, placeRadius: _placeRadius);

    // Find prior contexts, if prior is not chosen just leave empty
    List<MobilityContext> priorContexts =
        _priorContexts(_usePriorContexts, date, stops, moves, places);

    replyPort.send([priorContexts, stops, moves, places]);
  }

  static List<_Timestamped> _elementsForDate(
      List<_Timestamped> elements, DateTime date) {
    return elements.where((e) => e.datetime.midnight == date).toList();
  }

  static List<_Timestamped> _filterElements(
      List<_Timestamped> elements, DateTime date) {
    DateTime fourWeeksPrior = date.subtract(Duration(days: 28));
    return elements
        .where((e) =>
            e.datetime.midnight.isAfter(fourWeeksPrior) &&
            e.datetime.midnight.isBefore(date))
        .toList();
  }
}
