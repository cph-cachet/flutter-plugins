import 'package:flutter/material.dart';
import 'dart:async';
import 'package:health/health.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<HealthDataPoint> _healthDataList = List<HealthDataPoint>();
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    DateTime startDate = DateTime.utc(2001, 01, 01);
    DateTime endDate = DateTime.now();

    Future.delayed(Duration(seconds: 2), () async {
      _isAuthorized = await Health.requestAuthorization();

      if (_isAuthorized) {
        print('Authorized');

        bool weightAvailable =
            Health.isDataTypeAvailable(HealthDataType.WEIGHT);
        print("is WEIGHT data type available?: $weightAvailable");

        /// Specify the wished data types
        List<HealthDataType> types = [
          HealthDataType.WEIGHT,
          HealthDataType.HEIGHT,
          HealthDataType.STEPS,
          HealthDataType.BODY_MASS_INDEX,
          HealthDataType.WAIST_CIRCUMFERENCE,
          HealthDataType.BODY_FAT_PERCENTAGE,
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.BASAL_ENERGY_BURNED,
          HealthDataType.HEART_RATE,
          HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          HealthDataType.RESTING_HEART_RATE,
          HealthDataType.BLOOD_GLUCOSE,
          HealthDataType.BLOOD_OXYGEN,
        ];

        for (HealthDataType type in types) {
          /// Calls to 'Health.getHealthDataFromType'
          /// must be wrapped in a try catch block.b
          try {
            List<HealthDataPoint> healthData =
                await Health.getHealthDataFromType(startDate, endDate, type);
            _healthDataList.addAll(healthData);
          } catch (exception) {
            print(exception.toString());
          }
        }

        /// Print the results
        for (var x in _healthDataList) {
          print("Data point: $x");
        }

        /// Update the UI to display the results
        setState(() {});
      } else {
        print('Not authorized');
      }
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.sync),
              onPressed: () {
                initPlatformState();
              },
            )
          ],
        ),
        body: _healthDataList.isEmpty
            ? Text('No Data to show')
            : ListView.builder(
                itemCount: _healthDataList.length,
                itemBuilder: (_, index) => ListTile(
                      title: Text(
                          "${_healthDataList[index].dataType.toString()}: ${_healthDataList[index].value.toString()}"),
                      trailing: Text('${_healthDataList[index].unit}'),
                      subtitle: Text(
                          '${DateTime.fromMillisecondsSinceEpoch(_healthDataList[index].dateFrom)} - ${DateTime.fromMillisecondsSinceEpoch(_healthDataList[index].dateTo)}'),
                    )),
      ),
    );
  }
}
