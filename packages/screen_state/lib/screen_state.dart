import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

enum ScreenStateEvent { SCREEN_UNLOCKED, SCREEN_ON, SCREEN_OFF }

class Screen {
  EventChannel _eventChannel = const EventChannel('screenStateEvents');
  Stream<ScreenStateEvent> _screenStateStream;
  StreamSubscription<ScreenStateEvent> _screenStateStreamSubscription;

  /// Start tracking the screen state events, but only if on an Android device.
  void listen(void onData(ScreenStateEvent event),
      {Function onError, void onDone(), bool cancelOnError}) {
    if (Platform.isAndroid) {
      _screenStateStream = _eventChannel
          .receiveBroadcastStream()
          .map((event) => _parseScreenStateEvent(event));
      _screenStateStreamSubscription = _screenStateStream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: true);
    } else {
      print('[screen_state]: Screen state API not available on iOS!');
    }
  }

  /// Cancel the subscription, if it has been started.
  void cancel() {
    if (_screenStateStreamSubscription != null) {
      _screenStateStreamSubscription.cancel();
    }
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
