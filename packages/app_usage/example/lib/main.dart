import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_usage/app_usage.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppUsage appUsage = new AppUsage();
  String apps = 'Unknown';


  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
  }

  void getUsageStats() async {
    DateTime endDate = new DateTime.now();
    DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);
    Map<String, double> usage = await appUsage.getUsage(startDate, endDate);
    usage.removeWhere((key,val) => val == 0);
//    print(usage);
    setState(() => apps = makeString(usage));
  }

  String makeString(Map<String, double> usage) {
    String result = '';
    usage.forEach((k,v) {
      String appName = k.split('.').last;
      String timeInMins = (v / 60).toStringAsFixed(2);
      result += '$appName : $timeInMins minutes\n';
    });
    return result;
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App Usage Example'),
        ),
        body: Text(
          apps,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 20.0, // insert your font size here
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: getUsageStats,
            child: Icon(Icons.cached)
        ),
      ),
    );
  }
}
