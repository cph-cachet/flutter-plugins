# screen_state
[![pub package](https://img.shields.io/pub/v/screen_state.svg)](https://pub.dartlang.org/packages/screen_state)

A Flutter plugin for tracking the screen state.

## Install
Add `screen_state` as a dependency in  `pubspec.yaml`.

For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

## Usage
All incoming data points are streamed with a `StreamSubscription` which is set up by calling the `listen()` method on the `screenStateStream` stream object.

Given a method `_onData(ScreenStateEvent event)` the subscription can be set up as follows:
```dart
Screen _screen;
StreamSubscription<ScreenStateEvent> _subscription;
...
void onData(ScreenStateEvent event) {
    print(event);
}

void startListening() {
    _screen = new Screen();
    try {
      _subscription = _screen.screenStateStream.listen(onData);
    } on ScreenStateException catch (exception) {
      print(exception);
    }
}
```

The stream can also be cancelled again by calling the `cancel()` method:

```dart
  void stopListening() {
    _subscription.cancel();
  }
```