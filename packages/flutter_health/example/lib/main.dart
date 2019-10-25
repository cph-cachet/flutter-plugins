import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_health/flutter_health.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _healthKitOutput;
  var _healthDataList = List<HealthData>();
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    DateTime startDate = DateTime.utc(2019, 07, 01);
    DateTime endDate = DateTime.now();

    Future.delayed(Duration(seconds: 2), () async {
      _isAuthorized = await FlutterHealth.requestAuthorization();
      var isHealthDataAvailable = await FlutterHealth.checkIfHealthDataAvailable();


      if (_isAuthorized) {
        print('Authorized');
        print("Health Data Available? $isHealthDataAvailable");

/*        _healthDataList
            .addAll(await FlutterHealth.getAllHealthData(startDate, endDate));*/
        _healthDataList
          ..addAll(await FlutterHealth.getStepCount(startDate, endDate))
          ..addAll(await FlutterHealth.getWaistCircumference(startDate, endDate))
          ..addAll(await FlutterHealth.getBodyFatPercentage(startDate, endDate))
          ..addAll(await FlutterHealth.getBodyMassIndex(startDate, endDate))
          ..addAll(await FlutterHealth.getHeight(startDate, endDate))
          ..addAll(await FlutterHealth.getBodyFatPercentage(startDate, endDate))
          ..addAll(await FlutterHealth.getActiveEnergyBurned(startDate, endDate))
          ..addAll(await FlutterHealth.getBasalEnergyBurned(startDate, endDate))
          ..addAll(await FlutterHealth.getHeartRate(startDate, endDate))
          ..addAll(await FlutterHealth.getBloodPressureDiastolic(startDate, endDate))
          ..addAll(await FlutterHealth.getBloodPressureSystolic(startDate, endDate))
          ..addAll(await FlutterHealth.getRestingHeartRate(startDate, endDate))
          ..addAll(await FlutterHealth.getBloodGlucose(startDate, endDate))
          ..addAll(await FlutterHealth.getBloodOxygen(startDate, endDate));
        setState(() {});
      } else {
        print('Not authorized');
      }
    });

    print('Authorized: $_isAuthorized');
    for (var x in _healthDataList) print(x.toJson());

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
            ? Text('$_healthKitOutput\n')
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
