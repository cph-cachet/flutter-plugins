part of movisens_flutter;

/// A representation of a Movisens device with services
///
/// It contains all the services that the movisens device provides
/// and the methods for handling device connection.
class MovisensDevice {
  late String macAddress;
  BluetoothDevice? _bluetoothDevice;

  /// Is the phone and app connected to the movisens device
  bool get isConnected => _bluetoothDevice != null;

  final Map<MovisensServiceTypes, MovisensService> _services = {};

  /// Get the [AmbientService] if the device supports it.
  /// Is null if not supported / discovered on device.
  AmbientService? get ambientService =>
      _services[MovisensServiceTypes.ambient] as AmbientService?;

  /// Get the [EdaService] if the device supports it.
  /// Is null if not supported / discovered on device.
  EdaService? get edaService =>
      _services[MovisensServiceTypes.eda] as EdaService?;

  /// Get the [HrvService] if the device supports it.
  /// Is null if not supported / discovered on device.
  HrvService? get hrvService =>
      _services[MovisensServiceTypes.hrv] as HrvService?;

  /// Get the [MarkerService] if the device supports it.
  /// Is null if not supported / discovered on device.
  MarkerService? get markerService =>
      _services[MovisensServiceTypes.marker] as MarkerService?;

  /// Get the [BatteryService] if the device supports it.
  /// Is null if not supported / discovered on device.
  BatteryService? get batteryService =>
      _services[MovisensServiceTypes.battery] as BatteryService?;

  /// Get the [UserDataService] if the device supports it.
  /// Is null if not supported / discovered on device.
  UserDataService? get userDataService =>
      _services[MovisensServiceTypes.userData] as UserDataService?;

  /// Get the [PhysicalActivityService] if the device supports it.
  /// Is null if not supported / discovered on device.
  PhysicalActivityService? get physicalActivityService =>
      _services[MovisensServiceTypes.physicalActivity]
          as PhysicalActivityService?;

  /// Get the [RespirationService] if the device supports it.
  /// Is null if not supported / discovered on device.
  RespirationService? get respirationService =>
      _services[MovisensServiceTypes.respiration] as RespirationService?;

  /// Get the [SensorControlService] if the device supports it.
  /// Is null if not supported / discovered on device.
  SensorControlService? get sensorControlService =>
      _services[MovisensServiceTypes.sensorControl] as SensorControlService?;

  /// Get the [SkinTemperatureService] if the device supports it.
  /// Is null if not supported / discovered on device.
  SkinTemperatureService? get skinTemperatureService =>
      _services[MovisensServiceTypes.skinTemperature]
          as SkinTemperatureService?;

  /// A Movisens bluetooth device.
  ///
  /// [macAddress] required to connect to a device.
  MovisensDevice({required this.macAddress});

  /// Connect to the movisens device using the [macAddress].
  /// Automatically discovers services on device and stores them.
  Future<void> connect() async {
    _log.info("Connecting to movisens device [$macAddress]");
    FlutterBluePlus flutterBluePlus = FlutterBluePlus.instance;
    // Checking if already connected - skips the rest of connect if true
    // TODO: If already connected - do we need to use `device.connect()` ?
    await flutterBluePlus.connectedDevices.then((connectedDevices) async {
      for (BluetoothDevice device in connectedDevices) {
        if (device.id.id == macAddress) {
          await device.connect();
          _bluetoothDevice = device;
          // Discover services
          await _discoverAndSetup();
          return;
        }
      }
    });

    // (For android) Check if the device is bonded
    // TODO: Sometimes pairing with the device can be necessary - consider implementing
    if (Platform.isAndroid) {
      List<BluetoothDevice> bondedDevices = await flutterBluePlus.bondedDevices;
      for (BluetoothDevice device in bondedDevices) {
        if (device.id.id == macAddress) {
          await device.connect();
          _bluetoothDevice = device;
          // Discover services
          await _discoverAndSetup();
          return;
        }
      }
    }

    // Scan for devices
    flutterBluePlus.startScan(
        timeout: const Duration(seconds: 10), macAddresses: [macAddress]);
    late StreamSubscription subscription;
    subscription = flutterBluePlus.scanResults.listen((scanResults) async {
      for (ScanResult scanResult in scanResults) {
        await scanResult.device.connect();
        // clean up streams
        await flutterBluePlus.stopScan();
        await subscription.cancel();
        _bluetoothDevice = scanResult.device;
        await _discoverAndSetup();
      }
    });
  }

  // Discovers services on device and instanciates them
  Future<void> _discoverAndSetup() async {
    _log.info("Discovering services on movisens device [$macAddress]");
    // Discover services
    late List<BluetoothService> services;
    await Future.delayed(const Duration(seconds: 1), () async {
      services = await _bluetoothDevice!.discoverServices();
    }); // TODO: Do we need the delay?

    // Setup services
    for (BluetoothService service in services) {
      String serviceUuid = service.uuid.toString();
      MovisensServiceTypes? serviceType = serviceUUIDToName[serviceUuid];
      // TODO: Can this be done in a generic way?
      MovisensService? newService;
      switch (serviceType) {
        case MovisensServiceTypes.ambient:
          newService = AmbientService(service: service);
          break;
        case MovisensServiceTypes.eda:
          newService = EdaService(service: service);
          break;
        case MovisensServiceTypes.hrv:
          newService = HrvService(service: service);
          break;
        case MovisensServiceTypes.marker:
          newService = MarkerService(service: service);
          break;
        case MovisensServiceTypes.battery:
          newService = BatteryService(service: service);
          break;
        case MovisensServiceTypes.userData:
          newService = UserDataService(service: service);
          break;
        case MovisensServiceTypes.physicalActivity:
          newService = PhysicalActivityService(service: service);
          break;
        case MovisensServiceTypes.respiration:
          newService = RespirationService(service: service);
          break;
        case MovisensServiceTypes.sensorControl:
          newService = SensorControlService(service: service);
          break;
        case MovisensServiceTypes.skinTemperature:
          newService = SkinTemperatureService(service: service);
          break;
        default:
          _log.warning(
              "Service uuid $serviceUuid is not recognized on movisens device [$macAddress]");
          break;
      }
      if (newService != null) {
        _log.info(
            "Storing service: ${serviceType.toString()} on movisens device [$macAddress]");
        _services[serviceType!] = newService;
      }
    }
  }

  /// Disconnect from the device.
  /// Clears device and services from memory.
  Future<void> disconnect() async {
    // TODO: Disable notify for all services on device before?
    await _bluetoothDevice?.disconnect();
    _bluetoothDevice = null;
    _services.clear();
    _log.info("Disconnected from movisens device [$macAddress]");
  }
}
