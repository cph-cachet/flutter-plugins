part of mubs_background_location;

class LocationManager {
  ReceivePort port = ReceivePort();

  String logStr = '';

  LocationDto lastLocation;
  DateTime lastTimeLocation;

  Stream<LocationDto> _dtoStream;

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

  Future<void> start() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    print('Initialization done');
//    final _isRunning = await BackgroundLocator.isRegisterLocationUpdate();

    if (await _checkLocationPermission()) {
      _startLocator();
    } else {
      // show error
    }
  }

  Future<void> stop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
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
          notificationChannelName: "MUBSLocationService",
          notificationTitle: "MUBS",
          notificationMsg: "MUBS is tracking your location",
          wakeLockTime: 20,
          autoStop: false,
          distanceFilter: 0,
          interval: 1),
    );
  }
}
