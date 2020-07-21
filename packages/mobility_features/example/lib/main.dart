import 'dart:async';
import 'package:flutter/material.dart';

import 'package:mubs_background_location/mubs_background_location.dart';
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

String dtoToString(LocationDto dto) =>
    '${dto.latitude}, ${dto.longitude} @ ${DateTime.fromMillisecondsSinceEpoch(dto.time ~/ 1)}';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AppState _state = AppState.NO_FEATURES;

  /// Location Streaming
  LocationManager locationManager = LocationManager.instance;
  Stream<LocationDto> dtoStream;
  StreamSubscription<LocationDto> dtoSubscription;

  /// Mobility Features stream
  StreamSubscription<MobilityContext> mobilitySubscription;
  MobilityFactory mobilityFactory = MobilityFactory.instance;
  MobilityContext _mobilityContext;

  @override
  void initState() {
    /// Set up Mobility Features
    mobilityFactory.stopDuration = Duration(seconds: 30);
    mobilityFactory.placeRadius = 20;
    mobilityFactory.stopRadius = 5;

    /// Setup Location Manager
    locationManager.interval = 1;
    locationManager.distanceFilter = 0;
    locationManager.notificationTitle = 'Mobility Features';
    locationManager.notificationMsg = 'Your geo-location is being tracked';

    /// Set up streams:
    /// * Subscribe to stream in case it is already running (Android only)
    /// * Subscribe to MobilityContext updates
    dtoStream = locationManager.dtoStream;
    dtoSubscription = dtoStream.listen(onData);
    streamInit();
  }

  void onMobilityContext(MobilityContext context) {
    print('Context received: ${context.toJson()}');
    setState(() {
      _state = AppState.FEATURES_READY;
      _mobilityContext = context;
    });
  }

  void streamInit() async {
    // Subscribe if it hasn't been done already
    if (dtoSubscription != null) {
      dtoSubscription.cancel();
    }
    dtoSubscription = dtoStream.listen(onData);
    await locationManager.start();

    Stream<LocationSample> locationSampleStream = dtoStream.map((e) =>
        LocationSample(GeoLocation(e.latitude, e.longitude), DateTime.now()));

    mobilityFactory.startListening(locationSampleStream);
    mobilitySubscription =
        mobilityFactory.contextStream.listen(onMobilityContext);
  }

  void onData(LocationDto dto) {
    print(dtoToString(dto));
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
        entry("Stops", "${_mobilityContext.stops.length}",
            Icons.airline_seat_recline_normal),
        entry(
            "Moves", "${_mobilityContext.moves.length}", Icons.directions_run),
        entry("Significant Places", "${_mobilityContext.numberOfPlaces}",
            Icons.place),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(children: content),
    );
  }
}
