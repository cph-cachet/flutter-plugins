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
    try {
      DateTime endDate = new DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);
      final usage = await appUsage.fetchUsage(startDate, endDate);
      setState(() => apps = makeString(usage));
    }
    on AppUsageException catch (exception) {
      print(exception);
    }
  }

  String makeString(List<AppInfo> usage) {
    String result = '';
    usage.forEach((element) {
      result += element.packageName + ' -> ' + element.usage.toString() + '\n';
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
