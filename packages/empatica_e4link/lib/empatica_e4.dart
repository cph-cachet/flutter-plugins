library empaticae4;

import 'dart:async';

import 'package:flutter/services.dart';

class EmpaDeviceManager {
  static const String EmpaDeviceManagerMethodChannelName =
      "empatica.io/empatica_deviceManager";
  static const EmpaStatusDelegateEventChannelName =
      "empatica.io/empatica_statusDelegate";
  static const String EmpaDataDelegateEventChannelName =
      "empatica.io/empatica_dataDelegate";

  static MethodChannel _empaDeviceManagerMethodChannel =
      const MethodChannel(EmpaDeviceManagerMethodChannelName);
  final EventChannel _empaStatusDelegateEventChannel =
      const EventChannel(EmpaStatusDelegateEventChannelName);
  final EventChannel _empaDataDelegateEventChannel =
      const EventChannel(EmpaDataDelegateEventChannelName);

  // ------------    METHOD HANDLERS --------------------

  Future<void> authenticateWithAPIKey(String key) async {
    _empaDeviceManagerMethodChannel.invokeMethod('authenticateWithAPIKey', {
      'key': key,
    });
  }
  
  Future<void> testTheChannel() async {
    _empaDeviceManagerMethodChannel.invokeMethod('testTheChannel');
  }
}
