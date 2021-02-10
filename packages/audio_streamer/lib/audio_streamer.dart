import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

/** A [AudioStreamer] object is reponsible for connecting
 * to the native environment and streaming audio from the microphone.**/
const String EVENT_CHANNEL_NAME = 'audio_streamer.eventChannel';

class AudioStreamer {
  bool _isRecording = false;

  static int get sampleRate => 44100;

  static const EventChannel _noiseEventChannel =
      EventChannel(EVENT_CHANNEL_NAME);

  Stream<List<double>> _stream;
  StreamSubscription<List<dynamic>> _subscription;

  Stream<List<double>> _makeAudioStream(Function handleErrorFunction) {
    if (_stream == null) {
      _stream = _noiseEventChannel
          .receiveBroadcastStream()
          .handleError((error) {
            _isRecording = false;
            _stream = null;
            handleErrorFunction(error);
          })
          .map((buffer) => buffer as List<dynamic>)
          .map((list) => list.map((e) => double.parse('$e')).toList());
    }
    return _stream;
  }

  /// Verify that it was granted
  static Future<bool> checkPermission() async =>
      Permission.microphone.request().isGranted;

  /// Request the microphone permission
  static Future<void> requestPermission() async =>
      Permission.microphone.request();

  Future<bool> start(Function onData, Function handleError) async {
    if (_isRecording) {
      print('AudioStreamer: Already recording!');
      return _isRecording;
    } else {
      bool granted = await AudioStreamer.checkPermission();

      if (granted) {
        try {
          final stream = _makeAudioStream(handleError);
          _subscription = stream.listen(onData);
          _isRecording = true;
        } catch (err) {
          debugPrint('AudioStreamer: startRecorder() error: $err');
        }
      }

      /// If permission wasn't yet given, then
      /// ask for it, and then try recording again.
      else {
        await AudioStreamer.requestPermission();
        start(onData, handleError);
      }
    }
    return _isRecording;
  }

  Future<bool> stop() async {
    try {
      if (_subscription != null) {
        _subscription.cancel();
        _subscription = null;
      }
      _isRecording = false;
    } catch (err) {
      debugPrint('AudioStreamer: stopRecorder() error: $err');
    }
    return _isRecording;
  }
}
