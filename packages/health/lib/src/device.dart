part of health;

/// A [Device] object corresponds to device information as retrieved from HealthKit.
class Device {
  String? _udiDeviceIdentifier;
  String? _firmwareVersion;
  String? _hardwareVersion;
  String? _softwareVersion;
  String? _model;
  String? _manufacturer;
  String? _name;
  Device(
      this._udiDeviceIdentifier,
      this._firmwareVersion,
      this._hardwareVersion,
      this._softwareVersion,
      this._model,
      this._manufacturer,
      this._name);

  /// Converts a json object to the [Device].
  factory Device.fromJson(json) {
    return Device(
        json['udi_device_identifier'],
        json['firmware_version'],
        json['hardware_version'],
        json['software_version'],
        json['model'],
        json['manufacturer'],
        json['name']);
  }

  /// Converts the [Device] to a json object.
  Map<String, dynamic> toJson() => {
        'udi_device_identifier': udiDeviceIdentifier,
        'firmware_version': firmwareVersion,
        'hardware_version': hardwareVersion,
        'software_version': softwareVersion,
        'model': model,
        'manufacturer': manufacturer,
        'name': name
      };
  @override
  String toString() => """${this.runtimeType} -
    udiDeviceIdentifier: $udiDeviceIdentifier,
    firmwareVersion: $firmwareVersion,
    hardwareVersion: $hardwareVersion,
    softwareVersion: $softwareVersion,
    model: $model,
    manufacturer: $manufacturer,
    name: $name
    """;

  /// The device identifier portion of the US Food and Drug Administration's Unique Device Identifier (UDI).
  String? get udiDeviceIdentifier => _udiDeviceIdentifier;

  /// The device firmware version.
  String? get firmwareVersion => _firmwareVersion;

  /// The device hardware version.
  String? get hardwareVersion => _hardwareVersion;

  /// The device software version.
  String? get softwareVersion => _softwareVersion;

  /// The device model.
  String? get model => _model;

  /// The device manufacturer.
  String? get manufacturer => _manufacturer;

  /// The name of the device.
  String? get name => _name;
  @override
  bool operator ==(Object o) {
    return o is Device &&
        this.udiDeviceIdentifier == o.udiDeviceIdentifier &&
        this.firmwareVersion == o.firmwareVersion &&
        this.hardwareVersion == o.hardwareVersion &&
        this.softwareVersion == o.softwareVersion &&
        this.model == o.model &&
        this.manufacturer == o.manufacturer &&
        this.name == o.name;
  }

  @override
  int get hashCode => Object.hash(udiDeviceIdentifier, firmwareVersion,
      hardwareVersion, softwareVersion, model, manufacturer, name);
}
