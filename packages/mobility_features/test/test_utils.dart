part of 'mobility_features_test.dart';

const String datasetPath = 'lib/data/example-multi.json';
const String testDataDir = 'test/testdata';

Duration takeTime(DateTime start, DateTime end) {
  int ms = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
  return Duration(milliseconds: ms);
}

/// Clean file every time test is run
void flushFiles() async {
  File samples = File('$testDataDir/location_samples.json');
  File stops = File('$testDataDir/stops.json');
  File moves = File('$testDataDir/moves.json');

  await samples.writeAsString('');
  await stops.writeAsString('');
  await moves.writeAsString('');
}

void printList(List<dynamic> l) {
  for (int i = 0; i < l.length; i++) {
    print('[$i] ${l[i]}');
  }

  print('-' * 50);
}

double abs(double x) => x >= 0 ? x : -x;

class LocationDTO {
  double lat, lon;

  LocationDTO(this.lat, this.lon);
}

List<LocationSample> loadDataSet() {
  File f = File('$testDataDir/data-example-munich.json');
  String content = f.readAsStringSync();
  List<String> lines = content.split('\n');

  List<LocationSample> samples = [];
  for (var e in lines) {
    try {
      Map<String, dynamic> m = json.decode(e) as Map<String, dynamic>;
      GeoLocation geoLocation = GeoLocation(
          double.parse(m['lat'] as String), double.parse(m['lon'] as String));
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(m['datetime'] as String));
      samples.add(LocationSample(geoLocation, dateTime));
    } catch (error) {
      print('ERROR - $error');
    }
  }
  return samples;
}
