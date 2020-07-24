part of mobility_features;

class MobilityFactory {
  double _stopRadius = 5, _placeRadius = 50;
  Duration _stopDuration = const Duration(minutes: 3);

  StreamSubscription<LocationSample> _subscription;
  _MobilitySerializer<LocationSample> _serializerSamples;
  _MobilitySerializer<Stop> _serializerStops;
  _MobilitySerializer<Move> _serializerMoves;
  List<Stop> _stops = [];
  List<Move> _moves = [];
  List<Place> _places = [];
  List<LocationSample> _cluster = [], _prevCluster = [], _buffer = [];
  int _saveEvery = 10;
  bool debug = false;

  void _print(dynamic x) {
    if (debug) {
      print(x);
    }
  }

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
      _print('Loaded ${_cluster.length} location samples from disk');
    if (_stops.isNotEmpty) {
      _print('Loaded ${_stops.length} stops from disk');
      _stops = _mergeAllStops(_stops);
    }
    if (_moves.isNotEmpty) {
      _print('Loaded ${_moves.length} moves from disk');
      _moves = _moves
          .where((element) => element.duration > Duration(seconds: 10))
          .toList();
    }

    for (var s in _stops) _print(s);

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
      _serializerSamples.save(_buffer);
      _print('Stored buffer to disk');
      _buffer = [];
    }
  }

  List<Stop> _mergeAllStops(List<Stop> stops) {
    List<Stop> merged = [];
    if (stops.length < 2) return stops;

    /// Should be applied after places have been found
    List<Stop> toMerge = [];

    void _merge() {
      if (toMerge.isEmpty) return;
      GeoLocation geoLocation = _computeCentroid(toMerge);
      DateTime arr = toMerge.first.arrival;
      DateTime dep = toMerge.last.departure;
      Stop s = Stop._(geoLocation, arr, dep, placeId: toMerge.first.placeId);
      merged.add(s);
      _print('Merging output: ${merged.last}');
      toMerge = [];
    }

    for (Stop stop in stops) {
      /// If no stops to merge, we cannot merge and we therefore add the current
      /// stop and go to the next one
      if (toMerge.isEmpty) {
        toMerge.add(stop);
      }

      /// Otherwise check if we should add it or merge
      else {
        if (stop.placeId != toMerge.last.placeId) {
          _merge();
        }
        toMerge.add(stop);
      }
    }

    /// Merge remaining stops in the toMerge list
    _merge();
    return merged;
  }

  /// Converts the cluster into a stop, i.e. closing the cluster
  void _createStopAndResetCluster() {
    Stop s = Stop._fromLocationSamples(_cluster);

    /// If the stop is too short, it is discarded
    /// Otherwise compute a context and send it via the stream
    if (s.duration > _stopDuration) {
      _print('----> Stop found: $s');
      Stop stopPrev = _stops.isNotEmpty ? _stops.last : null;

      _stops.add(s);

      /// Find places
      _places = _findPlaces(_stops);

      /// Merge stops and recompute places
      _stops = _mergeAllStops(_stops);
      _places = _findPlaces(_stops);

      /// Store to disk
      _serializerStops.save([s]);

      /// Extract date
      DateTime date = _cluster.last.datetime.midnight;

      if (stopPrev != null) {
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
          _moves.add(m);
        }
        _serializerMoves.save([m]);
      }

      /// Compute features
      MobilityContext context =
          MobilityContext._(_stops, _places, _moves, date);
      _streamController.add(context);
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
