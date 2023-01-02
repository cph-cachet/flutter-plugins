/*
 * Copyright 2022 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
part of movisens_flutter;

/// A representation of a Movisens device with services
///
/// It contains all the services that the movisens device provides
/// and the methods for handling device connection.
class MovisensDevice {
  late String name;
  late String id;
  BluetoothDevice? _bluetoothDevice;

  /// Is the phone and app connected to the movisens device
  bool get isConnected => _bluetoothDevice != null;

  final Map<MovisensServiceTypes, MovisensService> _services = {};

  /// The bluetooth connection state of the device.
  ///
  /// Returns null if the device is not connected or being connected
  /// using the [connect] method.
  Stream<BluetoothDeviceState>? get state => _bluetoothDevice?.state;

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
  /// [name] required to connect to a device.
  MovisensDevice({required this.name});

  /// Connect to the movisens device using the [name].
  /// Automatically discovers services on device and stores them.
  Future<void> connect() async {
    _log.info("Connecting to movisens device using name: [$name]");
    FlutterBluePlus flutterBluePlus = FlutterBluePlus.instance;
    // Checking if already connected - skips the rest of connect if true
    // TODO: If already connected - can `device.connect()` be avoided?
    List<BluetoothDevice> connectedDevices =
        await flutterBluePlus.connectedDevices;
    for (BluetoothDevice device in connectedDevices) {
      if (device.name == name) {
        await device.connect();
        _bluetoothDevice = device;
        // Discover services
        await _discoverAndSetup();
        return;
      }
    }

    // (For android) Check if the device is bonded
    if (Platform.isAndroid) {
      List<BluetoothDevice> bondedDevices = await flutterBluePlus.bondedDevices;
      for (BluetoothDevice device in bondedDevices) {
        if (device.name == name) {
          await device.connect();
          _bluetoothDevice = device;
          // Discover services
          await _discoverAndSetup();
          return;
        }
      }
    }

    // Scan for devices
    flutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    late StreamSubscription subscription;
    subscription = flutterBluePlus.scanResults.listen((scanResults) async {
      // Select only 1 device to connect to
      ScanResult? scanResult =
          (scanResults.any((element) => element.device.name == name))
              ? scanResults.firstWhere((element) => element.device.name == name)
              : null;
      // connect, stop scanning and clean streams
      if (scanResult != null) {
        await flutterBluePlus.stopScan();
        await scanResult.device.connect();
        _bluetoothDevice = scanResult.device;
        await _discoverAndSetup();
        await subscription.cancel();
      }
    });
  }

  // Discovers services on device and instanciates them
  Future<void> _discoverAndSetup() async {
    id = _bluetoothDevice!.id.id;
    _log.info("Stored ID [$id] from movisens device [$name]");
    _log.info("Discovering services on movisens device [$id]");
    // Discover services
    late List<BluetoothService> services;
    // Delay introduced as BluetoothDevice.connect could sometimes finish before the device was connected.
    await Future.delayed(const Duration(milliseconds: 500));
    services = await _bluetoothDevice!.discoverServices();

    // Setup services
    for (BluetoothService service in services) {
      String serviceUuid = service.uuid.toString();
      MovisensServiceTypes? serviceType = serviceUUIDToName[serviceUuid];
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
              "Service uuid $serviceUuid is not recognized on movisens device [$id]");
          break;
      }
      if (newService != null) {
        _log.info(
            "Storing service: ${serviceType.toString()} on movisens device [$id]");
        _services[serviceType!] = newService;
      }
    }
  }

  /// Disconnect from the device.
  /// Clears device and services from memory.
  ///
  /// <mark>FlutterBluePlus can experience several bugs when trying to disconnect and connect again</mark>
  Future<void> disconnect() async {
    await _bluetoothDevice?.disconnect();
    _bluetoothDevice = null;
    _services.clear();
    _log.info("Disconnected from movisens device [$id]");
  }
}
