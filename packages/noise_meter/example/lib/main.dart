import 'package:noise_meter/noise_meter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isRecording = false;
  StreamSubscription<NoiseEvent> _noiseSubscription;
  String _volumes;
  NoiseMeter _noiseMeter;

  @override
  void initState() {
    super.initState();
  }

  void onData(NoiseEvent e) {
    this.setState(() {
      this._volumes = e.volumes.toString();
      if (!this._isRecording) {
        this._isRecording = true;
      }
    });
    print(this._volumes);
  }

  void startRecorder() async {
    try {
      _noiseMeter = new NoiseMeter();
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } on NoiseMeterException catch (exception) {
      print(exception);
    }
  }

  void stopRecorder() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }
      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Noise Level Example"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Noise Level",
              ),
              Text(
                'MIC ${(_isRecording ? 'ON' : 'OFF')} \n(Check Flutter log for data)',
                style: Theme.of(context).textTheme.display1,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (!this._isRecording) {
                return this.startRecorder();
              }
              this.stopRecorder();
            },
            child: Icon(this._isRecording ? Icons.stop : Icons.mic)),
      ),
    );
  }
}
