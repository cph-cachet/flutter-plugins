/*
 * Copyright (c) 2018. Daniel Morawetz
 * Licensed under Apache License v2.0
 */

part of activity_recognition;

class Activity {
  String type;
  int confidence;

  Activity(this.type, this.confidence);

  factory Activity.empty() {
    return Activity("UNKNOWN", 100);
  }

  factory Activity.fromJson(Map<String, dynamic> act) {
    return Activity(act['type'], act['confidence']);
  }
}
