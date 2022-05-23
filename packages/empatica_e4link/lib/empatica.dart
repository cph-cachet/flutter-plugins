library empaticae4;

import 'dart:async';

import 'package:flutter/services.dart';

part 'empatica_status_events.dart';
part 'empatica_data_events.dart';

class EmpaticaPlugin {
  static const String methodChannelName = 'empatica.io/empatica_methodChannel';
  static const String statusEventSinkName =
      "empatica.io/empatica_statusEventSink";
  static const String dataEventSinkName = "empatica.io/empatica_dataEventSink";

  final MethodChannel _methodChannel = const MethodChannel(methodChannelName);
  final EventChannel _statusEventChannel =
      const EventChannel(statusEventSinkName);
  final EventChannel _dataEventChannel = const EventChannel(dataEventSinkName);

  Stream<EmpaticaStatusEvent>? _statusEventSink;
  Stream<EmpaticaDataEvent>? _dataEventSink;

  /// The [EmpaStatus] of the device. For example, ready, connected, disconnected, etc.
  EmpaStatus status = EmpaStatus.initial;
  // ------------    METHOD HANDLERS --------------------

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

  Future<void> disconnect() async {
    await _methodChannel.invokeMethod('disconnect');
  }

  // ------------    STREAM HANDLERS --------------------

  Stream<EmpaticaStatusEvent>? get statusEventSink {
    _statusEventSink = _statusEventChannel
        .receiveBroadcastStream()
        .map((event) => EmpaticaStatusEvent.fromMap(event));

    _statusEventSink?.listen((event) {
      if (event.runtimeType == UpdateStatus) {
        status = (event as UpdateStatus).status;
      }
    });
    return _statusEventSink;
  }

  Stream<EmpaticaDataEvent>? get dataEventSink {
    _dataEventSink = _dataEventChannel
        .receiveBroadcastStream()
        .map((event) => EmpaticaDataEvent.fromMap(event));
    return _dataEventSink;
  }
}
