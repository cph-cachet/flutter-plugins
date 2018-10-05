import 'dart:async';

import 'package:flutter/services.dart';

enum ScreenStateEvent { SCREEN_UNLOCKED, SCREEN_ON, SCREEN_OFF }

class Screen {
  EventChannel _eventChannel = const EventChannel('screenStateEvents');
  Stream<ScreenStateEvent> _onScreenStateEvent;

  Stream<ScreenStateEvent> get screenStateEvents {
    _onScreenStateEvent = _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _parseScreenStateEvent(event));
    return _onScreenStateEvent;
  }

  ScreenStateEvent _parseScreenStateEvent(String event) {
    switch (event) {
      /** Android **/
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
}
