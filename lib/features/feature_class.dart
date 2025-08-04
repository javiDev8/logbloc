class Feature {
  String type;
  String id;
  bool pinned;
  bool isRequired;
  double position;
  String? schedule;

  Feature({
    required this.id,
    required this.type,
    required this.pinned,
    required this.isRequired,
    required this.position,
    this.schedule,
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
      position: 0,
    );
  }

  factory Feature.fromEntry(MapEntry<String, dynamic> entry) {
    final map = entry.value;
    return Feature(
      id: entry.key.split('-')[1],
      type: entry.key.split('-')[0],
      pinned: map['pinned'],
      isRequired: map['isRequired'],
      position: map['position'],
      schedule: map['schedule'],
    );
  }

  Map<String, dynamic> serialize() {
    final serial = {
      'pinned': pinned,
      'isRequired': isRequired,
      'position': position,
    };
    if (schedule != null) {
      serial['schedule'] = schedule!;
    }
    return serial;
  }

  Map<String, dynamic> makeRec() => {};
}
