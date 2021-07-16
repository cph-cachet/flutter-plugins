# Notifications

[![pub package](https://img.shields.io/pub/v/notifications.svg)](https://pub.dartlang.org/packages/notifications)

A plugin for monitoring notification on Android. 

## Install
Add `notifications` as a dependency in  `pubspec.yaml`.

For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

## Usage
All incoming data points are streamed with a `StreamSubscription` which is set up by calling the `listen()` method on the `notificationStream` stream object.

Given a method `onData(NotificationEvent event)` the subscription can be set up as follows:

```dart
Notifications _notifications;
StreamSubscription<NotificationEvent> _subscription;
...
void onData(NotificationEvent event) {
    print(event);
}

void startListening() {
    _notifications = new Notifications();
    try {
      _subscription = _notifications!.notificationStream!.listen(onData);
    } on NotificationException catch (exception) {
      print(exception);
    }
}
```

The stream can also be cancelled again by calling the `cancel()` method:

```dart
  void stopListening() {
    _subscription?.cancel();
  }
```

The `NotificationEvent` provides:

* the title
* the message
* package name
* timestamp

of each notification.