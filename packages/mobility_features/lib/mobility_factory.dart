part of mobility_features;

class MobilityFactory {
  double _stopRadius = 5,
      _placeRadius = 50;
  Duration _stopDuration = const Duration(minutes: 3);

  StreamSubscription<LocationSample> _subscription;
  _MobilitySerializer<LocationSample> _serializerSamples;
  _MobilitySerializer<Stop> _serializerStops;
  _MobilitySerializer<Move> _serializerMoves;
  List<Stop> _stops = [];
  List<Move> _moves = [];
  List<Place> _places = [];
  List<LocationSample> _cluster = [],
      _prevCluster = [],
      _buffer = [];
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
    if (_moves.isNotEmpty) {
      _moves = _moves.where((element) => element.duration > Duration(seconds: 10)).toList();
    }

    for (var s in _stops)
      print(s);

    if (_stops.isNotEmpty) {
      /// Only keeps stops and moves from the last known date
      DateTime date = _stops.last.datetime.midnight;
      _stops = _getElementsForDate(_stops, date);
      _moves = _getElementsForDate(_moves, date);
      _places = _findPlaces(_stops, placeRadius: _placeRadius);

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

  void _adjustSaveRate() {
    final now = DateTime.now();

    /// If night hours, increase saving rate
    if (22 <= now.hour && 8 <= now.hour) {
      _saveEvery = 1;
    }
  }

  /// Call-back method for handling incoming [LocationSample]s
  void _onData(LocationSample sample) {
    _adjustSaveRate();

    /// If no previous stops, make the sample into a placeholder stop
    if (_stops.isEmpty) {
      Stop s = Stop._fromLocationSamples([sample]);
      _stops.add(s);
    }
    else {
      /// If previous samples exist, check if we should compute anything
      if (_cluster.isNotEmpty) {
        /// If previous sample was on a different date, reset everything
        if (_cluster.last.datetime.midnight != sample.datetime.midnight) {
          _createStopAndResetCluster();
          _clearEverything();
        }

        /// If previous sample was today
        else {
          /// Compute median location of the collected samples
          GeoLocation centroid = _computeCentroid(_cluster);

          /// If the new data point is far away from cluster, make stop
          if (Distance.fromGeospatial(centroid, sample) > _stopRadius) {
            _createStopAndResetCluster();
          }
        }
      }
      _addToBuffer(sample);
      _cluster.add(sample);
    }
  }

  void _clearEverything() {
    print('cleared');
    _serializerStops.flush();
    _serializerMoves.flush();
    _stops = [];
    _moves = [];
    _places = [];
    _cluster = [];
    _buffer = [];
  }

  Duration _delta(_Timestamped first, _Timestamped last) {
    int ms = last.datetime.millisecondsSinceEpoch -
        first.datetime.millisecondsSinceEpoch;
    return Duration(milliseconds: ms);
  }

  /// Save a sample to the buffer and store samples on disk if buffer overflows
  void _addToBuffer(LocationSample sample) {
    _buffer.add(sample);
    if (_buffer.length >= _saveEvery) {
      _serializerSamples.save(_buffer);
      print('Stored buffer to disk');
      _buffer = [];
    }
  }

  /// Merge last two stops, and recompute places
  /// if they belong to the same place
  void mergeStops() {
    if (_stops.length < 2) return;
    Stop a = _stops[_stops.length - 2];
    Stop b = _stops[_stops.length - 1];

    if (a.placeId == b.placeId) {
      Duration d = _delta(a, b);
      if (d > Duration(minutes: 30)) {
        double lat = (a.geoLocation.latitude + b.geoLocation.latitude) / 2;
        double lon = (a.geoLocation.longitude + b.geoLocation.longitude) / 2;
        GeoLocation mean = GeoLocation(lat, lon);
        Stop s = Stop._(mean, a.arrival, b.departure);
        _stops.removeLast();
        _stops.removeLast();
        _stops.add(s);

        _places = _findPlaces(_stops);
      }
    }
  }

  /// Converts the cluster into a stop, i.e. closing the cluster
  void _createStopAndResetCluster() {
    Stop s = Stop._fromLocationSamples(_cluster);

    /// If the stop is too short, it is discarded
    /// Otherwise compute a context and send it via the stream
    if (s.duration >= _stopDuration) {
      Stop stopPrev = _stops.last;

      _stops.add(s);

      /// Find places
      _places = _findPlaces(_stops);

      /// Merge stops and recompute places
      mergeStops();

      Move m;
      if (_stops.last.placeId == s.placeId) {
        /// Compute the move between the two stops using the path of samples
        final path = _prevCluster + _cluster;
        m = Move._fromPath(stopPrev, s, path);
      } else {
        /// Compute the move between the two stops using a straight line
        m = Move._fromStops(stopPrev, s);
      }
      if (m.duration > Duration(seconds: 10)) {
        print('Found move');
        _moves.add(m);
      }

      /// Extract date
      DateTime date = _cluster.last.datetime.midnight;

      /// Compute features
      MobilityContext context =
      MobilityContext._(_stops, _places, _moves, date);
      _streamController.add(context);

      /// Store to disk
      _serializerStops.save([s]);
      _serializerMoves.save([m]);
    }

    /// Reset samples etc
    _prevCluster = _cluster;
    _cluster = [];
    _serializerSamples.flush();
    _buffer = [];
  }

  /// Configure the Stop-duration for the Stop algorithm
  set stopDuration(Duration value) {
    _stopDuration = value;
  }

  /// Configure the Stop-radius for the Stop algorithm
  set stopRadius(double value) {
    _stopRadius = value;
  }

  /// Configure the Stop-radius for the Place algorithm
  set placeRadius(value) {
    _placeRadius = value;
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

  static List<_Timestamped> _getElementsForDate(List<_Timestamped> elements,
      DateTime date) {
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
