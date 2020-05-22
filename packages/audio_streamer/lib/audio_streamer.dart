import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

/** A [AudioStreamer] object is reponsible for connecting
 * to the native environment and streaming audio from the microphone.**/
const String EVENT_CHANNEL_NAME = 'audio_streamer.eventChannel';

class AudioStreamer {
  bool _isRecording = false;
  bool debug = false;

  AudioStreamer({this.debug = false});

  int get sampleRate => 44100;

  static const EventChannel _noiseEventChannel = EventChannel(EVENT_CHANNEL_NAME);

  Stream<List<double>> _stream;
  StreamSubscription<List<dynamic>> _subscription;

  void _print(String t) {
    if (debug) print(t);
  }

  Stream<List<double>> get audioStream {
    if (_stream == null) {
      _stream = _noiseEventChannel
          .receiveBroadcastStream()
          .map((buffer) => buffer as List<dynamic>)
          .map((list) => list.map((e) => double.parse('$e')).toList());
    }
    return _stream;
  }

  /// Verify that it was granted
  static Future<bool> checkPermission() async => Permission.microphone.request().isGranted;

  /// Request the microphone permission
  static Future<void> requestPermission() async => Permission.microphone.request();

  Future<bool> start(Function onData) async {
    _print('AudioStreamer: startRecorder()');

    if (_isRecording) {
      print('AudioStreamer: Already recording!');
      return _isRecording;
    } else {
      bool granted = await AudioStreamer.checkPermission();

      if (granted) {
        _print('AudioStreamer: Permission granted? $granted');
        try {
          _isRecording = true;
          _subscription = audioStream.listen(onData);
        } catch (err) {
          _print('AudioStreamer: startRecorder() error: $err');
        }
      }

      /// If permission wasn't yet given, then
      /// ask for it, and then try recording again.
      else {
        await AudioStreamer.requestPermission();
        start(onData);
      }
    }
    return _isRecording;
  }

  Future<bool> stop() async {
    _print('AudioStreamer: stopRecorder()');
    try {
      if (_subscription != null) {
        _subscription.cancel();
        _subscription = null;
      }
      _isRecording = false;
    } catch (err) {
      _print('AudioStreamer: stopRecorder() error: $err');
    }
    return _isRecording;
  }
}
