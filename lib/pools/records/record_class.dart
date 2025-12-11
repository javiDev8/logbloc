import 'package:logbloc/apis/db.dart';
import 'package:logbloc/event_processor.dart';
import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/features/feature_switch.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/utils/feedback.dart';

class Rec {
  String id;
  String modelId;
  Map<String, dynamic> features;
  Schedule schedule;
  double completeness;

  Rec({
    required this.id,
    required this.modelId,
    required this.features,
    required this.schedule,
    required this.completeness,
  });

  serialize() {
    return {
      'id': id,
      'modelId': modelId,
      'features': features,
      'schedule': schedule.serialize(),
      'completeness': getCompleteness(
        modelId: modelId,
        features: features,
      ),
    };
  }

  factory Rec.fromMap(Map<String, dynamic> map) {
    return Rec(
      id: map['id'] as String,
      modelId: map['modelId'] as String,
      features: Map<String, dynamic>.from(map['features'] as Map),
      schedule: Schedule.fromMap(map['schedule']),
      completeness:
          map['completeness'] ??
          getCompleteness(
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
double getCompleteness({
  required String modelId,
  required Map<String, dynamic> features,
}) {
  try {
    double total = 0;
    final model = modelsPool.data![modelId]!;

    int reminderFts = 0;

    for (final ftEntry in features.entries) {
      Feature feature = featureSwitch(
        parseType: 'class',
        entry: MapEntry(
          ftEntry.key,
          model.features[ftEntry.key]!.serialize(),
        ),
        recordFt: ftEntry.value,
      );

      if (feature.type == 'reminder') {
        reminderFts++;
      } else {
        total += feature.completeness;
      }
    }

    return total / (features.length - reminderFts);
  } catch (e) {
    return 0;
  }
}
