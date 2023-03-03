// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:movisens_flutter/movisens_flutter.dart';
import 'package:logging/logging.dart';

void main() {
  // Recommended to use for testing of Movisens Flutter plugin.
  // Level.ALL
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movisens Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Movisens Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MovisensDevice device;

  @override
  void initState() {
    super.initState();
    device = MovisensDevice(name: deviceName);
  }

  // The name of your device
  // Due to iOS using generated UUIDs instead of MAC addresses,
  // this is the only way to connect to the device
  String deviceName =
      "MOVISENS Sensor 01234"; // Example: "MOVISENS Sensor 04421"

  void connect() async {
    await device.connect();

    device.state?.listen((event) {
      print('Connection event: $event');
    });
  }

  void listen() async {
    // Enable the device to emit all event for each service:
    await device.ambientService?.enableNotify();
    await device.edaService?.enableNotify();
    await device.hrvService?.enableNotify();
    await device.markerService?.enableNotify();
    await device.batteryService?.enableNotify();
    await device.physicalActivityService?.enableNotify();
    await device.respirationService?.enableNotify();
    await device.sensorControlService?.enableNotify();
    await device.skinTemperatureService?.enableNotify();

    // Listen to all characteristics
    device.ambientService?.events.listen((event) {
      print("all ambient events stream -- event : $event");
    });
    device.edaService?.events.listen((event) {
      print("all eda events stream -- event : $event");
    });
    device.hrvService?.events.listen((event) {
      print("all hrv events stream -- event : $event");
    });
    device.markerService?.events.listen((event) {
      print("all marker events stream -- event : $event");
    });
    device.batteryService?.events.listen((event) {
      print("all battery events stream -- event : $event");
    });
    device.physicalActivityService?.events.listen((event) {
      print("all physical events stream -- event : $event");
    });
    device.respirationService?.events.listen((event) {
      print("all respiration events stream -- event : $event");
    });
    device.sensorControlService?.events.listen((event) {
      print("all sensor control events stream -- event : $event");
    });
    device.skinTemperatureService?.events.listen((event) {
      print("all skin temp events stream -- event : $event");
    });

    // Or listen to individual characteristics:
    device.ambientService?.sensorTemperatureEvents?.listen((event) {
      print("Sensor temp listen : event: $event");
    });
    device.skinTemperatureService?.skinTemperatureEvents?.listen((event) {
      print("Skin temp listen : event: $event");
    });
  }

  void startMeasurement() async {
    // Test start and stop of measurement
    MeasurementStatus? ms =
        await device.sensorControlService?.getMeasurementStatus();
    bool? me = await device.sensorControlService?.getMeasurementEnabled();
    String s = (ms != null) ? enumToReadableString(ms) : "null";
    print("Measurement status:: $s");
    print("Measurement enabled:: $me");
    // Start a measurement that last 120 seconds or a indefinite one
    // Certain data has a delay of 60 - 84 seconds, so preferably a measurement longer than that.
    await device.sensorControlService?.setStartMeasurement(120);
    // await device.sensorControlService?.setMeasurementEnabled(true);
    // Delay 1 second for device to complete the task
    await Future.delayed(const Duration(seconds: 1));
    ms = await device.sensorControlService?.getMeasurementStatus();
    me = await device.sensorControlService?.getMeasurementEnabled();
    s = (ms != null) ? enumToReadableString(ms) : "null";
    print("Measurement status after start:: $s");
    print("Measurement enabled after start:: $me");
  }

  void stopMeasurement() async {
    await device.sensorControlService?.setMeasurementEnabled(false);
    // Wait 2 seconds for device to complete task
    await Future.delayed(const Duration(seconds: 2));
    MeasurementStatus? ms =
        await device.sensorControlService?.getMeasurementStatus();
    bool? me = await device.sensorControlService?.getMeasurementEnabled();
    String s = (ms != null) ? enumToReadableString(ms) : "null";
    print("Measurement status after stop:: $s");
    print("Measurement enabled after stop:: $me");
  }

  void deleteData() async {
    // Test deletion of data
    bool? da = await device.sensorControlService?.getDataAvailable();
    print('Data available :: $da');
    await device.sensorControlService?.setDeleteData(true);
    // Delay 1 second for device to complete the task
    await Future.delayed(const Duration(seconds: 1));
    da = await device.sensorControlService?.getDataAvailable();
    print('Data available after delete :: $da');
  }

  void action() async {
    // Use the function calls that aren't streams

    // Set and get current time MS
    try {
      int currentTimeMs = DateTime.now().millisecondsSinceEpoch;
      await device.sensorControlService?.setCurrentTimeMs(currentTimeMs);
    } catch (e) {
      print('Error setting Current Time MS::  $e');
    }
    // Delay 1 second for device to complete the task
    await Future.delayed(const Duration(seconds: 1));
    try {
      int? x = await device.sensorControlService?.getCurrentTimeMs();
      print("Current time MS:: $x");
    } catch (e) {
      print('Error getting Current Time MS::  $e');
    }

    // Get status
    int? sta = await device.sensorControlService?.getStatus();
    print('Status:: $sta');

    // Test storage level
    int? sl = await device.sensorControlService?.getStorageLevel();
    print('Storage level :: $sl');

    // set age
    await device.userDataService?.setAgeFloat(41.5);
    // get age
    double? age = await device.userDataService?.getAgeFloat();
    print('Age:: $age');

    // set sensor location
    await device.userDataService?.setSensorLocation(SensorLocation.chest);
    // get sensor location
    SensorLocation? sensorloc =
        await device.userDataService?.getSensorLocation();
    print('Sensor location:: $sensorloc');

    // set gender
    await device.userDataService?.setGender(Gender.male);
    // get gender
    Gender? gender = await device.userDataService?.getGender();
    print('gender:: $gender');

    // set height
    await device.userDataService?.setHeight(182);
    // get height
    int? height = await device.userDataService?.getHeight();
    print('height:: $height cm');

    // set weight
    await device.userDataService?.setWeight(84.5);
    // get weight
    double? weight = await device.userDataService?.getWeight();
    print('weight:: $weight kg');

    // Device information:
    String? firmwareRevisionString =
        await device.deviceInformationService?.getFirmwareRevisionString();
    print(firmwareRevisionString);
    String? manufacturerNameString =
        await device.deviceInformationService?.getManufacturerNameString();
    print(manufacturerNameString);
    String? modelNumberString =
        await device.deviceInformationService?.getModelNumberString();
    print(modelNumberString);
    String? serialNumberString =
        await device.deviceInformationService?.getSerialNumberString();
    print(serialNumberString);
  }

  void disconnect() async {
    await device.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Use buttons below:',
            ),
            TextButton(onPressed: connect, child: const Text("Connect")),
            TextButton(
                onPressed: listen,
                child: const Text("Listen to all device services")),
            TextButton(
                onPressed: startMeasurement,
                child: const Text("Start Measurement")),
            TextButton(
                onPressed: stopMeasurement,
                child: const Text("Stop Measurement")),
            TextButton(onPressed: deleteData, child: const Text("Delete Data")),
            TextButton(onPressed: action, child: const Text("Perform action")),
            TextButton(onPressed: disconnect, child: const Text("Disconnect")),
          ],
        ),
      ),
    );
  }
}
