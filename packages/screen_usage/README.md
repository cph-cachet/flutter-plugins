# Screen Usage
Supported operating systems (*as of September 10th 2018*)
* Android: ✔
* iOS: ✖

## Events
Registers the following events (*also while the application is running in the background)*:
* `SCREEN_UNLOCKED`
* `SCREEN_ON`
* `SCREEN_OFF`

# Usage
```dart
class Class {
  Screen _screenListener = new Screen();
  ScreenEvent _screenEvent;
  StreamSubscription<ScreenEvent> _screenEventSubscription;
  
  ...
  
  void function() {
    ...
     _screenEventSubscription =
        _screenListener.screenEvents.listen((ScreenEvent event) {
          setState(() {
            _screenEvent = event;
            /// Use _screenEvent
          });
        });
     ...
  }
}
```