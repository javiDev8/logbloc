import 'package:flutter/material.dart';
import 'package:logize/apis/db.dart';
import 'package:logize/event_processor.dart';
import 'package:logize/utils/feedback.dart';

class Tag {
  String id;
  String name;
  Color? color;

  static final initColor = Color.fromRGBO(200, 50, 50, 1);

  Tag({required this.id, required this.name, this.color});

  factory Tag.empty() =>
      Tag(id: UniqueKey().toString(), name: '', color: initColor);

  factory Tag.fromMap(Map<String, dynamic> map) => Tag(
    id: map['id'] as String,
    name: map['name'] as String,
    color: map.containsKey('color')
        ? Color(int.parse(map['color'] as String))
        : null,
  );

  serialize() => {
    'id': id,
    'name': name,
    if (color != null) 'color': color!.toARGB32().toString(),
  };

  save() async {
    await db.saveTag(this);
    eventProcessor.emitEvent(
      Event(
        entity: 'tag',
        type: 'save',
        entityIds: [id],
        timestamp: DateTime.now(),
      ),
    );
    feedback('tag saved', type: FeedbackType.success);
  }

  delete() async {
    await db.deleteTag(id);
    eventProcessor.emitEvent(
      Event(
        entity: 'tag',
        type: 'delete',
        entityIds: [id],
        timestamp: DateTime.now(),
      ),
    );
    feedback('tag deleted', type: FeedbackType.success);
  }
}
