# screen_state
[![pub package](https://img.shields.io/pub/v/screen_state.svg)](https://pub.dartlang.org/packages/screen_state)

A Flutter plugin for tracking the screen state.

## Install
Add ```screen_state``` as a dependency in  `pubspec.yaml`.
For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

## Example Usage
Instantiate a Screen object (no parameters needed):

```dart
Screen screen = new Screen();
```

Screen State events can be streamed by calling the `listen()` method on a `Screen`
object, using an onData method for handling incoming events:

```dart
screen.listen(onData);
```

An example of the `onData()` method is:

```dart  
onData(ScreenStateEvent event) {
    print(event);
}
```
  
The subscription can be cancelled again, by invoking the `cancel` method:
`screen.cancel();`