import 'package:logize/apis/db.dart';
import 'package:logize/event_processor.dart';
import 'package:logize/features/feature_class.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:flutter/material.dart';

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
        place: 0.0,
      );

  Map<String, dynamic> serialize() => {
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
  int recordsQuantity;
  Color? color;

  List<Schedule>? schedules;
  List<String>? cancelledDates;

  Model({
    required this.name,
    required this.features,
    required this.recordsQuantity,
    required this.id,
    this.color,
    this.schedules,
    this.cancelledDates,
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
    color: map.containsKey('color')
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
    schedules: map['schedules'] == null
        ? null
        : List<Schedule>.from(
            map['schedules']?.map<Schedule>(
              (e) => Schedule.fromMap(Map<String, dynamic>.from(e)),
            ),
          ),

    cancelledDates: map['cancelled-dates'],
  );

  Map<String, dynamic> serialize() => {
    'id': id,
    'name': name,
    'records-quantity': recordsQuantity,
    'features': features.map(
      (key, value) => MapEntry(key, value.serialize()),
    ),

    if (color != null) 'color': color!.toARGB32().toString(),
    if (schedules != null)
      'schedules': schedules!.map((s) => s.serialize()).toList(),
    if (cancelledDates != null) 'cancelled-dates': cancelledDates,
  };

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

  addSchedule(Schedule sch) {
    schedules ??= [];
    schedules!.add(sch);
  }

  List<Feature> getSortedFeatureList() {
    List<Feature> fts = features.values.toList();
    fts.sort((a, b) => a.position.compareTo(b.position));
    return fts;
  }
}
