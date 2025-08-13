import 'package:logize/apis/db.dart';
import 'package:logize/event_processor.dart';
import 'package:logize/features/feature_class.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:flutter/material.dart';
import 'package:logize/pools/tags/tag_class.dart';
import 'package:logize/pools/tags/tags_pool.dart';
import 'package:logize/utils/feedback.dart';

// the num represents a priority for sorting, being
// 0 the default, so "0" means is there, null means is not

typedef Features = Map<String, Feature>;

class Schedule {
  String id;
  String day;
  double place;
  String? period; // null -> puntual
  List<String>? includedFts; // null -> all

  static const periods = [null, 'day', 'week', 'month', 'year'];

  Schedule({
    required this.id,
    required this.day,
    required this.place,
    this.period,
    this.includedFts,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) => Schedule(
    id: map['id'] as String,
    day: map['day'] as String,
    place: (map['place'] as num).toDouble(),
    period: map['period'] as String?,
    includedFts: map['includedFts'] as List<String>?,
  );

  factory Schedule.empty({required String day, String? period}) =>
      Schedule(
        day: day,
        period: period,
        id: UniqueKey().toString(),
        place: DateTime.now().millisecondsSinceEpoch.toDouble(),
      );

  serialize() => {
    'id': id,
    'day': day,
    'place': place,
    if (period != null) 'period': period,
    if (includedFts != null) 'includedFts': includedFts,
  };
}

class Model {
  String id;
  String name;
  Features features;
  int recordCount;
  DateTime createdAt;
  Map<String, Schedule>? schedules;
  Map<String, String>? cancelledSchedules;
  Color? color;
  Map<String, Tag>? tags;

  Model({
    required this.id,
    required this.name,
    required this.features,
    required this.recordCount,
    required this.createdAt,
    this.schedules,
    this.cancelledSchedules,
    this.color,
    this.tags,
  });

  factory Model.empty() => Model(
    name: '',
    features: {},
    recordCount: 0,
    id: UniqueKey().toString(),
    createdAt: DateTime.now(),
  );

  factory Model.fromMap({required Map<String, dynamic> map}) => Model(
    id: map['id'],
    name: map['name'],
    recordCount: map['record-count'] as int,

    createdAt: DateTime.fromMillisecondsSinceEpoch(
      map['created-at'] as int,
    ),

    features: Map.fromEntries(
      (map['features'] as Map<String, dynamic>).entries
          .map<MapEntry<String, Feature>>(
            (ftEntry) => MapEntry(
              ftEntry.key,
              featureSwitch(parseType: 'class', entry: ftEntry) as Feature,
            ),
          ),
    ),

    schedules: map['schedules'] == null
        ? null
        : Map.fromEntries(
            (map['schedules'] as Map<String, dynamic>).entries.map(
              (e) => MapEntry(
                e.key,
                Schedule.fromMap(Map<String, dynamic>.from(e.value)),
              ),
            ),
          ),

    cancelledSchedules: map['cancelled-schedules'],

    color: map.containsKey('color')
        ? Color(int.parse(map['color'] as String))
        : null,

    tags: map['tags'] == null || tagsPool.data == null
        ? null
        : Map.fromEntries(
            (map['tags'] as List<String>)
                // ensure is contained in tags pool
                .where((tid) => tagsPool.data!.keys.contains(tid))
                .map<MapEntry<String, Tag>>(
                  (tid) => MapEntry(tid, tagsPool.data![tid]!),
                ),
          ),
  );

  Map<String, dynamic> serialize() => {
    'id': id,
    'name': name,
    'record-count': recordCount,
    'created-at': createdAt.millisecondsSinceEpoch,
    'features': features.map(
      (key, value) => MapEntry(key, value.serialize()),
    ),
    if (schedules != null)
      'schedules': schedules!.map((k, s) => MapEntry(k, s.serialize())),
    if (cancelledSchedules != null)
      'cancelled-schedules': cancelledSchedules,
    if (color != null) 'color': color!.toARGB32(),
    if (tags != null) 'tags': tags!.keys.toList(),
  };

  Future<String> save() async {
    try {
      createdAt = DateTime.now();
      final eventType = await db.saveModel(this);
      eventProcessor.emitEvent(
        Event(
          entity: 'model',
          type: eventType,
          entityIds: [id],
          timestamp: DateTime.now(),
        ),
      );
      return eventType;
    } catch (e) {
      throw Exception('model save failed: $e');
    }
  }

  Future<bool> delete() async {
    try {
      await db.deleteModel(id);
      eventProcessor.emitEvent(
        Event(
          entity: 'model',
          type: 'delete',
          entityIds: [id],
          timestamp: DateTime.now(),
        ),
      );
      feedback('model deleted', type: FeedbackType.success);
      return true;
    } catch (e) {
      throw Exception('models delete error $e');
    }
  }

  addSchedule(Schedule sch) {
    schedules ??= {};
    schedules![sch.id] = sch;
  }

  List<Feature> getSortedFeatureList() {
    List<Feature> fts = features.values.toList();
    fts.sort((a, b) => a.position.compareTo(b.position));
    return fts;
  }
}
