import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Custom Exception for the plugin,
/// thrown whenever the plugin is used on platforms
/// where some health data metric isnt available
class HealthDataNotAvailableException implements Exception {
  String _cause;

  HealthDataNotAvailableException(this._cause);

  @override
  String toString() {
    return _cause;
  }
}

enum HealthDataType {
  BODY_FAT,
  HEIGHT,
  BODY_MASS_INDEX,
  WAIST_CIRCUMFERENCE,
  STEPS,
  BASAL_ENERGY_BURNED,
  ACTIVE_ENERGY_BURNED,
  HEART_RATE,
  BODY_TEMPERATURE,
  BLOOD_PRESSURE_SYSTOLIC,
  BLOOD_PRESSURE_DIASTOLIC,
  RESTING_HEART_RATE,
  WALKING_HEART_RATE,
  BLOOD_OXYGEN,
  BLOOD_GLUCOSE,
  ELECTRODERMAL_ACTIVITY,
  WEIGHT,

  /// HEART RATE EVENTS BELOW
  HIGH_HEART_RATE_EVENT,
  LOW_HEART_RATE_EVENT,
  IRREGULAR_HEART_RATE_EVENT,
  UNKNOWN
}

enum PlatformType { IOS, ANDROID, UNKNOWN }

class HealthData {
  double value;
  String unit;
  int dateFrom;
  int dateTo;
  String dataType;
  String platform;

  HealthData(
      {this.value,
      this.unit,
      this.dateFrom,
      this.dateTo,
      this.dataType,
      this.platform});

  HealthData.fromJson(Map<String, dynamic> json) {
    try {
      value = json['value'];
      unit = json['unit'];
      dateFrom = json['date_from'];
      dateTo = json['date_to'];
      dataType = json['data_type'];
      platform = json['platform_type'];
    } catch (error) {
      print(error);
      print('test');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['unit'] = this.unit;
    data['date_from'] = this.dateFrom;
    data['date_to'] = this.dateTo;
    data['data_type'] = this.dataType;
    data['platform_type'] = this.platform;
    return data;
  }

  String toString() {
    Map<String, dynamic> json = this.toJson();
    return json.toString();
  }
}

class FlutterHealth {
  static const Map<HealthDataType, String> _dataTypeToStringIOS = {
    HealthDataType.BODY_FAT: "bodyFatPercentage",
    HealthDataType.HEIGHT: "height",
    HealthDataType.BODY_MASS_INDEX: "bodyMassIndex",
    HealthDataType.WAIST_CIRCUMFERENCE: "waistCircumference",
    HealthDataType.STEPS: "stepCount",
    HealthDataType.BASAL_ENERGY_BURNED: "basalEnergyBurned",
    HealthDataType.ACTIVE_ENERGY_BURNED: "activeEnergyBurned",
    HealthDataType.HEART_RATE: "heartRate",
    HealthDataType.BODY_TEMPERATURE: "bodyTemperature",
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC: "bloodPressureSystolic",
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC: "bloodPressureDiastolic",
    HealthDataType.RESTING_HEART_RATE: "restingHeartRate",
    HealthDataType.WALKING_HEART_RATE: "walkingHeartRateAverage",
    HealthDataType.BLOOD_OXYGEN: "oxygenSaturation",
    HealthDataType.BLOOD_GLUCOSE: "bloodGlucose",
    HealthDataType.ELECTRODERMAL_ACTIVITY: "electrodermalActivity",
    HealthDataType.WEIGHT: "bodyMass",
    HealthDataType.HIGH_HEART_RATE_EVENT: "highHeartRateEvent",
    HealthDataType.LOW_HEART_RATE_EVENT: "lowHeartRateEvent",
    HealthDataType.IRREGULAR_HEART_RATE_EVENT: "irregularHeartRhythmEvent",
    HealthDataType.UNKNOWN: null,
  };

  static const Map<HealthDataType, String> _dataTypeToStringAndroid = {
    HealthDataType.BODY_FAT: "bodyFatPercentage",
    HealthDataType.HEIGHT: "height",
    HealthDataType.BODY_MASS_INDEX: null,
    HealthDataType.WAIST_CIRCUMFERENCE: null,
    HealthDataType.STEPS: "stepCount",
    HealthDataType.BASAL_ENERGY_BURNED: null,
    HealthDataType.ACTIVE_ENERGY_BURNED: "activeEnergyBurned",
    HealthDataType.HEART_RATE: "heartRate",
    HealthDataType.BODY_TEMPERATURE: "bodyTemperature",
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC: "bloodPressureSystolic",
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC: "bloodPressureDiastolic",
    HealthDataType.RESTING_HEART_RATE: null,
    HealthDataType.WALKING_HEART_RATE: null,
    HealthDataType.BLOOD_OXYGEN: "oxygenSaturation",
    HealthDataType.BLOOD_GLUCOSE: "bloodGlucose",
    HealthDataType.ELECTRODERMAL_ACTIVITY: null,
    HealthDataType.WEIGHT: null,
    HealthDataType.HIGH_HEART_RATE_EVENT: null,
    HealthDataType.LOW_HEART_RATE_EVENT: null,
    HealthDataType.IRREGULAR_HEART_RATE_EVENT: null,
    HealthDataType.UNKNOWN: null,
  };

  static String enumToDataTypeKey(HealthDataType type) {
    return Platform.isAndroid
        ? _dataTypeToStringAndroid[type]
        : _dataTypeToStringIOS[type];
  }

  static const MethodChannel _channel = const MethodChannel('flutter_health');

  static PlatformType _platformType =
      Platform.isAndroid ? PlatformType.ANDROID : PlatformType.IOS;

  static String _methodName = 'getData';

  /// Check if a given data type is available on the platform
  static bool checkIfDataTypeAvailable(HealthDataType dataType) {
    String dataTypeKey = _platformType == PlatformType.ANDROID
        ? _dataTypeToStringAndroid[dataType]
        : _dataTypeToStringIOS[dataType];

    /// Check that the key isn't null.
    /// If it is, then the data type does not exist for the current platform.
    return dataTypeKey != null;
  }

  ///  Check if GoogleFit/Apple HealthKit is enabled on the device
  static Future<bool> checkIfHealthDataAvailable() async {
    final bool isHealthDataAvailable =
        await _channel.invokeMethod('checkIfHealthDataAvailable');
    return isHealthDataAvailable;
  }

  /// Request access to GoogleFit/Apple HealthKit
  static Future<bool> requestAuthorization() async {
    final bool isAuthorized =
        await _channel.invokeMethod('requestAuthorization');
    return isAuthorized;
  }

  /// Main function for fetching health data
  static Future<List<HealthData>> getHealthDataFromType(
      DateTime startDate, DateTime endDate, HealthDataType dataType) async {
    List<HealthData> healthData = new List();

    String dataTypeKey = _platformType == PlatformType.ANDROID
        ? _dataTypeToStringAndroid[dataType]
        : _dataTypeToStringIOS[dataType];

    /// If not implemented on platform, throw an exception
    if (dataTypeKey == null) {
      throw new HealthDataNotAvailableException(
          "Method ${dataType.toString()} not implemented for platform ${_platformType.toString()}");
    }

    /// Set parameters for method channel request
    Map<String, dynamic> args = {
      'dataTypeKey': dataTypeKey,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch
    };

    try {
      List result = await _channel.invokeMethod(_methodName, args);

      /// Process each data point received
      for (var x in result) {
        /// Add the platform_type and data_type fields
        x["platform_type"] = _platformType.toString();
        x["data_type"] = dataType.toString();

        /// Convert to JSON
        Map<String, dynamic> jsonData = Map<String, dynamic>.from(x);

        /// Convert JSON to HealthData object
        HealthData data = HealthData.fromJson(jsonData);
        healthData.add(data);
      }
    } catch (error) {
      print(error);
    }
    return healthData;
  }
}
