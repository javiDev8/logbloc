import 'package:logize/apis/db.dart';
import 'package:logize/event_processor.dart';
import 'package:logize/features/feature_class.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:flutter/material.dart';

// the num represents a priority for sorting, being
// 0 the default, so "0" means is there, null means is not
typedef ScheduleRules = Map<String, Map<String, String>>;

typedef Features = Map<String, Feature>;

class Model {
  String id;
  String name;
  Features features;
  ScheduleRules? scheduleRules;
  int recordsQuantity;
  Color? color;

  Model({
    required this.name,
    required this.features,
    required this.recordsQuantity,
    required this.id,
    this.scheduleRules,
    this.color,
  });

  factory Model.empty() => Model(
    name: '',
    features: {},
    recordsQuantity: 0,
    id: UniqueKey().toString(),
  );

  factory Model.fromMap({required Map<String, dynamic> map}) => Model(
    id: map['id'],
    name: map['name'],
    recordsQuantity: map['records-quantity'] as int,
    color:
        map.containsKey('color')
            ? Color(int.parse(map['color'] as String))
            : null,
    features: Map.fromEntries(
      (map['features'] as Map<String, dynamic>).entries
          .map<MapEntry<String, Feature>>(
            (ftEntry) => MapEntry(
              ftEntry.key,
              featureSwitch(parseType: 'class', entry: ftEntry) as Feature,
            ),
          ),
    ),
    scheduleRules: (map['scheduleRules'] as Map<String, dynamic>?)?.map(
      (key, value) => MapEntry(
        key,
        (value as Map<String, dynamic>).map((k, v) => MapEntry(k, v)),
      ),
    ),
  );

  Map<String, dynamic> serialize() {
    final map = {
      'id': id,
      'name': name,
      'records-quantity': recordsQuantity,
      'features': features.map(
        (key, value) => MapEntry(key, value.serialize()),
      ),
      'scheduleRules': scheduleRules,
    };
    if (color != null) {
      map['color'] = color!.toARGB32().toString();
    }
    return map;
  }

  Future<String> save() async {
    try {
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

  delete() async {
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
    } catch (e) {
      throw Exception('models delete error $e');
    }
  }

  addScheduleRule(
    Map<String, String> map,
    // expected map format is { 'day': '2025-06-01' } or
    // { 'week-day': '3' } or { 'month-day': 15 } ...etc
  ) {
    scheduleRules ??= {};
    scheduleRules![map.entries.first.key] ??= {};
    if ((scheduleRules![map.entries.first.key]!.containsKey(
          map.entries.first.value,
        )) &&
        map.keys.first == 'week-day') {
      scheduleRules![map.entries.first.key]!.remove(
        map.entries.first.value,
      );
    } else {
      scheduleRules![map.entries.first.key]![map.entries.first.value] =
          '${DateTime.now().millisecondsSinceEpoch.toString()}.0';
    }
  }

  cancelSchedule(String strDate) async {
    if (scheduleRules!.containsKey('day') &&
        scheduleRules!['day']!.containsKey(strDate)) {
      scheduleRules!['day']!.remove(strDate);
    } else {
      scheduleRules!['day'] ??= {};
      scheduleRules!['day']![strDate] = 'c';
    }
    await save();
  }
}
