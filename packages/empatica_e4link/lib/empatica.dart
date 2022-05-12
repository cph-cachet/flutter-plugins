library empaticae4;

import 'dart:async';

import 'package:flutter/services.dart';

class EmpaticaPlugin {
  static const String empaticaMethodChannelName =
      'empatica.io/empatica_methodChannel';
  static const String empaticaEventSinkName =
      "empatica.io/empatica_statusEventSink";

  final MethodChannel _methodChannel =
      const MethodChannel(empaticaMethodChannelName);
  final EventChannel _eventChannel = const EventChannel(empaticaEventSinkName);

  Stream<dynamic>? _eventSink;

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

  Stream<dynamic>? get eventSink {
    _eventSink = _eventChannel.receiveBroadcastStream();
    return _eventSink;
  }
}
