part of mobility_features;

const String _LOCATION_SAMPLES_FILE = 'location_samples',
    _STOPS_FILE = 'stops',
    _MOVES_FILE = 'moves',
    _TEST_DATA_PATH = 'test/testdata';

Future<File> _fileReference(Type T) async {
  bool isMobile = Platform.isAndroid || Platform.isIOS;

  /// If on a mobile device, use the path_provider plugin to access the
  /// file system
  String path;
  if (isMobile) {
    path = (await getApplicationDocumentsDirectory()).path;
  }

  /// Otherwise if unit testing just use the normal file system
  else {
    path = _TEST_DATA_PATH;
  }

  /// Decide which file to write to, depending on the type (T)
  String type = _LOCATION_SAMPLES_FILE;
  if (T == Move) {
    type = _MOVES_FILE;
  } else if (T == Stop) {
    type = _STOPS_FILE;
  }

  // Create a file reference
  File reference = new File('$path/$type.json');

  // If it does not exist already,
  // create it by writing an empty string to it
  bool exists = reference.existsSync();
  if (!exists) {
    reference.writeAsStringSync('', mode: FileMode.write);
  }

  return reference;
}
