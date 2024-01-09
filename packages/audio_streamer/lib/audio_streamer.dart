import 'dart:async';
import 'package:flutter/services.dart';

const String EVENT_CHANNEL_NAME = 'audio_streamer.eventChannel';
const String METHOD_CHANNEL_NAME = 'audio_streamer.methodChannel';

/// API for streaming raw audio data.
class AudioStreamer {
  static const EventChannel _noiseEventChannel =
      EventChannel(EVENT_CHANNEL_NAME);
  static const MethodChannel _sampleRateChannel =
      MethodChannel(METHOD_CHANNEL_NAME);
  static const int DEFAULT_SAMPLING_RATE = 44100;

  int _sampleRate = DEFAULT_SAMPLING_RATE;
  Stream<List<double>>? _stream;
  static AudioStreamer? _instance;

  /// Constructs a singleton instance of [AudioStreamer].
  ///
  /// [AudioStreamer] is designed to work as a singleton.
  // When a second instance is created, the first instance will not be able to listen to the
  // audio because it is overridden. Forcing the class to be a singleton class can prevent
  // misuse of creating a second instance from a programmer.
  factory AudioStreamer() => _instance ??= AudioStreamer._();

  AudioStreamer._();

  /// The sampling rate in Hz. Must be set before the [audioStream] is used.
  /// Default sample rate of is 44100 Hz.
  /// Note that sampling rate can only be set on Android, not on iOS.
  int get sampleRate => _sampleRate;
  set sampleRate(int rate) {
    _sampleRate = rate;
    _stream = null;
  }

  /// The actual sampling rate.
  ///
  /// The actual sampling rate may be different from the requested sampling rate.
  /// Only available after sampling has started.
  Future<int> get actualSampleRate async =>
      await _sampleRateChannel.invokeMethod<int>('getSampleRate') ??
      DEFAULT_SAMPLING_RATE;

  /// The stream of audio samples.
  Stream<List<double>> get audioStream => _stream ??= _noiseEventChannel
      .receiveBroadcastStream({"sampleRate": sampleRate})
      .map((buffer) => buffer as List<dynamic>?)
      .map((list) => (list != null && list.isNotEmpty && list[0] is double)
          ? list.cast<double>()
          : list!.map((e) => e is double ? e : double.parse('$e')).toList());
}
