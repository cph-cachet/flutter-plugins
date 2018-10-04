# flutter_light_example

A pedometer plugin for retrieving the light sensor data in Lux. Works for Android only, since the light sensor API is not available on iOS.
## Usage
```dart
class MyClass {
  String _luxString = 'Unknown';
  StreamSubscription<int> _subscription;
  Light _light;
      
    // Platform messages are asynchronous, so we initialize in an async method.
    void someSetupFunction() {
      _light = new Light();
     _subscription = _light.lightSensorStream.listen(_onData,
             onError: _onError, onDone: _onDone, cancelOnError: true);
    }
    
    void _onData(int luxValue) async {
    // Do something with the luxValue
    }
    
    void _onDone() {
    // Handle finish
    }
    
    void _onError(error) {
    // Handle the error
    }
}
  
```
