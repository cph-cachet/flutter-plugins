import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

/// The type of screen state events coming from Android or iOS.
enum ScreenStateEvent { SCREEN_LOCKED, SCREEN_UNLOCKED, SCREEN_ON, SCREEN_OFF }

/// Custom Exception for the `screen_state` plugin, used whenever the plugin
class ScreenStateException implements Exception {
  String _cause;

  ScreenStateException(this._cause);

  @override
  String toString() => '$runtimeType - $_cause';
}

/// Screen representation as object which holds the stream for [ScreenStateEvent]s.
class Screen {
  static Screen? _singleton;
  EventChannel _eventChannel = const EventChannel('screenStateEvents');
  Stream<ScreenStateEvent>? _screenStateStream;
  ScreenStateEvent? _lastScreenState;

  /// Constructs a singleton instance of [Screen].
  ///
  /// [Screen] is designed to work as a singleton.
  factory Screen() => _singleton ??= Screen._();

  Screen._();

  /// Stream of [ScreenStateEvent]s.
  /// Each event is streamed as it occurs on the phone.
  /// Only Android [ScreenStateEvent] are streamed.
  Stream<ScreenStateEvent>? get screenStateStream {
    if (Platform.isAndroid) {
      if (_screenStateStream == null) {
        _screenStateStream = _eventChannel
            .receiveBroadcastStream()
            .map((event) => _parseAndroidScreenStateEvent(event));
      }
      return _screenStateStream;
    } else if (Platform.isIOS) {
      if (_screenStateStream == null) {
        _screenStateStream = _eventChannel
            .receiveBroadcastStream(
          _lastScreenState != null
              ? [
            _parseIosScreenStateEventToString(_lastScreenState!),
          ]
              : [],
        )
            .map(
              (event) {
            final screenState = _parseIosScreenStateEvent(event);
            _lastScreenState = screenState;
            return screenState;
          },
        );
      }
      return _screenStateStream;
    }
    throw ScreenStateException(
        'Screen State API only available on Android and iOS.');
  }

  ScreenStateEvent _parseAndroidScreenStateEvent(String event) {
    switch (event) {
      case 'android.intent.action.SCREEN_OFF':
        return ScreenStateEvent.SCREEN_OFF;
      case 'android.intent.action.SCREEN_ON':
        return ScreenStateEvent.SCREEN_ON;
      case 'android.intent.action.USER_PRESENT':
        return ScreenStateEvent.SCREEN_UNLOCKED;
      default:
        throw new ArgumentError('$event was not recognized.');
    }
  }

  ScreenStateEvent _parseIosScreenStateEvent(String event) {
    switch (event) {
      case 'SCREEN_OFF':
        return ScreenStateEvent.SCREEN_OFF;
      case 'SCREEN_ON':
        return ScreenStateEvent.SCREEN_ON;
      case 'UNLOCKED':
        return ScreenStateEvent.SCREEN_UNLOCKED;
      case 'LOCKED':
        return ScreenStateEvent.SCREEN_LOCKED;
      default:
        throw new ArgumentError('$event was not recognized.');
    }
  }

  String _parseIosScreenStateEventToString(ScreenStateEvent event) {
    switch (event) {
      case ScreenStateEvent.SCREEN_OFF:
        return 'SCREEN_OFF';
      case ScreenStateEvent.SCREEN_ON:
        return 'SCREEN_ON';
      case ScreenStateEvent.SCREEN_UNLOCKED:
        return 'UNLOCKED';
      case ScreenStateEvent.SCREEN_LOCKED:
        return 'LOCKED';
      default:
        throw new ArgumentError('$event was not recognized.');
    }
  }
}