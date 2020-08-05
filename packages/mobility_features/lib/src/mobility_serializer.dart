part of mobility_features;

class _MobilitySerializer<T> {
  /// Provide a file reference in order to serialize objects.
  File _file;
  String delimiter = '\n';

  _MobilitySerializer();

  /// Deletes the content of the file
  void flush() {
    _file.writeAsStringSync('', mode: FileMode.write);
  }

  Future<File> get file async {
    if (_file == null) {
      _file = await _fileReference(T);
    }
    return _file;
  }

  /// Writes a list of [_Serializable] to the file given in the constructor.
  void save(List<_Serializable> elements) async {
    File f = await file;
    String jsonString = "";
    for (_Serializable e in elements) {
      jsonString += json.encode(e.toJson()) + delimiter;
    }
    f.writeAsStringSync(jsonString, mode: FileMode.writeOnlyAppend);
  }

  /// Reads contents of the file in the constructor,
  /// and maps it to a list of a specific [_Serializable] type.
  Future<List<_Serializable>> load() async {
    File f = await file;

    /// Read file content as one big string
    String content = await f.readAsString();

    /// Split content into lines by delimiting them
    List<String> lines = content.split(delimiter);

    /// Remove last entry since it is always empty
    /// Then convert each line to JSON, and then to Dart Map<T> objects
    Iterable<Map<String, dynamic>> jsonObjs = lines
        .sublist(0, lines.length - 1)
        .map((e) => json.decode(e))
        .map((e) => Map<String, dynamic>.from(e));

    switch (T) {
      case Move:

        /// Filter out moves which are not recent
        return jsonObjs.map((x) => Move._fromJson(x)).toList();
      case Stop:

        /// Filter out stops which are not recent
        return jsonObjs.map((x) => Stop._fromJson(x)).toList();
      default:

        /// Filter out data samples not from today
        return jsonObjs.map((x) => LocationSample._fromJson(x)).toList();
    }
  }
}
