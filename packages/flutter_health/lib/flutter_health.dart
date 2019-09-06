import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class FlutterHealth {

  static const healthKitTypes = [
    'BODY_FAT',
    'HEIGHT',
    'BODY_MASS_INDEX',
    'WAIST_CIRCUMFERENCE',
    'STEPS',
    'BASAL_ENERGY_BURNED',
    'ACTIVE_ENERGY_BURNED',
    'HEART_RATE',
    'BODY_TEMPERATURE',
    'BLOOD_PRESSURE_SYSTOLIC',
    'BLOOD_PRESSURE_DIASTOLIC',
    'RESTING_HEART_RATE',
    'WALKING_HEART_RATE',
    'BLOOD_OXYGEN',
    'BLOOD_GLUCOSE',
    'ELECTRODERMAL_ACTIVITY',
    'HIGH_HEART_RATE_EVENT',
    'LOW_HEART_RATE_EVENT',
    'IRREGULAR_HEART_RATE_EVENT',
  ];

  static const googleFitTypes = [
    'BODY_FAT',
    'HEIGHT',
    'STEPS',
    'CALORIES',
    'HEART_RATE',
    'BODY_TEMPERATURE',
    'BLOOD_PRESSURE',
    'BLOOD_OXYGEN',
    'BLOOD_GLUCOSE',
  ];

  static const MethodChannel _channel = const MethodChannel('flutter_health');
  static PlatformType _platformType = Platform.isAndroid
      ? PlatformType.ANDROID
      : PlatformType.IOS;

  static Future<bool> checkIfHealthDataAvailable() async {
    final bool isHealthDataAvailable = await _channel.invokeMethod(
        'checkIfHealthDataAvailable');
    return isHealthDataAvailable;
  }

  static Future<bool> requestAuthorization() async {
    final bool isAuthorized = await _channel.invokeMethod(
        'requestAuthorization');
    return isAuthorized;
  }

  static Future<List<HealthData>> getHKBodyFat(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 0);
  }

  static Future<List<GFHealthData>> getGFBodyFat(DateTime startDate,
      DateTime endDate) async {
    return getGFHealthData(startDate, endDate, 0);
  }

  static Future<List<HealthData>> getHKHeight(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 1);
  }

  static Future<List<GFHealthData>> getGFHeight(DateTime startDate,
      DateTime endDate) async {
    return getGFHealthData(startDate, endDate, 1);
  }

  static Future<List<HealthData>> getHKBodyMass(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 2);
  }

  static Future<List<HealthData>> getHKWaistCircumference(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 3);
  }

  static Future<List<HealthData>> getStepCount(DateTime startDate,
      DateTime endDate) async {
    return getHealthData(startDate, endDate, 'STEPS');
  }

  static Future<List<HealthData>> getHKBasalEnergyBurned(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 5);
  }

  static Future<List<HealthData>> getHKActiveEnergyBurned(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 6);
  }

  static Future<List<GFHealthData>> getGFEnergyBurned(DateTime startDate,
      DateTime endDate) async {
    return getGFHealthData(startDate, endDate, 3);
  }

  static Future<List<HealthData>> getHKHeartRate(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 7);
  }

  static Future<List<GFHealthData>> getGFHeartRate(DateTime startDate,
      DateTime endDate) async {
    return getGFHealthData(startDate, endDate, 4);
  }

  static Future<List<HealthData>> getHKRestingHeartRate(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 8);
  }

  static Future<List<HealthData>> getHKWalkingHeartRate(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 9);
  }

  static Future<List<HealthData>> getHKBodyTemperature(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 10);
  }

  static Future<List<GFHealthData>> getGFBodyTemperature(DateTime startDate,
      DateTime endDate) async {
    return getGFHealthData(startDate, endDate, 5);
  }

  static Future<List<List<HealthData>>> getHKBloodPressure(DateTime startDate,
      DateTime endDate) async {
    var sys = await getHealthDataCACHET(startDate, endDate, 11);
    var dia = await getHealthDataCACHET(startDate, endDate, 12);
    return [sys, dia];
  }

  static Future<List<GFHealthData>> getGFBloodPressure(DateTime startDate,
      DateTime endDate) async {
    return await getGFHealthData(startDate, endDate, 6);
  }


  static Future<List<HealthData>> getHKBloodPressureSys(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 11);
  }

  static Future<List<HealthData>> getHKBloodPressureDia(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 12);
  }

  static Future<List<HealthData>> getHKBloodOxygen(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 13);
  }

  static Future<List<GFHealthData>> getGFBloodOxygen(DateTime startDate,
      DateTime endDate) async {
    return getGFHealthData(startDate, endDate, 7);
  }


  static Future<List<HealthData>> getHKBloodGlucose(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 14);
  }

  static Future<List<GFHealthData>> getGFBloodGlucose(DateTime startDate,
      DateTime endDate) async {
    return getGFHealthData(startDate, endDate, 8);
  }

  static Future<List<HealthData>> getHKElectrodermalActivity(DateTime startDate,
      DateTime endDate) async {
    return getHealthDataCACHET(startDate, endDate, 15);
  }

  static Future<List<HealthData>> getHKHighHeart(DateTime startDate,
      DateTime endDate) async {
    return getHKHeartData(startDate, endDate, 16);
  }

  static Future<List<HealthData>> getHKLowHeart(DateTime startDate,
      DateTime endDate) async {
    return getHKHeartData(startDate, endDate, 17);
  }

  static Future<List<HealthData>> getHKIrregular(DateTime startDate,
      DateTime endDate) async {
    return getHKHeartData(startDate, endDate, 18);
  }

//
//  static Future<List<HealthData>> getHKAllData(DateTime startDate,
//      DateTime endDate) async {
//    List<HealthData> allData = new List<HealthData>();
//    var healthData = List.from(HKDataType.values);
//    healthData.removeRange(
//        HKDataType.values.indexOf(HKDataType.HIGH_HEART_RATE_EVENT),
//        HKDataType.values.indexOf(HKDataType.IRREGULAR_HEART_RATE_EVENT));
//    for (int i = 0; i < healthData.length; i++) {
//      allData.addAll(await getHealthDataCACHET(startDate, endDate, i));
//    }
//    for (int i = HKDataType.values.indexOf(
//        HKDataType.HIGH_HEART_RATE_EVENT); i < HKDataType.values.length; i++) {
//      allData.addAll(await getHKHeartData(startDate, endDate, i));
//    }
//    return allData;
//  }
//

//  static Future<List<GFHealthData>> getGFAllData(DateTime startDate,
//      DateTime endDate) async {
//    List<GFHealthData> allData = new List<GFHealthData>();
//    var healthData = List.from(GFDataType.values);
//
//    for (int i = 0; i < GFDataType.values.length; i++) {
//      allData.addAll(await getGFHealthData(startDate, endDate, i));
//    }
//    return allData;
//  }

//  static Future<List<HealthData>> getHKAllDataWithCombinedBP(DateTime startDate,
//      DateTime endDate) async {
//    List<HealthData> allData = new List<HealthData>();
//    var healthData = List.from(HKDataType.values);
//    healthData.removeRange(
//        HKDataType.values.indexOf(HKDataType.HIGH_HEART_RATE_EVENT),
//        HKDataType.values.indexOf(HKDataType.IRREGULAR_HEART_RATE_EVENT));
//    List<HealthData> bpRecords = [];
//    for (int i = 0; i < healthData.length; i++) {
//      if (healthData[i] == HKDataType.BLOOD_PRESSURE_SYSTOLIC) {
//        bpRecords = await getHealthDataCACHET(startDate, endDate, i);
//      } else if (healthData[i] == HKDataType.BLOOD_PRESSURE_DIASTOLIC) {
//        var dia = await getHealthDataCACHET(startDate, endDate, i);
//        for (int j = 0; j < dia.length; j++) {
//          try {
//            bpRecords[j].value2 = dia[j].value;
//          } catch (e) {}
//        }
//        allData.addAll(bpRecords);
//      } else
//        allData.addAll(await getHealthDataCACHET(startDate, endDate, i));
//    }
//    for (int i = HKDataType.values.indexOf(
//        HKDataType.HIGH_HEART_RATE_EVENT); i < HKDataType.values.length; i++) {
//      allData.addAll(await getHKHeartData(startDate, endDate, i));
//    }
//    return allData;
//  }


  /// CACHET implementation
  static Future<List<GFHealthData>> getGFHealthData(DateTime startDate,
      DateTime endDate, int type) async {
    Map<String, dynamic> args = {};
    args.putIfAbsent('index', () => type);
    args.putIfAbsent('startDate', () => startDate.millisecondsSinceEpoch);
    args.putIfAbsent('endDate', () => endDate.millisecondsSinceEpoch);
    try {
      List result = await _channel.invokeMethod('getGFHealthData', args);
      var gfHealthData = List<GFHealthData>.from(result.map((i) =>
          GFHealthData.fromJson(Map<String, dynamic>.from(i))));
      return gfHealthData;
    } catch (e, s) {
      return const [];
    }
  }

  static Future<List<HealthData>> getHealthDataCACHET(DateTime startDate,
      DateTime endDate, int type) async {
    Map<String, dynamic> args = {};

    args.putIfAbsent('index', () => type);
    args.putIfAbsent('startDate', () => startDate.millisecondsSinceEpoch);
    args.putIfAbsent('endDate', () => endDate.millisecondsSinceEpoch);
    try {
      List result = await _channel.invokeMethod('getData', args);
      List<HealthData> healthData = new List();

      /// Process each data point received
      for (var x in result) {
        /// Add the platform_type and data_type fields
        x["platform_type"] = _platformType.toString();
        x["data_type"] = HKDataType.values[type].toString();

        /// Convert to JSON
        Map<String, dynamic> jsonData = Map<String, dynamic>.from(x);

        /// Convert JSON to HealtData object
        HealthData data = HealthData.fromJson(jsonData);
        healthData.add(data);
      }
      return healthData;
    } catch (e) {
      return const [];
    }
  }

  static Future<List<HealthData>> getHealthData(DateTime startDate,
      DateTime endDate, String dataType) async {
    Map<String, dynamic> args = {};

    int dataTypeIndex = _platformType == PlatformType.ANDROID
        ? googleFitTypes.indexOf(dataType)
        : healthKitTypes.indexOf(dataType);

    args.putIfAbsent('index', () => dataTypeIndex);
    args.putIfAbsent('startDate', () => startDate.millisecondsSinceEpoch);
    args.putIfAbsent('endDate', () => endDate.millisecondsSinceEpoch);
    try {
      List result = await _channel.invokeMethod('getData', args);
      List<HealthData> healthData = new List();

      /// Process each data point received
      for (var x in result) {
        /// Add the platform_type and data_type fields
        x["platform_type"] = _platformType.toString();
        x["data_type"] = dataType;

        /// Convert to JSON
        Map<String, dynamic> jsonData = Map<String, dynamic>.from(x);

        /// Convert JSON to HealtData object
        HealthData data = HealthData.fromJson(jsonData);
        healthData.add(data);
      }
      return healthData;
    } catch (e) {
      return const [];
    }
  }

  static Future<List<HealthData>> getHKHeartData(DateTime startDate,
      DateTime endDate, int type) async {
    Map<String, dynamic> args = {};
    args.putIfAbsent('index', () => type);
    args.putIfAbsent('startDate', () => startDate.millisecondsSinceEpoch);
    args.putIfAbsent('endDate', () => endDate.millisecondsSinceEpoch);
    try {
      List result = await _channel.invokeMethod('getHeartAlerts', args);
      var hkHealthData = List<HealthData>.from(result.map((i) =>
          HealthData.fromJson(Map<String, dynamic>.from(i))));
      return hkHealthData;
    } catch (e) {
      return const [];
    }
  }

}


class GFHealthData {
  String value;
  String value2;
  String unit;
  int dateFrom;
  int dateTo;
  GFDataType dataType;

  GFHealthData(
      {this.value, this.unit, this.dateFrom, this.dateTo, this.dataType});

  GFHealthData.fromJson(Map<String, dynamic> json) {
    value = json['value'].toString();
    value2 = json['value2'].toString();
    unit = json['unit'];
    dateFrom = json['date_from'];
    dateTo = json['date_to'];
    dataType = GFDataType.values[json['data_type_index']];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['value2'] = this.value2;
    data['unit'] = this.unit;
    data['date_from'] = this.dateFrom;
    data['date_to'] = this.dateTo;
    data['data_type_index'] = GFDataType.values.indexOf(this.dataType);
    return data;
  }
}

enum HKDataType {
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
  HIGH_HEART_RATE_EVENT,
  LOW_HEART_RATE_EVENT,
  IRREGULAR_HEART_RATE_EVENT
}

enum GFDataType {
  BODY_FAT,
  HEIGHT,
  STEPS,
  CALORIES,
  HEART_RATE,
  BODY_TEMPERATURE,
  BLOOD_PRESSURE,
  BLOOD_OXYGEN,
  BLOOD_GLUCOSE,
}


/// Cachet implementations below
enum PlatformType {
  IOS,
  ANDROID,
  UNKNOWN
}

class HealthData {
  double value;
  double value2;
  String unit;
  int dateFrom;
  int dateTo;
  String dataType;
  String platform;

  HealthData(
      {this.value, this.unit, this.dateFrom, this.dateTo, this.dataType, this.platform});

  HealthData.fromJson(Map<String, dynamic> json) {
    try {
      value = json['value'];
      unit = json['unit'];
      dateFrom = json['date_from'];
      dateTo = json['date_to'];
      dataType = json['data_type'];
      platform = json['platform_type'];
    }
    catch (error) {
      print(error);
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

}