import 'package:noise_meter/noise_meter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isRecording = false;
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter(onError);
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  void onData(NoiseReading noiseReading) {
    this.setState(() {
      _latestReading = noiseReading;
      if (!this._isRecording) this._isRecording = true;
    });
  }

  void onError(Object error) {
    print(error);
    _isRecording = false;
  }

  void start() {
    try {
      _noiseSubscription = _noiseMeter?.noise.listen(onData);
    } catch (err) {
      print(err);
    }
  }

  void stop() {
    try {
      _noiseSubscription?.cancel();
      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print(err);
    }
  }

  List<Widget> getContent() => <Widget>[
        Container(
            margin: EdgeInsets.all(25),
            child: Column(children: [
              Container(
                child: Text(_isRecording ? "Mic: ON" : "Mic: OFF",
                    style: TextStyle(fontSize: 25, color: Colors.blue)),
                margin: EdgeInsets.only(top: 20),
              ),
              Container(
                child: Text(
                  'Noise: ${_latestReading?.meanDecibel} dB',
                ),
                margin: EdgeInsets.only(top: 20),
              ),
              Container(
                child: Text(
                  'Max: ${_latestReading?.maxDecibel} dB',
                ),
              )
            ])),
      ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: getContent())),
        floatingActionButton: FloatingActionButton(
            backgroundColor: _isRecording ? Colors.red : Colors.green,
            onPressed: _isRecording ? stop : start,
            child: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic)),
      ),
    );
  }
}
