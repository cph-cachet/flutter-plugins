import 'dart:async';

import 'package:flutter/services.dart';

enum ScreenEvent { SCREEN_UNLOCKED, SCREEN_ON, SCREEN_OFF }

class Screen {
  EventChannel _eventChannel = const EventChannel('screenEvents');
  Stream<ScreenEvent> _onScreenEvent;

  Stream<ScreenEvent> get screenEvents {
    _onScreenEvent = _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _parseScreenEvent(event));
    return _onScreenEvent;
  }

  ScreenEvent _parseScreenEvent(String event) {
    switch (event) {
      /** Android **/
      case 'android.intent.action.SCREEN_OFF':
        return ScreenEvent.SCREEN_OFF;
      case 'android.intent.action.SCREEN_ON':
        return ScreenEvent.SCREEN_ON;
      case 'android.intent.action.USER_PRESENT': /*** PRESENT == unlocked ***/
        return ScreenEvent.SCREEN_UNLOCKED;

      /** iOS **/
//      case 'IOS_SCREEN_UNLOCKED':
//        return ScreenEvent.SCREEN_UNLOCKED;
//      case 'IOS_SCREEN_LOCKED':
//        return ScreenEvent.SCREEN_OFF;

      default:
        throw new ArgumentError('$event was not recognized.');
    }
  }
}
