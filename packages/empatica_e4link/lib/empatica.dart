library empaticae4;

import 'dart:async';

import 'package:flutter/services.dart';

class EmpaticaPlugin {
  static const String empaticaMethodChannelName =
      'empatica.io/empatica_methodChannel';
  static const String empaticaStatusEventChannelName =
      'empatica.io/empatica_statusEventChannel';

  static const MethodChannel _channel =
      MethodChannel(empaticaMethodChannelName);

  Future<void> testTheChannel() async {
    await _channel.invokeMethod('testTheChannel');
  }

  Future<void> authenticateWithAPIKey(String key) async {
    await _channel.invokeMethod('authenticateWithAPIKey', {'key': key});
  }

  Future<void> startScanning() async {
    await _channel.invokeMethod('startScanning');
  }

  Future<void> authenticateWithConnectUser() async {
    await _channel.invokeMethod('authenticateWithConnectUser');
  }

  Future<void> stopScanning() async {
    await _channel.invokeMethod('stopScanning');
  }

  Future<void> connectDevice(String serialNumber) async {
    await _channel
        .invokeMethod('connectDevice', {'serialNumber': serialNumber});
  }

  // ------------    STREAM HANDLERS --------------------

}
