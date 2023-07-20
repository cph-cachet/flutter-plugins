import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

const String EVENT_CHANNEL_NAME = 'audio_streamer.eventChannel';
const String METHOD_CHANNEL_NAME = 'audio_streamer.methodChannel';

/// API for streaming raw / native audio data.
class AudioStreamer {
  static AudioStreamer? _singleton;

  bool _isRecording = false;
  static const EventChannel _noiseEventChannel =
      EventChannel(EVENT_CHANNEL_NAME);
  static const MethodChannel _sampleRateChannel =
      MethodChannel(METHOD_CHANNEL_NAME);
  Stream<List<double>>? _stream;
  StreamSubscription<List<dynamic>>? _subscription;

  /// Constructs a singleton instance of [AudioStreamer].
  ///
  /// [AudioStreamer] is designed to work as a singleton.
  // When a second instance is created, the first instance will not be able to listen to the
  // audio because it is overridden. Forcing the class to be a singleton class can prevent
  // misuse of creating a second instance from a programmer.
  factory AudioStreamer() => _singleton ??= AudioStreamer._();

  AudioStreamer._();

  /// Get the actual sampling rate, may be different from the requested sampling rate
  Future<int> get actualSampleRate async =>
      await _sampleRateChannel.invokeMethod('getSampleRate');

  /// Verify that microphone permission was granted.
  Future<bool> checkPermission() async =>
      await Permission.microphone.request().isGranted;

  /// Request the microphone permission.
  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  /// Start streaming audio.
  ///
  /// Only starts if microphone permission was granted
  ///
  /// The [onData] callback function will be called to handle the audio stream.
  /// The [handleError] callback will be called to handle any errors.
  /// The [samplingRate] specifies the sampling rate in Hz.
  /// Default sample rate of is 44100 Hz.
  /// Note that sampling rate can only be set on Android, not on iOS.
  Future<bool> start(
    Function onData,
    Function handleError, {
    samplingRate = 44100,
  }) async {
    if (_isRecording) {
      print('AudioStreamer: Already recording!');
      return _isRecording;
    } else {
      bool granted = await checkPermission();

      if (granted) {
        final stream = _makeAudioStream(handleError, samplingRate);
        _subscription = stream.listen(onData as void Function(List<double>)?);
        _isRecording = true;
      }

      // If permission wasn't yet given, then ask for it, and then try recording again.
      else {
        await requestPermission();
        start(onData, handleError, samplingRate: samplingRate);
      }
    }
    return _isRecording;
  }

  /// Stop audio recording.
  Future<bool> stop() async {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }
    return _isRecording = false;
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
          .map((list) {
            if (list != null && list.isNotEmpty && list[0] is double)
              return list.cast<double>();
            return list!
                .map((e) => e is double ? e : double.parse('$e'))
                .toList();
          });
    }
    return _stream!;
  }
}
