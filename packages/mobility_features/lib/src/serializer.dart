part of '../mobility_features.dart';

class MobilitySerializer<T> {
  // Provide a file reference in order to serialize objects.
  File? _file;
  String delimiter = '\n';

  MobilitySerializer();

  /// Deletes the content of the file
  void flush() => _file!.writeAsStringSync('', mode: FileMode.write);

  Future<File> get file async => _file ??= await _fileReference(T);

  /// Writes a list of [Serializable] to the file given in the constructor.
  void save(List<Serializable> elements) async {
    File f = await file;
    String jsonString = "";
    for (Serializable e in elements) {
      jsonString += json.encode(e.toJson()) + delimiter;
    }
    f.writeAsStringSync(jsonString, mode: FileMode.writeOnlyAppend);
  }

  /// Reads contents of the [file] and maps it to a list of a specific
  /// [Serializable] type.
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
