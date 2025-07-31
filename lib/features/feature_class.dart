class Feature {
  String type;
  String id;
  bool pinned;
  bool isRequired;

  Feature({
    required this.id,
    required this.type,
    required this.pinned,
    required this.isRequired,
  });

  get key => '$type-$id';

  static String genId() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  factory Feature.empty(String type) {
    return Feature(
      type: type,
      id: genId(),
      pinned: false,
      isRequired: false,
    );
  }

  factory Feature.fromEntry(MapEntry<String, dynamic> entry) {
    final map = entry.value;
    return Feature(
      id: entry.key.split('-')[1],
      type: entry.key.split('-')[0],
      pinned: map['pinned'],
      isRequired: map['isRequired'],
    );
  }

  Map<String, dynamic> serialize() => {
    'pinned': pinned,
    'isRequired': isRequired,
  };

  Map<String, dynamic> makeRec() => {};
}
