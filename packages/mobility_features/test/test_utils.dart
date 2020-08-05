part of mobility_test;

const String datasetPath = 'lib/data/example-multi.json';
const String testDataDir = 'test/testdata';

Duration takeTime(DateTime start, DateTime end) {
  int ms = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
  return Duration(milliseconds: ms);
}

void flushFiles() async {
  File samples = new File('$testDataDir/location_samples.json');
  File stops = new File('$testDataDir/stops.json');
  File moves = new File('$testDataDir/moves.json');

  await samples.writeAsString('');
  await stops.writeAsString('');
  await moves.writeAsString('');
}

void printList(List l) {
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
  File f = new File('$testDataDir/data-example-munich.json');
  String content = f.readAsStringSync();
  List<String> lines = content.split('\n');

  List<LocationSample> samples = [];
  lines.forEach((e) {
    try {
      Map m = json.decode(e);
      GeoLocation geoLocation =
          GeoLocation(double.parse(m['lat']), double.parse(m['lon']));
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(m['datetime']));
      samples.add(LocationSample(geoLocation, dateTime));
    } catch (error) {}
  });
  return samples;
}
