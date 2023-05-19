import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/*
 * A [AudioStreamer] object is reponsible for connecting
 * to the native environment and streaming audio from the microphone.*
 */
const String EVENT_CHANNEL_NAME = 'audio_streamer.eventChannel';
const String METHOD_CHANNEL_NAME = 'audio_streamer.methodChannel';

class AudioStreamer {
  bool _isRecording = false;

  static Future<int> get currSampleRate => _getActualSampleRate();

  static const EventChannel _noiseEventChannel =
      EventChannel(EVENT_CHANNEL_NAME);

  static const MethodChannel _sampleRateChannel =
      MethodChannel(METHOD_CHANNEL_NAME);

  Stream<List<double>>? _stream;
  StreamSubscription<List<dynamic>>? _subscription;

  /// Use MethodChannel to get the current sample rate, may be different from requested sample rate
  static Future<int> _getActualSampleRate() async {
    var currSampleRate = await _sampleRateChannel.invokeMethod('getSampleRate');
    return currSampleRate;
  }

  /// Use EventChannel to receive audio stream from native
  Stream<List<double>> _makeAudioStream(
      Function handleErrorFunction, int sampleRate) {
    if (_stream == null) {
      _stream = _noiseEventChannel
          .receiveBroadcastStream({"sampleRate": sampleRate})
          .handleError((error) {
            _isRecording = false;
            _stream = null;
            handleErrorFunction(error);
          })
          .map((buffer) => buffer as List<dynamic>?)
          .map(((list) {
        if (list != null && list.isNotEmpty && list[0] is double) return list.cast<double>();
        return list!.map((e) => e is double ? e : double.parse('$e')).toList();
      });
    }
    return _stream!;
  }

  /// Verify that microphone permission was granted
  static Future<bool> checkPermission() async =>
      await Permission.microphone.request().isGranted;

  /// Request the microphone permission
  static Future<void> requestPermission() async =>
      await Permission.microphone.request();

  /// Start recording if microphone permission was granted
  ///
  /// Parameters:
  ///
  /// * [onData] - A callback function that will be called to handle the audio stream.
  /// * [handleError] - A callback function that will be called to handle any errors.
  /// * [sampleRate] - Optional.
  ///   + If unspecified: Default sample rate of 44100 will be used.
  ///   + If specified: Audio streamer will use the specified sample rate, but this may not succeed on iOS.
  Future<bool> start(Function onData, Function handleError,
      {sampleRate = 44100}) async {
    if (_isRecording) {
      print('AudioStreamer: Already recording!');
      return _isRecording;
    } else {
      bool granted = await AudioStreamer.checkPermission();

      if (granted) {
        try {
          final stream = _makeAudioStream(handleError, sampleRate);
          _subscription = stream.listen(onData as void Function(List<double>)?);
          _isRecording = true;
        } catch (err) {
          debugPrint('AudioStreamer: startRecorder() error: $err');
        }
      }

      /// If permission wasn't yet given, then
      /// ask for it, and then try recording again.
      else {
        await AudioStreamer.requestPermission();
        start(onData, handleError, sampleRate: sampleRate);
      }
    }
    return _isRecording;
  }

  /// Stop the recording
  Future<bool> stop() async {
    try {
      if (_subscription != null) {
        _subscription!.cancel();
        _subscription = null;
      }
      _isRecording = false;
    } catch (err) {
      debugPrint('AudioStreamer: stopRecorder() error: $err');
    }
    return _isRecording;
  }
}
