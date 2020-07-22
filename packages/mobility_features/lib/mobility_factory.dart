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
  bool _useInterpolation = true;

  set useInterpolation(bool value) {
    _useInterpolation = value;
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
      print('Loaded ${_cluster.length} location samples from disk');
    if (_stops.isNotEmpty) print('Loaded ${_stops.length} stops from disk');
    if (_moves.isNotEmpty) print('Loaded ${_moves.length} moves from disk');

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

  /// Call-back method for handling incoming [LocationSample]s
  void _onData(LocationSample sample) {
    /// If not previous stops, make a placeholder stop
    if (_stops.isEmpty) {
      if (_stops.isEmpty) {
        Stop s = Stop._fromLocationSamples([sample]);
        _stops.add(s);
      }
    }

    /// If previous samples exist, check if we should compute anything
    if (_cluster.isNotEmpty) {
      /// If previous sample was on a different date
      if (_cluster.last.datetime.midnight != sample.datetime.midnight) {
        _serializerStops.flush();
        _serializerMoves.flush();
        _createStopAndResetCluster();
      }

      /// If previous sample was today
      else {
        /// Compute median location of the collected samples
        GeoLocation centroid = _computeCentroid(_cluster);

        /// If the new data point is far away from cluster, make stop
        if (Distance.fromGeospatial(centroid, sample) > _stopRadius) {
          if (_useInterpolation) {
            print('${_cluster.last}, $sample');
            Duration delta = _delta(_cluster.last, sample);

            /// If it has been more than 1 hour since the last sample,
            /// create an interpolated sample
            if (delta > Duration(hours: 1)) {
              DateTime dt = sample.datetime.subtract(Duration(seconds: 1));
              GeoLocation lastLoc = _cluster.last.geoLocation;
              LocationSample interpolated = LocationSample(lastLoc, dt);
              print('created point: $interpolated');
              _cluster.add(interpolated);
            }
          }
          _createStopAndResetCluster();
        }
      }
    }
    _addToBuffer(sample);
    _cluster.add(sample);
  }

  Duration _delta(LocationSample first, LocationSample last) {
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

  /// Converts the cluster into a stop, i.e. closing the cluster
  void _createStopAndResetCluster() {
    Stop s = Stop._fromLocationSamples(_cluster);

    /// If the stop is too short, it is discarded
    /// Otherwise compute a context and send it via the stream
    if (s.duration >= _stopDuration) {
      _stops.add(s);

      /// Find places
      _places = _findPlaces(_stops);

      Move m;
      if (_stops.last.placeId == s.placeId) {
        /// Compute the move between the two stops using the path of samples
        final path = _prevCluster + _cluster;
        m = Move._fromPath(_stops.last, s, path);
      } else {
        /// Compute the move between the two stops using a straight line
        m = Move._fromStops(_stops.last, s);
      }
      _moves.add(m);

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

    /// Reset the cluster
    _prevCluster = _cluster;
    _cluster = [];

    /// Reset samples
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
