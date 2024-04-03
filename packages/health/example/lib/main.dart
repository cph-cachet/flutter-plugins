import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:carp_serializable/carp_serializable.dart';

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
  AUTHORIZED,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_DELETED,
  DATA_NOT_ADDED,
  DATA_NOT_DELETED,
  STEPS_READY,
  HEALTH_CONNECT_STATUS,
}

class _HealthAppState extends State<HealthApp> {
  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  int _nofSteps = 0;

  // All types available depending on platform (iOS ot Android).
  List<HealthDataType> get types => (Platform.isAndroid)
      ? dataTypesAndroid
      : (Platform.isIOS)
          ? dataTypesIOS
          : [];

  // // Or specify specific types
  // static final types = [
  //   HealthDataType.WEIGHT,
  //   HealthDataType.STEPS,
  //   HealthDataType.HEIGHT,
  //   HealthDataType.BLOOD_GLUCOSE,
  //   HealthDataType.WORKOUT,
  //   HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  //   HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
  //   // Uncomment this line on iOS - only available on iOS
  //   // HealthDataType.AUDIOGRAM
  // ];

  // Set up corresponding permissions
  // READ only
  List<HealthDataAccess> get permissions =>
      types.map((e) => HealthDataAccess.READ).toList();

  // Or both READ and WRITE
  // List<HealthDataAccess> get permissions =>
  //     types.map((e) => HealthDataAccess.READ_WRITE).toList();

  void initState() {
    // configure the health plugin before use.
    Health().configure(useHealthConnectIfAvailable: true);

    super.initState();
  }

  /// Install Google Health Connect on this phone.
  Future<void> installHealthConnect() async {
    await Health().installHealthConnect();
  }

  /// Authorize, i.e. get permissions to access relevant health data.
  Future<void> authorize() async {
    // If we are trying to read Step Count, Workout, Sleep or other data that requires
    // the ACTIVITY_RECOGNITION permission, we need to request the permission first.
    // This requires a special request authorization call.
    //
    // The location permission is requested for Workouts using the Distance information.
    await Permission.activityRecognition.request();
    await Permission.location.request();

    // Check if we have health permissions
    bool? hasPermissions =
        await Health().hasPermissions(types, permissions: permissions);

    // hasPermissions = false because the hasPermission cannot disclose if WRITE access exists.
    // Hence, we have to request with WRITE as well.
    hasPermissions = false;

    bool authorized = false;
    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        authorized = await Health()
            .requestAuthorization(types, permissions: permissions);
      } catch (error) {
        debugPrint("Exception in authorize: $error");
      }
    }

    setState(() => _state =
        (authorized) ? AppState.AUTHORIZED : AppState.AUTH_NOT_GRANTED);
  }

  /// Gets the Health Connect status on Android.
  Future<void> getHealthConnectSdkStatus() async {
    assert(Platform.isAndroid, "This is only available on Android");

    final status = await Health().getHealthConnectSdkStatus();

    setState(() {
      _contentHealthConnectStatus = Text('Health Connect Status: $status');
      _state = AppState.HEALTH_CONNECT_STATUS;
    });
  }

  /// Fetch data points from the health plugin and show them in the app.
  Future<void> fetchData() async {
    setState(() => _state = AppState.FETCHING_DATA);

    // get data within the last 24 hours
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(hours: 24));

    // Clear old data points
    _healthDataList.clear();

    // try {
    // fetch health data
    List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
      types: types,
      startTime: yesterday,
      endTime: now,
    );

    debugPrint('Total number of data points: ${healthData.length}. '
        '${healthData.length > 100 ? 'Only showing the first 100.' : ''}');

    // save all the new data points (only the first 100)
    _healthDataList.addAll(
        (healthData.length < 100) ? healthData : healthData.sublist(0, 100));
    // } catch (error) {
    //   debugPrint("Exception in getHealthDataFromTypes: $error");
    // }

    // filter out duplicates
    _healthDataList = Health().removeDuplicates(_healthDataList);

    _healthDataList.forEach((data) => debugPrint(toJsonString(data)));

    // update the UI to display the results
    setState(() {
      _state = _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
    });
  }

  /// Add some random health data.
  /// Note that you should ensure that you have permissions to add the
  /// following data types.
  Future<void> addData() async {
    final now = DateTime.now();
    final earlier = now.subtract(Duration(minutes: 20));

    // Add data for supported types
    // NOTE: These are only the ones supported on Androids new API Health Connect.
    // Both Android's Google Fit and iOS' HealthKit have more types that we support in the enum list [HealthDataType]
    // Add more - like AUDIOGRAM, HEADACHE_SEVERE etc. to try them.
    bool success = true;

    // misc. health data examples using the writeHealthData() method
    success &= await Health().writeHealthData(
        value: 1.925,
        type: HealthDataType.HEIGHT,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 90, type: HealthDataType.WEIGHT, startTime: now);
    success &= await Health().writeHealthData(
        value: 90,
        type: HealthDataType.HEART_RATE,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 90,
        type: HealthDataType.STEPS,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 200,
        type: HealthDataType.ACTIVE_ENERGY_BURNED,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 70,
        type: HealthDataType.HEART_RATE,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 37,
        type: HealthDataType.BODY_TEMPERATURE,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 105,
        type: HealthDataType.BLOOD_GLUCOSE,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 1.8,
        type: HealthDataType.WATER,
        startTime: earlier,
        endTime: now);

    // different types of sleep
    success &= await Health().writeHealthData(
        value: 0.0,
        type: HealthDataType.SLEEP_REM,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 0.0,
        type: HealthDataType.SLEEP_ASLEEP,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 0.0,
        type: HealthDataType.SLEEP_AWAKE,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 0.0,
        type: HealthDataType.SLEEP_DEEP,
        startTime: earlier,
        endTime: now);

    // specialized write methods
    success &= await Health().writeBloodOxygen(
      saturation: 98,
      startTime: earlier,
      endTime: now,
      flowRate: 1.0,
    );
    success &= await Health().writeWorkoutData(
      activityType: HealthWorkoutActivityType.AMERICAN_FOOTBALL,
      title: "Random workout name that shows up in Health Connect",
      start: now.subtract(Duration(minutes: 15)),
      end: now,
      totalDistance: 2430,
      totalEnergyBurned: 400,
    );
    success &= await Health().writeBloodPressure(
      systolic: 90,
      diastolic: 80,
      startTime: now,
    );
    success &= await Health().writeMeal(
      mealType: MealType.SNACK,
      startTime: earlier,
      endTime: now,
      caloriesConsumed: 1000,
      carbohydrates: 50,
      protein: 25,
      fatTotal: 50,
      name: "Banana",
      caffeine: 0.002,
    );

    // Store an Audiogram - only available on iOS
    // const frequencies = [125.0, 500.0, 1000.0, 2000.0, 4000.0, 8000.0];
    // const leftEarSensitivities = [49.0, 54.0, 89.0, 52.0, 77.0, 35.0];
    // const rightEarSensitivities = [76.0, 66.0, 90.0, 22.0, 85.0, 44.5];
    // success &= await Health().writeAudiogram(
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
  Future<void> deleteData() async {
    final now = DateTime.now();
    final earlier = now.subtract(Duration(hours: 24));

    bool success = true;
    for (HealthDataType type in types) {
      success &= await Health().delete(
        type: type,
        startTime: earlier,
        endTime: now,
      );
    }

    setState(() {
      _state = success ? AppState.DATA_DELETED : AppState.DATA_NOT_DELETED;
    });
  }

  /// Fetch steps from the health plugin and show them in the app.
  Future<void> fetchStepData() async {
    int? steps;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool stepsPermission =
        await Health().hasPermissions([HealthDataType.STEPS]) ?? false;
    if (!stepsPermission) {
      stepsPermission =
          await Health().requestAuthorization([HealthDataType.STEPS]);
    }

    if (stepsPermission) {
      try {
        steps = await Health().getTotalStepsInInterval(midnight, now);
      } catch (error) {
        debugPrint("Exception in getTotalStepsInInterval: $error");
      }

      debugPrint('Total number of steps: $steps');

      setState(() {
        _nofSteps = (steps == null) ? 0 : steps;
        _state = (steps == null) ? AppState.NO_DATA : AppState.STEPS_READY;
      });
    } else {
      debugPrint("Authorization not granted - error in authorization");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  /// Revoke access to health data. Note, this only has an effect on Android.
  Future<void> revokeAccess() async {
    try {
      await Health().revokePermissions();
    } catch (error) {
      debugPrint("Exception in revokeAccess: $error");
    }
  }

  // UI building below

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Health Example'),
        ),
        body: Container(
          child: Column(
            children: [
              Wrap(
                spacing: 10,
                children: [
                  TextButton(
                      onPressed: authorize,
                      child: Text("Authenticate",
                          style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.blue))),
                  if (Platform.isAndroid)
                    TextButton(
                        onPressed: getHealthConnectSdkStatus,
                        child: Text("Check Health Connect Status",
                            style: TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.blue))),
                  TextButton(
                      onPressed: fetchData,
                      child: Text("Fetch Data",
                          style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.blue))),
                  TextButton(
                      onPressed: addData,
                      child: Text("Add Data",
                          style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.blue))),
                  TextButton(
                      onPressed: deleteData,
                      child: Text("Delete Data",
                          style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.blue))),
                  TextButton(
                      onPressed: fetchStepData,
                      child: Text("Fetch Step Data",
                          style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.blue))),
                  TextButton(
                      onPressed: revokeAccess,
                      child: Text("Revoke Access",
                          style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.blue))),
                  if (Platform.isAndroid)
                    TextButton(
                        onPressed: installHealthConnect,
                        child: Text("Install Health Connect",
                            style: TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.blue))),
                ],
              ),
              Divider(thickness: 3),
              Expanded(child: Center(child: _content))
            ],
          ),
        ),
      ),
    );
  }

  Widget get _contentFetchingData => Column(
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

  Widget get _contentDataReady => ListView.builder(
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
        if (p.value is NutritionHealthValue) {
          return ListTile(
            title: Text(
                "${p.typeString} ${(p.value as NutritionHealthValue).mealType}: ${(p.value as NutritionHealthValue).name}"),
            trailing:
                Text('${(p.value as NutritionHealthValue).calories} kcal'),
            subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
          );
        }
        return ListTile(
          title: Text("${p.typeString}: ${p.value}"),
          trailing: Text('${p.unitString}'),
          subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
        );
      });

  Widget _contentNoData = const Text('No Data to show');

  Widget _contentNotFetched = const Column(children: [
    const Text("Press 'Auth' to get permissions to access health data."),
    const Text("Press 'Fetch Dat' to get health data."),
    const Text("Press 'Add Data' to add some random health data."),
    const Text("Press 'Delete Data' to remove some random health data."),
  ], mainAxisAlignment: MainAxisAlignment.center);

  Widget _authorized = const Text('Authorization granted!');

  Widget _authorizationNotGranted = const Column(
    children: [
      const Text('Authorization not given.'),
      const Text(
          'For Google Fit please check your OAUTH2 client ID is correct in Google Developer Console.'),
      const Text(
          'For Google Health Connect please check if you have added the right permissions and services to the manifest file.'),
      const Text('For Apple Health check your permissions in Apple Health.'),
    ],
    mainAxisAlignment: MainAxisAlignment.center,
  );

  Widget _contentHealthConnectStatus = const Text(
      'No status, click getHealthConnectSdkStatus to get the status.');

  Widget _dataAdded = const Text('Data points inserted successfully.');

  Widget _dataDeleted = const Text('Data points deleted successfully.');

  Widget get _stepsFetched => Text('Total number of steps: $_nofSteps.');

  Widget _dataNotAdded =
      const Text('Failed to add data.\nDo you have permissions to add data?');

  Widget _dataNotDeleted = const Text('Failed to delete data');

  Widget get _content => switch (_state) {
        AppState.DATA_READY => _contentDataReady,
        AppState.DATA_NOT_FETCHED => _contentNotFetched,
        AppState.FETCHING_DATA => _contentFetchingData,
        AppState.NO_DATA => _contentNoData,
        AppState.AUTHORIZED => _authorized,
        AppState.AUTH_NOT_GRANTED => _authorizationNotGranted,
        AppState.DATA_ADDED => _dataAdded,
        AppState.DATA_DELETED => _dataDeleted,
        AppState.DATA_NOT_ADDED => _dataNotAdded,
        AppState.DATA_NOT_DELETED => _dataNotDeleted,
        AppState.STEPS_READY => _stepsFetched,
        AppState.HEALTH_CONNECT_STATUS => _contentHealthConnectStatus,
      };
}
