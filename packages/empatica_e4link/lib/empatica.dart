library empaticae4;

import 'dart:async';

import 'package:flutter/services.dart';

class EmpaticaPlugin {
  static const String methodChannelName = 'empatica.io/empatica_methodChannel';
  static const String statusEventSinkName =
      "empatica.io/empatica_statusEventSink";
  static const String dataEventSinkName = "empatica.io/empatica_dataEventSink";

  final MethodChannel _methodChannel = const MethodChannel(methodChannelName);
  final EventChannel _statusEventChannel =
      const EventChannel(statusEventSinkName);
  final EventChannel _dataEventChannel = const EventChannel(dataEventSinkName);

  Stream<dynamic>? _statusEventSink;
  Stream<dynamic>? _dataEventSink;

  Future<void> testTheChannel() async {
    await _methodChannel.invokeMethod('testTheChannel');
  }

  Future<void> authenticateWithAPIKey(String key) async {
    await _methodChannel.invokeMethod('authenticateWithAPIKey', {'key': key});
  }

  Future<void> startScanning() async {
    await _methodChannel.invokeMethod('startScanning');
  }

  Future<void> authenticateWithConnectUser() async {
    await _methodChannel.invokeMethod('authenticateWithConnectUser');
  }

  Future<void> stopScanning() async {
    await _methodChannel.invokeMethod('stopScanning');
  }

  Future<void> connectDevice(String serialNumber) async {
    await _methodChannel
        .invokeMethod('connectDevice', {'serialNumber': serialNumber});
  }

  // ------------    STREAM HANDLERS --------------------

  Stream<dynamic>? get statusEventSink {
    _statusEventSink = _statusEventChannel.receiveBroadcastStream();
    return _statusEventSink;
  }

  Stream<dynamic>? get dataEventSink {
    _dataEventSink = _dataEventChannel.receiveBroadcastStream();
    return _dataEventSink;
  }
}
