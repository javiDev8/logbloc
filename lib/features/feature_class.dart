import 'package:flutter/material.dart';

class Feature {
  String id;
  String type;
  String title;
  bool pinned;
  bool isRequired;
  double position;

  Feature({
    required this.id,
    required this.type,
    required this.title,
    required this.pinned,
    required this.isRequired,
    required this.position,
  });

  get key => '$type-$id';

  static String genId() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  factory Feature.empty(String type) {
    return Feature(
      id: genId(),
      type: type,
      title: '',
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
      title: map['title'],
      pinned: map['pinned'],
      isRequired: map['isRequired'],
      position: map['position'],
    );
  }

  setTitle(String t) => title = t;

  Map<String, dynamic> serialize() {
    return {
      'title': title,
      'pinned': pinned,
      'isRequired': isRequired,
      'position': position,
    };
  }

  Map<String, dynamic> makeRec() {
    final now = TimeOfDay.now();
    return {'time': '${now.hour}:${now.minute}'};
  }
}
