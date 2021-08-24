part of carp_background_location;

/// Provide access to location data while the app is in the background.
///
/// Use as a singleton:
///
///  `LocationManager()...`
///
class LocationManager {
  ReceivePort _port = ReceivePort();
  Stream<LocationDto>? _locationStream;
  String _channelName = "BackgroundLocationChannel",
      _notificationTitle = "Background Location",
      _notificationMsg = "Your location is being tracked";

  int _interval = 1;
  double _distanceFilter = 0;
  LocationAccuracy _accuracy = LocationAccuracy.NAVIGATION;

  /// A stream of location data updates
  Stream<LocationDto> get locationStream {
    if (_locationStream == null) {
      Stream<dynamic> dataStream = _port.asBroadcastStream();
      _locationStream = dataStream
          .where((event) => event != null)
          .map((location) => location as LocationDto);
    }
    return _locationStream!;
  }

  /// Get the status of the location manager.
  /// Will return `true` if a location service is currently running.
  Future<bool> get isRunning async =>
      await BackgroundLocator.isRegisterLocationUpdate();

  static final LocationManager _instance = LocationManager._();

  /// Get the singleton [LocationManager] instance
  factory LocationManager() => _instance;

  LocationManager._() {
    // Check if the port is already used
    if (IsolateNameServer.lookupPortByName(
            LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    // Register the service to the port name
    IsolateNameServer.registerPortWithName(
        _port.sendPort, LocationServiceRepository.isolateName);
  }

  /// Get the current location.
  Future<LocationDto> getCurrentLocation() async {
    if (!await BackgroundLocator.isRegisterLocationUpdate()) {
      await start();
      LocationDto dto = await locationStream.first;
      stop();
      return dto;
    }
    return await locationStream.first;
  }

  /// Start the location service.
  /// Will have no effect if it is already running.
  Future<void> start({bool askForPermission: true}) async {
    await BackgroundLocator.initialize();

    if (askForPermission) {
      if (await _checkLocationPermission()) {
        _startLocator();
      }
    } else {
      _startLocator();
    }
  }

  /// Stop the location service.
  /// Has no effect if the service is not currently running.
  Future<void> stop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
  }

  /// Check whether or not location permissions have been granted.
  /// Location permissions are necessary for getting location updates.
  Future<bool> checkIfPermissionGranted() async {
    final access = await LocationPermissions().checkPermissionStatus();
    return (access == PermissionStatus.granted);
  }

  /// Checks the status of the location permission.
  /// The status can be either of these
  ///     - Unknown (i.e. has not been requested)
  ///     - Denied (i.e. no access)
  ///     - Restricted (i.e. only once/when app is in foreground)
  ///     - Always (i.e. works in the foreground and the background)
  Future<bool> _checkLocationPermission() async {
    final access = await LocationPermissions().checkPermissionStatus();
    switch (access) {
      case PermissionStatus.unknown:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await LocationPermissions().requestPermissions(
          permissionLevel: LocationPermissionLevel.locationAlways,
        );
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
      case PermissionStatus.granted:
        return true;
      default:
        return false;
    }
  }

  /// Starts the location service with the given parameters.
  void _startLocator() {
    BackgroundLocator.registerLocationUpdate(
      LocationCallbackHandler.callback,
      autoStop: false,
      androidSettings: AndroidSettings(
          accuracy: _accuracy,
          interval: _interval,
          distanceFilter: _distanceFilter,
          androidNotificationSettings: AndroidNotificationSettings(
            notificationChannelName: _channelName,
            notificationTitle: _notificationTitle,
            notificationMsg: _notificationMsg,
          )),
      iosSettings: IOSSettings(
        accuracy: _accuracy,
        distanceFilter: _distanceFilter,
      ),
    );
  }

  /// Set the title of the notification for the background service.
  /// Android only.
  set notificationTitle(value) => _notificationTitle = value;

  /// Set the message of the notification for the background service.
  /// Android only.
  set notificationMsg(value) => _notificationMsg = value;

  /// Set the update interval in seconds.
  /// Android only.
  set interval(int value) => _interval = value;

  /// Set the update distance, i.e. the distance the user needs to move
  /// before an update is fired.
  set distanceFilter(double value) => _distanceFilter = value;

  /// Set the update accuracy. See [LocationAccuracy] for options.
  set accuracy(LocationAccuracy value) => _accuracy = value;
}
