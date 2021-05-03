library mobility_app;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carp_background_location/carp_background_location.dart';
import 'package:mobility_features/mobility_features.dart';

part 'stops_page.dart';

part 'moves_page.dart';

part 'places_page.dart';

void main() => runApp(MyApp());

Widget entry(String key, String value, Icon icon) {
  return Container(
      padding: const EdgeInsets.all(2),
      margin: EdgeInsets.all(3),
      child: ListTile(
        leading: icon,
        title: Text(key),
        trailing: Text(value),
      ));
}

String formatDate(DateTime date) {
  return '${date.year}/${date.month}/${date.day}';
}

String interval(DateTime a, DateTime b) {
  String pad(int x) => '${x.toString().padLeft(2, '0')}';
  return '${pad(a.hour)}:${pad(a.minute)}:${pad(a.second)} - ${pad(b.hour)}:${pad(b.minute)}:${pad(b.second)}';
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

final stopIcon = Icon(Icons.my_location);
final moveIcon = Icon(Icons.directions_walk);
final placeIcon = Icon(Icons.place);
final featuresIcon = Icon(Icons.assessment);
final homeStayIcon = Icon(Icons.home);
final distanceTravelledIcon = Icon(Icons.card_travel);
final entropyIcon = Icon(Icons.equalizer);
final varianceIcon = Icon(Icons.swap_calls);

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

  int _currentIndex = 0;

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
    super.initState();

    /// Set up Mobility Features
    mobilityFactory.stopDuration = Duration(seconds: 20);
    mobilityFactory.placeRadius = 50.0;
    mobilityFactory.stopRadius = 5.0;

    /// Setup Location Manager
    locationManager.distanceFilter = 0;
    locationManager.interval = 1;
    locationManager.notificationTitle = 'Mobility Features';
    locationManager.notificationMsg = 'Your geo-location is being tracked';
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
    /// Set up streams:
    /// * Subscribe to stream in case it is already running (Android only)
    /// * Subscribe to MobilityContext updates
    dtoStream = locationManager.dtoStream;
    dtoSubscription = dtoStream.listen(onData);

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

  Widget get featuresOverview {
    return ListView(
      children: <Widget>[
        entry("Stops", "${_mobilityContext.stops.length}", stopIcon),
        entry("Moves", "${_mobilityContext.moves.length}", moveIcon),
        entry("Significant Places",
            "${_mobilityContext.numberOfSignificantPlaces}", placeIcon),
        entry(
            "Home Stay",
            _mobilityContext.homeStay < 0
                ? "?"
                : "${(_mobilityContext.homeStay * 100).toStringAsFixed(1)}%",
            homeStayIcon),
        entry(
            "Distance Travelled",
            "${(_mobilityContext.distanceTravelled / 1000).toStringAsFixed(2)} km",
            distanceTravelledIcon),
        entry(
            "Normalized Entropy",
            "${_mobilityContext.normalizedEntropy.toStringAsFixed(2)}",
            entropyIcon),
        entry(
            "Location Variance",
            "${(111.133 * _mobilityContext.locationVariance).toStringAsFixed(5)} km",
            varianceIcon),
      ],
    );
  }

  List<Widget> get contentNoFeatures {
    return [
      Container(
          margin: EdgeInsets.all(25),
          child: Text(
            'Move around to start generating features',
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
      Expanded(child: featuresOverview),
    ];
  }

  Widget get content {
    List<Widget> children;
    if (_state == AppState.FEATURES_READY)
      children = contentFeaturesReady;
    else
      children = contentNoFeatures;
    return Column(children: children);
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _navBar() {
    return BottomNavigationBar(
      onTap: onTabTapped, // new
      currentIndex: _currentIndex, // this will be set when a new tab is tapped
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: featuresIcon,
          title: new Text('Features'),
        ),
        BottomNavigationBarItem(
          icon: stopIcon,
          title: new Text('Stops'),
        ),
        BottomNavigationBarItem(
          icon: placeIcon,
          title: new Text('Places'),
        ),
        BottomNavigationBarItem(icon: moveIcon, title: Text('Moves'))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Stop> stops = [];
    List<Move> moves = [];
    List<Place> places = [];

    if (_mobilityContext != null) {
      for (var x in _mobilityContext.stops) print(x);
      for (var x in _mobilityContext.moves) {
        print(x);
        print('${x.stopFrom} --> ${x.stopTo}');
      }
      stops = _mobilityContext.stops;
      moves = _mobilityContext.moves;
      places = _mobilityContext.places;
    }

    List<Widget> pages = [
      content,
      StopsPage(stops),
      PlacesPage(places),
      MovesPage(moves),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: _navBar(),
    );
  }
}
