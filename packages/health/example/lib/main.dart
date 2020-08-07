import 'package:flutter/material.dart';
import 'dart:async';
import 'package:health/health.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum AppState { DATA_NOT_FETCHED, FETCHING_DATA, DATA_READY, NO_DATA }

class _MyAppState extends State<MyApp> {
  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;

  DateTime startDate = DateTime.utc(2001, 01, 01);
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchData() async {
    setState(() {
      _state = AppState.FETCHING_DATA;
    });

    /// Specify the wished data types
    List<HealthDataType> types = [
      HealthDataType.BODY_MASS_INDEX,
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
    ];

    HealthFactory health = HealthFactory(types);
    final typesToGet = types + [HealthDataType.MOVE_MINUTES];

    for (HealthDataType type in typesToGet) {
      /// Calls must be wrapped in a try catch block
      try {
        /// Fetch new data
        List<HealthDataPoint> healthData =
            await health.getHealthDataFromType(startDate, endDate, type);

        /// Save all the new data points
        _healthDataList.addAll(healthData);

        /// Filter out duplicates based on their UUID
        _healthDataList = HealthFactory.removeDuplicates(_healthDataList);
      } catch (exception) {
        print("An exception occured");
        print(exception.toString());
      }
    }

    /// Print the results
    typesToGet.forEach((x) => print("Data point: $x"));

    /// Update the UI to display the results
    setState(() {
      _state = _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
    });
  }

  Widget _contentFetchingData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              strokeWidth: 10,
            )),
        Text('Fetching data...')
      ],
    );
  }

  Widget _contentDataReady() {
    return ListView.builder(
        itemCount: _healthDataList.length,
        itemBuilder: (_, index) {
          HealthDataPoint p = _healthDataList[index];
          return ListTile(
            title: Text("${p.typeString}: ${p.value}"),
            trailing: Text('${p.unitString}'),
            subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
          );
        });
  }

  Widget _contentNoData() {
    return Text('No Data to show');
  }

  Widget _contentNotFetched() {
    return Text('Press the download button to fetch data');
  }

  Widget _content() {
    if (_state == AppState.DATA_READY)
      return _contentDataReady();
    else if (_state == AppState.NO_DATA)
      return _contentNoData();
    else if (_state == AppState.FETCHING_DATA) return _contentFetchingData();

    return _contentNotFetched();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.file_download),
                onPressed: () {
                  fetchData();
                },
              )
            ],
          ),
          body: Center(
            child: _content(),
          )),
    );
  }
}
