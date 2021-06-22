part of mobility_features;

/// Main entry for configuring and listening for mobility features.
/// Used as a singleton `MobilityFactory()`.
class MobilityFeatures {
  double _stopRadius = 5, _placeRadius = 50;
  Duration _stopDuration = const Duration(seconds: 20);

  StreamSubscription<LocationSample>? _subscription;
  _MobilitySerializer<LocationSample>? _serializerSamples;
  late _MobilitySerializer<Stop> _serializerStops;
  late _MobilitySerializer<Move> _serializerMoves;
  List<Stop> _stops = [];
  List<Move> _moves = [];
  List<Place> _places = [];
  List<LocationSample> _cluster = [], _buffer = [], _samples = [];
  int _saveEvery = 10;
  bool debug = false;

  void _print(dynamic x) {
    if (debug) {
      print(x);
    }
  }

  // Outgoing stream
  StreamController<MobilityContext> _streamController =
      StreamController<MobilityContext>.broadcast();

  Stream<MobilityContext> get contextStream => _streamController.stream;

  // Private constructor
  MobilityFeatures._();

  // Private Singleton field
  static final MobilityFeatures _instance = MobilityFeatures._();

  /// Public getter for the Singleton instance
  factory MobilityFeatures() => _instance;

  /// Listen to a Stream of [LocationSample].
  /// The subscription will be stored as a [StreamSubscription]
  /// which may be cancelled later.
  Future startListening(Stream<LocationSample> stream) async {
    await _handleInit();

    if (_subscription != null) {
      await _subscription!.cancel();
    }
    _subscription = stream.listen(_onData);
  }

  Future<void> _handleInit() async {
    _serializerSamples =
        _serializerSamples = _MobilitySerializer<LocationSample>();
    _serializerStops = _MobilitySerializer<Stop>();
    _serializerMoves = _MobilitySerializer<Move>();

    _stops = (await _serializerStops.load() as List<Stop>);
    _moves = (await _serializerMoves.load() as List<Move>);
    _cluster = (await _serializerSamples!.load() as List<LocationSample>);
    _stops = uniqueElements(_stops) as List<Stop>;
    _moves = uniqueElements(_moves) as List<Move>;

    if (_cluster.isNotEmpty)
      _print('Loaded ${_cluster.length} location samples from disk');
    if (_stops.isNotEmpty) {
      _print('Loaded ${_stops.length} stops from disk');
    }
    if (_moves.isNotEmpty) {
      _print('Loaded ${_moves.length} moves from disk');
    }

    for (var s in _stops) _print(s);

    if (_stops.isNotEmpty) {
      /// Only keeps stops and moves from the last known date
      DateTime date = _stops.last.datetime.midnight;
      _stops = _getElementsForDate(_stops, date) as List<Stop>;
      _moves = _getElementsForDate(_moves, date) as List<Move>;
      _places = _findPlaces(_stops, placeRadius: _placeRadius);

      // Compute features
      MobilityContext context =
          MobilityContext._(_stops, _places, _moves, date);
      _streamController.add(context);
    }
  }

  /// Cancel the [StreamSubscription] and stop listening.
  Future stopListening() async {
    if (_subscription != null) {
      await _subscription!.cancel();
    }
  }

  void _adjustSaveRate() {
    final now = DateTime.now();

    // If night hours, increase saving rate
    if (22 <= now.hour && 8 <= now.hour) {
      _saveEvery = 1;
    }
  }

  /// Call-back method for handling incoming [LocationSample]s
  void _onData(LocationSample sample) {
    _samples.add(sample);
    _adjustSaveRate();

    // If previous samples exist, check if we should compute anything
    if (_cluster.isNotEmpty) {
      // If previous sample was on a different date, reset everything
      if (_cluster.last.datetime.midnight != sample.datetime.midnight) {
        _createStopAndResetCluster();
        _clearEverything();
      }

      // If previous sample was today
      else {
        // Compute median location of the collected samples
        GeoLocation centroid = _computeCentroid(_cluster);

        // If the new data point is far away from cluster, make stop
        if (Distance.fromGeospatial(centroid, sample) > _stopRadius) {
          _createStopAndResetCluster();
        }
      }
    }
    _addToBuffer(sample);
    _cluster.add(sample);
  }

  void _clearEverything() {
    _print('cleared');
    _serializerStops.flush();
    _serializerMoves.flush();
    _stops = [];
    _moves = [];
    _places = [];
    _cluster = [];
    _buffer = [];
  }

  /// Save a sample to the buffer and store samples on disk if buffer overflows
  void _addToBuffer(LocationSample sample) {
    _buffer.add(sample);
    if (_buffer.length >= _saveEvery) {
      _serializerSamples!.save(_buffer);
      _print('Stored buffer to disk');
      _buffer = [];
    }
  }

  /// Converts the cluster into a stop, i.e. closing the cluster
  void _createStopAndResetCluster() {
    Stop s = Stop._fromLocationSamples(_cluster);

    // If the stop is too short, it is discarded
    // Otherwise compute a context and send it via the stream
    if (s.duration > _stopDuration) {
      _print('----> Stop found: $s');
      Stop? stopPrev = _stops.isNotEmpty ? _stops.last : null;

      _stops.add(s);

      // Find places
      _places = _findPlaces(_stops);

      // Merge stops and recompute places
      _stops = _mergeStops(_stops);
      _places = _findPlaces(_stops);

      // Store to disk
      _serializerStops.flush();
      _serializerStops.save(_stops);

      // Extract date
      DateTime date = _cluster.last.datetime.midnight;

      if (stopPrev != null) {
        _moves = _findMoves(_stops, _samples);
        _serializerMoves.flush();
        _serializerMoves.save(_moves);
      }

      // Compute features
      MobilityContext context =
          MobilityContext._(_stops, _places, _moves, date);
      _streamController.add(context);
    }

    // Reset samples etc
    _cluster = [];
    _serializerSamples!.flush();
    _buffer = [];
  }

  /// Configure the stop-duration for the stop algorithm
  set stopDuration(Duration value) {
    _stopDuration = value;
  }

  /// Configure the stop-radius for the stop algorithm
  set stopRadius(double value) {
    _stopRadius = value;
  }

  /// Configure the stop-radius for the place algorithm
  set placeRadius(value) {
    _placeRadius = value;
  }

  Future<_MobilitySerializer<LocationSample>>
      get _locationSampleSerializer async {
    if (_serializerSamples == null) {
      _serializerSamples = _MobilitySerializer<LocationSample>();
    }
    return _serializerSamples!;
  }

  Future<void> saveSamples(List<LocationSample> samples) async {
    final serializer = await _locationSampleSerializer;
    serializer.save(samples);
  }

  Future<List<LocationSample>> loadSamples() async {
    final serializer = await _locationSampleSerializer;
    return (await serializer.load() as List<LocationSample>);
  }

  static List<_Timestamped> _getElementsForDate(
      List<_Timestamped> elements, DateTime date) {
    return elements.where((e) => e.datetime.midnight == date).toList();
  }

  static List<_Timestamped> uniqueElements(List<_Timestamped> elements) {
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
