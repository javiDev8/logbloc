import 'package:logbloc/apis/db.dart';
import 'package:logbloc/event_processor.dart';
import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/features/feature_switch.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/utils/feedback.dart';
import 'package:logbloc/utils/noticable_print.dart';

class Rec {
  String id;
  String modelId;
  Map<String, dynamic> features;
  Schedule schedule;
  int completeFts;

  Rec({
    required this.id,
    required this.modelId,
    required this.features,
    required this.schedule,
    required this.completeFts,
  });

  double get completenessRate => completeFts / features.length;

  serialize() {
    return {
      'id': id,
      'modelId': modelId,
      'features': features,
      'schedule': schedule.serialize(),
      'completeFts': getCompleteFts(modelId: modelId, features: features),
    };
  }

  factory Rec.fromMap(Map<String, dynamic> map) {
    return Rec(
      id: map['id'] as String,
      modelId: map['modelId'] as String,
      features: Map<String, dynamic>.from(map['features'] as Map),
      schedule: Schedule.fromMap(map['schedule']),
      completeFts:
          map['completeFts'] ??
          getCompleteFts(
            features: map['features'],
            modelId: map['modelId'],
          ),
    );
  }

  save({bool? silent}) async {
    final event = Event(
      entity: 'record',
      type: '',
      entityIds: [id],
      timestamp: DateTime.now(),
    );
    try {
      event.type = await db.saveRecord(this);
      if (silent != true) {
        eventProcessor.emitEvent(event);
      }
    } catch (e) {
      throw Exception('record add failed: $e');
    }
  }

  Future<bool> delete() async {
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
      feedback('record deleted', type: FeedbackType.success);
      return true;
    } catch (e) {
      throw Exception('record delete failed: $e');
    }
  }
}

// this truly is an awful patch, but works nice for now
int getCompleteFts({
  required String modelId,
  required Map<String, dynamic> features,
}) {
  try {
    int doneCount = 0;
    final model = modelsPool.data![modelId]!;
    for (final ftEntry in features.entries) {
      Feature feature = featureSwitch(
        parseType: 'class',
        entry: MapEntry(
          ftEntry.key,
          model.features[ftEntry.key]!.serialize(),
        ),
        recordFt: ftEntry.value,
      );
      if (!feature.isEmpty) doneCount++;
    }

    return doneCount;
  } catch (e) {
    nPrint('fail: $e');
    return 0;
  }
}
