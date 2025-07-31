Map<String, dynamic> parseMap(Map<dynamic, dynamic> originalMap) {
  final Map<String, dynamic> newMap = {};

  originalMap.forEach((key, value) {
    final String stringKey = key.toString();

    if (value is Map) {
      newMap[stringKey] = parseMap(value);
    } else {
      newMap[stringKey] = value;
    }
  });

  return newMap;
}
