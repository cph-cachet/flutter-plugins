part of mobility_features;

class MobilityFactory {
  bool _usePriorContexts = false;
  double _placeRadius = 20;
  double _stopRadius = 5;
  Duration _stopDuration = const Duration(minutes: 3);
  Duration _moveDuration = const Duration(seconds: 1);

  StreamSubscription<LocationSample> _subscription;
  _MobilitySerializer<LocationSample> _serializerSamples;
  _MobilitySerializer<Stop> _serializerStops;
  _MobilitySerializer<Move> _serializerMoves;
  List<Stop> _stops = [];
  List<Move> _moves = [];
  List<Place> _places = [];
  List<LocationSample> _cluster = [], _prevCluster = [], _buffer = [];
  Stop _stopPrev;
  LocationSample _samplePrev;
  int _saveEvery = 10;

  /// Outgoing stream
  StreamController<MobilityContext> _streamController =
      StreamController<MobilityContext>.broadcast();

  Stream<MobilityContext> get contextStream => _streamController.stream;

  /// Private constructor
  MobilityFactory._();

  /// Private Singleton field
  static final MobilityFactory _instance = MobilityFactory._();

  /// Public getter for the Singleton instance
  static MobilityFactory get instance => _instance;

  /// Listen to a Stream of [LocationSample]
  /// The subscription will be stored as a [StreamSubscription]
  /// which may be cancelled later
  Future startListening(Stream<LocationSample> s) async {
    await _handleInit();

    if (_subscription != null) {
      await _subscription.cancel();
    }
    _subscription = s.listen(_onData);
  }

  Future<void> _handleInit() async {
    _serializerSamples =
        _serializerSamples = _MobilitySerializer<LocationSample>();
    _serializerStops = _MobilitySerializer<Stop>();
    _serializerMoves = _MobilitySerializer<Move>();

    _stops = await _serializerStops.load();
    _moves = await _serializerMoves.load();
    _cluster = await _serializerSamples.load();
    _stops = uniqueElements(_stops);
    _moves = uniqueElements(_moves);

    if (_cluster.isNotEmpty)
      print('Loaded ${_cluster.length} location samples from disk');
    if (_stops.isNotEmpty) print('Loaded ${_stops.length} stops from disk');
    if (_moves.isNotEmpty) print('Loaded ${_moves.length} moves from disk');

    if (_stops.isNotEmpty) {
      /// Only keeps stops and moves from the last known date
      DateTime date = _stops.last.datetime.midnight;
      _stops = _getElementsForDate(_stops, date);
      _moves = _getElementsForDate(_moves, date);
      _places = _findPlaces(_stops);

      for (var s in _stops) print(s);
      for (var m in _moves) print(m);

      /// Compute features
      MobilityContext context =
          MobilityContext._(_stops, _places, _moves, date);
      _streamController.add(context);
    }
  }

  /// Cancel the [StreamSubscription]
  Future stopListening() async {
    if (_subscription != null) {
      await _subscription.cancel();
    }
  }

  /// Call-back method for handling incoming [LocationSample]s
  void _onData(LocationSample sample) {
    /// Load stops and moves on disk, perhaps the app was just closed
    if (_stopPrev == null) {
      _initStops(sample);
    }

    /// Check if previous sample was on a different date, i.e. at midnight when
    /// dates change, compute features with the existing cluster
    if (_samplePrev != null) {
      if (_samplePrev.datetime.midnight != sample.datetime.midnight) {
        _serializerStops.flush();
        _serializerMoves.flush();
        _serializerSamples.flush();
        _createStopAndResetCluster();
      }
    }

    if (_cluster.isNotEmpty) {
      /// Compute median location of the collected samples
      GeoLocation centroid = _computeCentroid(_cluster);

      /// If the new data point is far away from the centroid,
      /// convert the cluster to a stop.
      if (Distance.fromGeospatial(centroid, sample) > _stopRadius) {
        _createStopAndResetCluster();
      }
    }
    _addToBuffer(sample);
    _cluster.add(sample);
    _samplePrev = sample;
  }

  /// Save a sample to the buffer and store samples on disk if buffer overflows
  void _addToBuffer(LocationSample sample) {
    _buffer.add(sample);
    bool overflow = _buffer.length >= _saveEvery;
    if (overflow) {
      _serializerSamples.save(_buffer);
      print('Stored buffer to disk');
      _buffer = [];
    }
  }

  void _initStops(LocationSample sample) {
    /// Check if any stops and moves have been stored today on disk.
    /// If no stops are saved, make a stop with the current sample.
    /// Otherwise use the last saved stop.
    if (_stops.isEmpty) {
      Stop s = Stop._fromLocationSamples([sample]);
      _stops.add(s);
      _stopPrev = s;
    } else {
      _stopPrev = _stops.last;
    }
  }

  void _createStopAndResetCluster() {
    Stop s = Stop._fromLocationSamples(_cluster);

    /// If the stop is too short, it is discarded
    if (s.duration >= _stopDuration) {
      _computeContext(s);
    }

    /// Reset the cluster
    _prevCluster = _cluster;
    _cluster = [];
  }

  void _computeContext(Stop s) {
    _stops.add(s);

    /// Find places
    _places = _findPlaces(_stops);

    /// Compute the move between the two stops using the path of samples
    final path = _prevCluster + _cluster;
    Move m = Move._fromPath(_stopPrev, s, path);
    _moves.add(m);

    /// Extract date
    DateTime date = _cluster.last.datetime.midnight;

    /// Compute features
    MobilityContext context = MobilityContext._(_stops, _places, _moves, date);
    _streamController.add(context);

    /// TODO: Store to disk
    _serializerStops.save([s]);
    _serializerMoves.save([m]);

    /// Update previous stop
    _stopPrev = s;
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

  /// Configure the move duration, used for filtering noisy moves.
  set moveDuration(Duration value) {
    _moveDuration = value;
  }

  Future<_MobilitySerializer<LocationSample>>
      get _locationSampleSerializer async {
    if (_serializerSamples == null) {
      _serializerSamples = _MobilitySerializer<LocationSample>();
    }
    return _serializerSamples;
  }

  Future<void> saveSamples(List<LocationSample> samples) async {
    final serializer = await _locationSampleSerializer;
    serializer.save(samples);
  }

  Future<List<LocationSample>> loadSamples() async {
    final serializer = await _locationSampleSerializer;
    return await serializer.load();
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
