import 'package:flutter/material.dart';
import 'package:air_quality/air_quality.dart';

enum AppState { NOT_DOWNLOADED, DOWNLOADING, FINISHED_DOWNLOADING }

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Quality Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _content = 'Unknown';
  String _key = '9e538456b2b85c92647d8b65090e29f957638c77';
  AirQuality _airQuality;
  AppState _state = AppState.NOT_DOWNLOADED;
  List<AirQualityData> _data;

  @override
  void initState() {
    super.initState();
    _airQuality = new AirQuality(_key);
  }

  Future download() async {
    _data = [];

    setState(() {
      _state = AppState.DOWNLOADING;
    });

    /// Via city name (Munich)
    AirQualityData feedFromCity = await _airQuality.feedFromCity('munich');

    /// Via station ID (Gothenburg weather station)
    AirQualityData feedFromStationId =
    await _airQuality.feedFromStationId('7867');

    /// Via Geo Location (Berlin)
    AirQualityData feedFromGeoLocation =
    await _airQuality.feedFromGeoLocation(52.6794, 12.5346);


    /// Via IP (depends on service provider)
    AirQualityData fromIP = await _airQuality.feedFromIP();

    // Update screen state
    setState(() {
      _data.add(feedFromCity);
      _data.add(feedFromStationId);
      _data.add(feedFromGeoLocation);
    });

    setState(() {
      _state = AppState.FINISHED_DOWNLOADING;
    });
  }

  Widget contentFinishedDownload() {
    return Center(
      child: ListView.separated(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_data[index].toString()),

          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      ),
    );
  }

  Widget contentDownloading() {
    return Container(
        margin: EdgeInsets.all(25),
        child: Column(children: [
          Text(
            'Fetching Air Quality...',
            style: TextStyle(fontSize: 20),
          ),
          Container(
              margin: EdgeInsets.only(top: 50),
              child: Center(child: CircularProgressIndicator(strokeWidth: 10)))
        ]));
  }

  Widget contentNotDownloaded() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Press the button to download the Air Quality',
          ),
        ],
      ),
    );
  }

  Widget showContent() => _state == AppState.FINISHED_DOWNLOADING
      ? contentFinishedDownload()
      : _state == AppState.DOWNLOADING
      ? contentDownloading()
      : contentNotDownloaded();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: showContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: download,
        tooltip: 'Download',
        child: Icon(Icons.cloud_download),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
