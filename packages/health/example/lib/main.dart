import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(HealthApp());

class HealthApp extends StatefulWidget {
  @override
  _HealthAppState createState() => _HealthAppState();
}

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_DELETED,
  DATA_NOT_ADDED,
  DATA_NOT_DELETED,
  STEPS_READY,
}

class _HealthAppState extends State<HealthApp> {
  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  int _nofSteps = 10;
  double _mgdl = 10.0;

  // create a HealthFactory for use in the app
  HealthFactory health = HealthFactory();

  /// Fetch data points from the health plugin and show them in the app.
  Future fetchData() async {
    setState(() => _state = AppState.FETCHING_DATA);

    // define the types to get
    final types = [
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      HealthDataType.BLOOD_GLUCOSE,
      HealthDataType.WORKOUT,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      // Uncomment these lines on iOS - only available on iOS
      // HealthDataType.AUDIOGRAM
    ];

    // with coresponsing permissions
    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      // HealthDataAccess.READ,
    ];

    // get data within the last 24 hours
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(hours: 24));

    // If we are trying to read Step Count, Workout, Sleep or other data that requires
    // the ACTIVITY_RECOGNITION permission, we need to request the permission first.
    // This requires a special request authorization call.
    //
    // The location permission is requested for Workouts using the Distance information.
    await Permission.activityRecognition.request();
    await Permission.location.request();

    // requesting access to the data types before reading them
    // note that strictly speaking, the [permissions] are not
    // needed, since we only want READ access.
    bool requested =
        await health.requestAuthorization(types, permissions: permissions);
    print('requested: $requested');

    // Clear old data points
    _healthDataList.clear();

    if (requested) {
      try {
        // fetch health data
        List<HealthDataPoint> healthData =
            await health.getHealthDataFromTypes(yesterday, now, types);
        // save all the new data points (only the first 100)
        _healthDataList.addAll((healthData.length < 100)
            ? healthData
            : healthData.sublist(0, 100));
      } catch (error) {
        print("Exception in getHealthDataFromTypes: $error");
      }

      // filter out duplicates
      _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

      // print the results
      _healthDataList.forEach((x) => print(x));

      // update the UI to display the results
      setState(() {
        _state =
            _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
      });
    } else {
      print("Authorization not granted");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  /// Add some random health data.
  Future addData() async {
    final now = DateTime.now();
    final earlier = now.subtract(Duration(minutes: 20));

    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEIGHT,
      HealthDataType.BLOOD_GLUCOSE,
      HealthDataType.WORKOUT, // Requires Google Fit on Android
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      // Uncomment these lines on iOS - only available on iOS
      // HealthDataType.AUDIOGRAM,
    ];
    final permissions = [
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      // HealthDataAccess.READ_WRITE,
    ];

    bool? hasPermissions =
        await HealthFactory.hasPermissions(types, permissions: permissions);
    // hasPermissions = false because the getData method only requests READ,
    // and the hasPermission cannot disclose if WRITE access exists.
    hasPermissions = false;
    if (hasPermissions == false) {
      await health.requestAuthorization(types, permissions: permissions);
    }

    // Store a count of steps taken
    _nofSteps = Random().nextInt(10);
    bool success = await health.writeHealthData(
        _nofSteps.toDouble(), HealthDataType.STEPS, earlier, now);

    // Store a height
    success &=
        await health.writeHealthData(1.93, HealthDataType.HEIGHT, earlier, now);

    // Store a Blood Glucose measurement
    _mgdl = Random().nextInt(10) * 1.0;
    success &= await health.writeHealthData(
        _mgdl, HealthDataType.BLOOD_GLUCOSE, now, now);

    success &= await health.writeBloodPressure(120, 90, now, now);

    // Store a workout eg. running
    success &= await health.writeWorkoutData(
      HealthWorkoutActivityType.RUNNING,
      earlier,
      now,
      // The following are optional parameters
      // and the UNITS are functional on iOS ONLY!
      totalEnergyBurned: 230,
      totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
      totalDistance: 1234,
      totalDistanceUnit: HealthDataUnit.FOOT,
    );

    // success &= await health.writeHealthData(
    //     3, HealthDataType.SLEEP_ASLEEP, now.subtract(Duration(hours: 3)), now);

    // Store an Audiogram
    // Uncomment these on iOS - only available on iOS
    // const frequencies = [125.0, 500.0, 1000.0, 2000.0, 4000.0, 8000.0];
    // const leftEarSensitivities = [49.0, 54.0, 89.0, 52.0, 77.0, 35.0];
    // const rightEarSensitivities = [76.0, 66.0, 90.0, 22.0, 85.0, 44.5];

    // success &= await health.writeAudiogram(
    //   frequencies,
    //   leftEarSensitivities,
    //   rightEarSensitivities,
    //   now,
    //   now,
    //   metadata: {
    //     "HKExternalUUID": "uniqueID",
    //     "HKDeviceName": "bluetooth headphone",
    //   },
    // );

    setState(() {
      _state = success ? AppState.DATA_ADDED : AppState.DATA_NOT_ADDED;
    });
  }

  /// Delete some random health data.
  Future deleteData() async {
    final now = DateTime.now();
    final earlier = now.subtract(Duration(hours: 24));

    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEIGHT,
      HealthDataType.BLOOD_GLUCOSE,
      HealthDataType.WORKOUT, // Requires Google Fit on Android
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      // Uncomment these lines on iOS - only available on iOS
      // HealthDataType.AUDIOGRAM,
    ];
    final permissions = [
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      // HealthDataAccess.READ_WRITE,
    ];
    bool? hasPermissions =
        await HealthFactory.hasPermissions(types, permissions: permissions);
    // hasPermissions = false because the getData method only requests READ,
    // and the hasPermission cannot disclose if WRITE access exists.
    hasPermissions = false;
    if (hasPermissions == false) {
      await health.requestAuthorization(types, permissions: permissions);
    }

    bool success = false;

    success = await health.delete(HealthDataType.STEPS, earlier, now);
    success &= await health.delete(HealthDataType.HEIGHT, earlier, now);
    success &= await health.delete(HealthDataType.BLOOD_GLUCOSE, earlier, now);
    success &= await health.delete(HealthDataType.WORKOUT, earlier, now);
    success &= await health.delete(
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        earlier,
        now); // on Android this deletes both systolic and diastolic measurements.

    setState(() {
      _state = success ? AppState.DATA_DELETED : AppState.DATA_NOT_DELETED;
    });
  }

  /// Fetch steps from the health plugin and show them in the app.
  Future fetchStepData() async {
    int? steps;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);

    if (requested) {
      try {
        steps = await health.getTotalStepsInInterval(midnight, now);
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }

      print('Total number of steps: $steps');

      setState(() {
        _nofSteps = (steps == null) ? 0 : steps;
        _state = (steps == null) ? AppState.NO_DATA : AppState.STEPS_READY;
      });
    } else {
      print("Authorization not granted - error in authorization");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  Future revokeAccess() async {
    await health.revokePermissions();
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
          if (p.value is AudiogramHealthValue) {
            return ListTile(
              title: Text("${p.typeString}: ${p.value}"),
              trailing: Text('${p.unitString}'),
              subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
            );
          }
          if (p.value is WorkoutHealthValue) {
            return ListTile(
              title: Text(
                  "${p.typeString}: ${(p.value as WorkoutHealthValue).totalEnergyBurned} ${(p.value as WorkoutHealthValue).totalEnergyBurnedUnit?.name}"),
              trailing: Text(
                  '${(p.value as WorkoutHealthValue).workoutActivityType.name}'),
              subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
            );
          }
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
    return Column(
      children: [
        Text('Press the download button to fetch data.'),
        Text('Press the plus button to insert some random data.'),
        Text('Press the walking button to get total step count.'),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _authorizationNotGranted() {
    return Text('Authorization not given. '
        'For Android please check your OAUTH2 client ID is correct in Google Developer Console. '
        'For iOS check your permissions in Apple Health.');
  }

  Widget _dataAdded() {
    return Text('Data points inserted successfully!');
  }

  Widget _dataDeleted() {
    return Text('Data points deleted successfully!');
  }

  Widget _stepsFetched() {
    return Text('Total number of steps: $_nofSteps');
  }

  Widget _dataNotAdded() {
    return Text('Failed to add data');
  }

  Widget _dataNotDeleted() {
    return Text('Failed to delete data');
  }

  Widget _content() {
    if (_state == AppState.DATA_READY)
      return _contentDataReady();
    else if (_state == AppState.NO_DATA)
      return _contentNoData();
    else if (_state == AppState.FETCHING_DATA)
      return _contentFetchingData();
    else if (_state == AppState.AUTH_NOT_GRANTED)
      return _authorizationNotGranted();
    else if (_state == AppState.DATA_ADDED)
      return _dataAdded();
    else if (_state == AppState.DATA_DELETED)
      return _dataDeleted();
    else if (_state == AppState.STEPS_READY)
      return _stepsFetched();
    else if (_state == AppState.DATA_NOT_ADDED)
      return _dataNotAdded();
    else if (_state == AppState.DATA_NOT_DELETED)
      return _dataNotDeleted();
    else
      return _contentNotFetched();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Health Example'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.file_download),
                onPressed: () {
                  fetchData();
                },
              ),
              IconButton(
                onPressed: () {
                  addData();
                },
                icon: Icon(Icons.add),
              ),
              IconButton(
                onPressed: () {
                  deleteData();
                },
                icon: Icon(Icons.delete),
              ),
              IconButton(
                onPressed: () {
                  fetchStepData();
                },
                icon: Icon(Icons.nordic_walking),
              ),
              IconButton(
                onPressed: () {
                  revokeAccess();
                },
                icon: Icon(Icons.logout),
              )
            ],
          ),
          body: Center(
            child: _content(),
          )),
    );
  }
}
