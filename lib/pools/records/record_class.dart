import 'package:logize/apis/db.dart';
import 'package:logize/event_processor.dart';

class Rec {
  String id;
  String modelId;
  String date;
  Map<String, dynamic> features;
  double sortPlace;

  Rec({
    required this.id,
    required this.modelId,
    required this.date,
    required this.features,
    required this.sortPlace,
  });

  serialize() {
    return {
      'id': id,
      'modelId': modelId,
      'features': features,
      'date': date,
      'sortPlace': sortPlace,
    };
  }

  factory Rec.fromMap(Map<String, dynamic> map) {
    return Rec(
      id: map['id'] as String,
      modelId: map['modelId'] as String,
      features: Map<String, dynamic>.from(map['features'] as Map),
      date: map['date'] as String,
      sortPlace: (map['sortPlace'] as num).toDouble(),
    );
  }

  save() async {
    final event = Event(
      entity: 'record',
      type: '',
      entityIds: [id],
      timestamp: DateTime.now(),
    );
    try {
      event.type = await db.saveRecord(this);
      eventProcessor.emitEvent(event);
    } catch (e) {
      throw Exception('record add failed: $e');
    }
  }

  delete() async {
    try {
      await db.deleteRecord(this);
      eventProcessor.emitEvent(
        Event(
          entity: 'record',
          type: 'delete',
          entityIds: [id],
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      throw Exception('record delete failed: $e');
    }
  }
}
