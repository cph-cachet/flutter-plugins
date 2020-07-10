import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobility_features/mobility_features.dart';

void main() => runApp(MyApp());

String formatDate(DateTime date) {
  return '${date.year}/${date.month}/${date.day}';
}

enum AppState { NO_FEATURES, CALCULATING_FEATURES, FEATURES_READY }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Mobility Features Demo'),
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
  String location = '';
  StreamSubscription subscription;
  MobilityFactory mobilityFactory = MobilityFactory.instance;
  AppState _state = AppState.NO_FEATURES;
  MobilityContext _mobilityContext;

  @override
  void initState() {
    setUpLocationStream();
    mobilityFactory.stopDuration = Duration(seconds: 1);
    mobilityFactory.placeRadius = 50;
    mobilityFactory.stopRadius = 25;
  }

  void setUpLocationStream() {
    Stream<Position> positionStream =
        Geolocator().getPositionStream().asBroadcastStream();

    Stream<LocationSample> locationSampleStream = positionStream.map((e) =>
        LocationSample(GeoPosition(e.latitude, e.longitude), e.timestamp));

    mobilityFactory.startListening(locationSampleStream);
    subscription = positionStream.listen(onData);
  }

  void onData(Position p) {
    print(p);
    setState(() {
      location = p.toString();
    });
  }

  Widget entry(String key, String value, IconData icon) {
    return Container(
        padding: const EdgeInsets.all(2),
        margin: EdgeInsets.all(3),
        child: ListTile(
          leading: Icon(icon),
          title: Text(key),
          trailing: Text(value),
        ));
  }

  Widget get featuresOverview {
    return ListView(
      children: <Widget>[
        entry(
            "Routine Index",
            _mobilityContext.routineIndex < 0
                ? "?"
                : "${(_mobilityContext.routineIndex * 100).toStringAsFixed(1)}%",
            Icons.repeat),
        entry(
            "Home Stay",
            _mobilityContext.homeStay < 0
                ? "?"
                : "${(_mobilityContext.homeStay * 100).toStringAsFixed(1)}%",
            Icons.home),
        entry(
            "Distance Travelled",
            "${(_mobilityContext.distanceTravelled / 1000).toStringAsFixed(2)} km",
            Icons.directions_walk),
        entry("Significant Places", "${_mobilityContext.numberOfPlaces}",
            Icons.place),
        entry(
            "Normalized Entropy",
            "${_mobilityContext.normalizedEntropy.toStringAsFixed(2)}",
            Icons.equalizer),
        entry(
            "Location Variance",
            "${(111.133 * _mobilityContext.locationVariance).toStringAsFixed(5)} km",
            Icons.crop_rotate),
      ],
    );
  }

  List<Widget> get contentNoFeatures {
    return [
      Container(
          margin: EdgeInsets.all(25),
          child: Text(
            'Click on the refresh button to generate features',
            style: TextStyle(fontSize: 20),
          ))
    ];
  }

  List<Widget> get contentFeaturesReady {
    return [
      Container(
          margin: EdgeInsets.all(25),
          child: Column(children: [
            Text(
              'Statistics for today,',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '${formatDate(_mobilityContext.date)}',
              style: TextStyle(fontSize: 20, color: Colors.blue),
            ),
          ])),
      Expanded(child: featuresOverview)
    ];
  }

  List<Widget> get contentCalculatingFeatures {
    return [
      Container(
          margin: EdgeInsets.all(25),
          child: Column(children: [
            Text(
              'Calculating features...',
              style: TextStyle(fontSize: 20),
            ),
            Container(
                margin: EdgeInsets.only(top: 50),
                child:
                    Center(child: CircularProgressIndicator(strokeWidth: 10)))
          ]))
    ];
  }

  List<Widget> get content {
    if (_state == AppState.FEATURES_READY)
      return contentFeaturesReady;
    else if (_state == AppState.CALCULATING_FEATURES)
      return contentCalculatingFeatures;
    else
      return contentNoFeatures;
  }

  void _updateFeatures() async {
    if (_state == AppState.CALCULATING_FEATURES) {
      print('Already calculating features!');
      return;
    }

    setState(() {
      _state = AppState.CALCULATING_FEATURES;
    });

    print('Calculating features...');

    DateTime start = DateTime.now();
    MobilityContext mc = await mobilityFactory.computeFeatures();
    DateTime end = DateTime.now();
    Duration dur = Duration(milliseconds: end.millisecondsSinceEpoch - start.millisecondsSinceEpoch);
    print('Computed features in $dur');
    setState(() {
      _mobilityContext = mc;
      _state = AppState.FEATURES_READY;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(children: content),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateFeatures,
        tooltip: 'Calculate features',
        child: Icon(Icons.refresh),
      ), //  This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
