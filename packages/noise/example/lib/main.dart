import 'package:flutter/material.dart';
import 'dart:async';
import 'package:noise/noise.dart';

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
  String _noiseLevel;
  Noise _noise;
  int myNumber = 0;

  @override
  void initState() {
    super.initState();
  }

  void onData(NoiseEvent e) {
    this.setState(() {
      this._noiseLevel = "${e.decibel} dB";
    });
  }

  void startRecorder() async {
    try {
      _noise = new Noise(500); // New observation every 500 ms
      _noiseSubscription = _noise.noiseStream.listen(onData);

      this.setState(() {
        this._isRecording = true;
      });
    } catch (err) {
      print('startRecorder error: $err');
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
                '$_noiseLevel',
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
            child: Icon(this._isRecording ? Icons.stop : Icons.mic)
        ),
      ),
    );
  }

}

