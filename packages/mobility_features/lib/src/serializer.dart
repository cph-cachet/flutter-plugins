part of '../mobility_features.dart';

/// Utility class for (de)serializing [Stop] and [Move] objects.
class MobilitySerializer<T> {
  // Provide a file reference in order to serialize objects.
  File? _file;
  String delimiter = '\n';

  MobilitySerializer();

  /// Clears (deletes) the content of [file]
  void clear() => _file!.writeAsStringSync('', mode: FileMode.write);

  Future<File> get file async => _file ??= await _fileReference(T);

  /// Appends a list of mobility [elements] to [file].
  void append(List<Serializable> elements) async {
    File f = await file;
    String jsonString = "";
    for (Serializable element in elements) {
      jsonString += json.encode(element.toJson()) + delimiter;
    }
    f.writeAsStringSync(jsonString, mode: FileMode.writeOnlyAppend);
  }

  /// Reads contents of the [file] and maps it to a list of a specific
  /// mobility objects.
  Future<List<Serializable>> load() async {
    File f = await file;

    // Read file content as one big string
    String content = await f.readAsString();

    // Split content into lines by delimiting them
    List<String> lines = content.split(delimiter);

    // Remove last entry since it is always empty
    // Then convert each line to JSON, and then to Dart Map<T> objects
    Iterable<Map<String, dynamic>> jsonObjs = lines
        .sublist(0, lines.length - 1)
        .map((e) => json.decode(e))
        .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>));

    switch (T) {
      // Filter out moves which are not recent
      case const (Move):
        return jsonObjs.map((x) => Move.fromJson(x)).toList();
      // Filter out stops which are not recent
      case const (Stop):
        return jsonObjs.map((x) => Stop.fromJson(x)).toList();
      // Filter out data samples not from today
      default:
        return jsonObjs.map((x) => LocationSample.fromJson(x)).toList();
    }
  }
}

const String _LOCATION_SAMPLES_FILE = 'location_samples',
    _STOPS_FILE = 'stops',
    _MOVES_FILE = 'moves',
    _TEST_DATA_PATH = 'test/testdata';

Future<File> _fileReference(Type T) async {
  bool isMobile = Platform.isAndroid || Platform.isIOS;

  /// If on a mobile device, use the path_provider plugin to access the
  /// file system. Otherwise if unit testing just use the normal file system.
  String path;
  if (isMobile) {
    path = (await getApplicationDocumentsDirectory()).path;
  } else {
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
  File reference = File('$path/$type.json');

  // If it does not exist already, create it by writing an empty string to it.
  bool exists = reference.existsSync();
  if (!exists) {
    reference.writeAsStringSync('', mode: FileMode.write);
  }

  return reference;
}
