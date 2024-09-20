part of '../health.dart';

class UvExposureModel {
  final double value;
  final int startTime;
  final int endTime;
  final RecordingMethod recordingMethod;

  UvExposureModel({
    required this.value,
    required this.startTime,
    required this.endTime,
    required this.recordingMethod,
  });

  factory UvExposureModel.fromMap(Map<String, dynamic> map) {
    return UvExposureModel(
      value: map['value'] as double,
      startTime: map['startTime'] as int,
      endTime: map['endTime'] as int,
      recordingMethod: RecordingMethod.fromInt(map['recordingMethod'] as int),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'startTime': startTime,
      'endTime': endTime,
      'recordingMethod': recordingMethod.index,
    };
  }
}