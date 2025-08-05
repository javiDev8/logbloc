import 'package:logize/apis/db.dart';
import 'package:logize/event_processor.dart';
import 'package:logize/pools/models/model_class.dart';

class Rec {
  String id;
  String modelId;
  Map<String, dynamic> features;
  Schedule schedule;

  Rec({
    required this.id,
    required this.modelId,
    required this.features,
    required this.schedule,
  });

  serialize() {
    return {
      'id': id,
      'modelId': modelId,
      'features': features,
      'schedule': schedule.serialize(),
    };
  }

  factory Rec.fromMap(Map<String, dynamic> map) {
    return Rec(
      id: map['id'] as String,
      modelId: map['modelId'] as String,
      features: Map<String, dynamic>.from(map['features'] as Map),
      schedule: Schedule.fromMap(map['schedule']),
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
