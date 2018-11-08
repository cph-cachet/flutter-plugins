import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'dart:io';
import 'dart:async';
import 'package:noise/noise.dart';

import 'package:path_provider/path_provider.dart';

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
  Noise _noise;

  String _recorderTxt = '00:00:00';

  @override
  void initState() {
    super.initState();
    _noise = new Noise();
  }

  void onData(NoiseEvent e) {
    print(e.toString());
  }

  Future<String> get _localPath async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String timestamp = DateTime.now()
        .toString()
        .replaceAll(" ", "-")
        .replaceAll(":", "-")
        .replaceAll("_", "-")
        .replaceAll(".", "-");
    return appDocDir.path + "/audio-$timestamp.m4a";
  }

  void startRecorder() async {
    try {
      String appDocPath = await _localPath;
      String path = await _noise.startRecorder(appDocPath);
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
      String result = await _noise.stopRecorder();
      print('stopRecorder: $result');

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
          title: const Text('Noise Plugin Example'),
        ),
        body: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 24.0, bottom: 16.0),
                  child: Text(
                    this._recorderTxt,
                    style: TextStyle(
                      fontSize: 48.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 56.0,
                  height: 56.0,
                  child: ClipOval(
                    child: FlatButton(
                      onPressed: () {
                        if (!this._isRecording) {
                          return this.startRecorder();
                        }
                        this.stopRecorder();
                      },
                      padding: EdgeInsets.all(8.0),
                      child: Image(
                        image: this._isRecording
                            ? AssetImage('icons/ic_stop.png')
                            : AssetImage('icons/ic_mic.png'),
                      ),
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
          ],
        ),
      ),
    );
  }
}
