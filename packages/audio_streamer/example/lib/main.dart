import 'package:flutter/material.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'dart:math';

import 'package:flutter/services.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioStreamer _streamer = AudioStreamer();
  bool _isRecording = false;
  List<double> _audio = [];

  @override
  void initState() {
    super.initState();
  }

  void onAudio(List<double> buffer) async {
    _audio.addAll(buffer);
    var sampleRate = await AudioStreamer.currSampleRate;
    double secondsRecorded = _audio.length.toDouble() / sampleRate;
    print('Max amp: ${buffer.reduce(max)}');
    print('Min amp: ${buffer.reduce(min)}');
    print('$secondsRecorded seconds recorded.');
    print('-' * 50);
  }

  void handleError(PlatformException error) {
    setState(() {
      _isRecording = false;
    });
    print(error.message);
    print(error.details);
  }

  void start() async {
    try {
      //_streamer.start(onAudio, handleError, sampleRate: 16000); //uses custom sample rate
      _streamer.start(
          onAudio, handleError); //uses default sample rate of 44100 Hz
      setState(() {
        _isRecording = true;
      });
    } catch (error) {
      print(error);
    }
  }

  void stop() async {
    bool stopped = await _streamer.stop();
    setState(() {
      _isRecording = stopped;
    });
  }

  List<Widget> getContent() => <Widget>[
        Container(
            margin: EdgeInsets.all(25),
            child: Column(children: [
              Container(
                child: Text(_isRecording ? "Mic: ON" : "Mic: OFF",
                    style: TextStyle(fontSize: 25, color: Colors.blue)),
                margin: EdgeInsets.only(top: 20),
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
