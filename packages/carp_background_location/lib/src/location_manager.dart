part of carp_background_location;

class LocationManager {
  ReceivePort port = ReceivePort();
  Stream<LocationDto> _dtoStream;
  String _channelName = "BackgroundLocationChannel",
      _notificationTitle = "Background Location",
      _notificationMsg = "Your location is being tracked";

  int _interval = 1;
  double _distanceFilter = 0;

  Stream<LocationDto> get dtoStream {
    if (_dtoStream == null) {
      Stream<dynamic> dataStream = port.asBroadcastStream();
      _dtoStream = dataStream.where((event) => event != null).map((e) {
        LocationDto dto = e as LocationDto;
        return dto;
      });
    }
    return _dtoStream;
  }
  Future<bool> get isRunning async =>
      await BackgroundLocator.isRegisterLocationUpdate();

  static final LocationManager _instance = LocationManager._();

  static LocationManager get instance => _instance;

  LocationManager._() {
    if (IsolateNameServer.lookupPortByName(
            LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);
  }

  Future<void> start({bool askForPermission: true}) async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    print('Initialization done');

    if (askForPermission) {
      if (await _checkLocationPermission()) {
        _startLocator();
      }
    } else {
      _startLocator();
    }
  }

  Future<void> stop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
  }

  Future<bool> checkIfPermissionGranted() async {
    final access = await LocationPermissions().checkPermissionStatus();
    return access == PermissionStatus.granted;
  }

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
        break;
      case PermissionStatus.granted:
        return true;
        break;
      default:
        return false;
        break;
    }
  }

  void _startLocator() {
    Map<String, dynamic> data = {'countInit': 1};
    BackgroundLocator.registerLocationUpdate(
      LocationCallbackHandler.callback,
      initCallback: LocationCallbackHandler.initCallback,
      initDataCallback: data,
      disposeCallback: LocationCallbackHandler.disposeCallback,
      androidNotificationCallback: LocationCallbackHandler.notificationCallback,
      settings: LocationSettings(
          notificationChannelName: _channelName,
          notificationTitle: _notificationTitle,
          notificationMsg: _notificationMsg,
          autoStop: false,
          distanceFilter: _distanceFilter,
          interval: _interval),
    );
  }

  set notificationTitle(value) {
    _notificationTitle = value;
  }

  set distanceFilter(double value) {
    _distanceFilter = value;
  }

  set interval(int value) {
    _interval = value;
  }

  set notificationMsg(value) {
    _notificationMsg = value;
  }
}
