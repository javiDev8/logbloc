import 'package:logbloc/apis/db.dart';
import 'package:logbloc/event_processor.dart';
import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/features/feature_switch.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/pools/tags/tags_pool.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/simple_pickers/simple_biweek_picker.dart';
import 'package:logbloc/utils/feedback.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:logbloc/utils/noticable_print.dart';

// the num represents a priority for sorting, being
// 0 the default, so "0" means is there, null means is not

typedef Features = Map<String, Feature>;

class Model {
  String id;
  String name;
  Features features;
  int recordCount;
  DateTime createdAt;
  Map<String, Schedule>? schedules;
  List<String>? simplePeriods;
  Map<String, List<String>>? cancelledSchedules;
  Color? color;
  List<String>? tags;

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
    this.simplePeriods,
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
    simplePeriods: map['simple-periods'],

    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created-at'] as int),

    features: Map.fromEntries(
      (map['features'] as Map<String, dynamic>).entries
          .map<MapEntry<String, Feature>>((ftEntry) {
            try {
              final Feature f =
                  featureSwitch(parseType: 'class', entry: ftEntry) as Feature;
              return MapEntry(ftEntry.key, f);
	    } catch (e) {
	      rethrow;
	    }
          }),
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

    cancelledSchedules: map['cancelled-schedules'] == null
        ? null
        : Map.fromEntries(
            (map['cancelled-schedules'] as Map<String, dynamic>).entries.map(
              (e) =>
                  MapEntry(e.key, List<String>.from(e.value as List<dynamic>)),
            ),
          ),

    color: (map['color'] as int?) == null
        ? null
        : Color.fromARGB(
            (map['color'] as int) >> 24 & 0xFF,
            (map['color'] as int) >> 16 & 0xFF,
            (map['color'] as int) >> 8 & 0xFF,
            (map['color'] as int) & 0xFF,
          ),

    tags: map['tags'] == null || tagsPool.data == null
        ? null
        : List.from(
            map['tags'] as List<dynamic>,
          ).where((t) => tagsPool.data!.contains(t)).cast<String>().toList(),
  );

  Map<String, dynamic> serialize() => {
    'id': id,
    'name': name,
    'record-count': recordCount,
    'created-at': createdAt.millisecondsSinceEpoch,
    if (simplePeriods?.isNotEmpty == true) 'simple-periods': simplePeriods,
    'features': features.map((key, value) => MapEntry(key, value.serialize())),
    if (schedules != null)
      'schedules': schedules!.map((k, s) => MapEntry(k, s.serialize())),
    if (cancelledSchedules != null) 'cancelled-schedules': cancelledSchedules,
    if (color != null) 'color': color!.toARGB32(),
    if (tags != null) 'tags': tags!,
  };

  Future<String> save({bool? silent}) async {
    try {
      for (final ft in features.values) {
        await ft.onModelSave(modelId: id);
      }

      createdAt = DateTime.now();
      final eventType = await db.saveModel(this);
      if (silent != true) {
        eventProcessor.emitEvent(
          Event(
            entity: 'model',
            type: eventType,
            entityIds: [id],
            timestamp: DateTime.now(),
          ),
        );
      }

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
      feedback('logbook deleted', type: FeedbackType.success);
      return true;
    } catch (e) {
      throw Exception('models delete error $e');
    }
  }

  addSchedule(Schedule sch) {
    schedules ??= {};
    schedules![sch.id] = sch;
  }

  cancelSchedule({required String date, required Schedule schedule}) async {
    if (schedule.period == null) {
      schedules!.remove(schedule.id);
    } else {
      cancelledSchedules ??= {};
      cancelledSchedules![date] ??= [];
      cancelledSchedules![date]!.add(schedule.id);
    }

    await save();
  }

  // gets all schedules that matches a date
  List<Schedule> getDateSchedules(DateTime date) {
    List<Schedule> schs = [];
    for (final period in Schedule.periods) {
      if (schedules?.isNotEmpty == true) {
        late final String day;
        switch (period) {
          case null:
            day = strDate(date);
            break;

          case 'everyday':
            day = 'everyday';
            break;

          case 'week':
            day = date.weekday.toString();
            break;

          case 'bi-week':
            day = dateToBiweekDay(date);
            break;

          case 'month':
            day = date.day.toString();
            break;

          case 'year':
            date.year.toString();
            break;
        }

        final schMatches = schedules!.values
            .where(
              (sch) =>
                  sch.period == null ||
                  sch.startDate!.millisecondsSinceEpoch <=
                      date.millisecondsSinceEpoch,
            )
            .where((sch) => sch.period == period && sch.day == day)
            .toList();

        schs.addAll(schMatches);
      }
    }

    return schs;
  }

  List<Feature> getSortedFeatureList() {
    List<Feature> fts = features.values.toList();

    List<Feature> pinned = [], unpinned = [];
    for (final ft in fts) {
      if (ft.pinned == true) {
        pinned.add(ft);
      } else {
        unpinned.add(ft);
      }
    }

    pinned.sort((a, b) => a.position.compareTo(b.position));
    unpinned.sort((a, b) => a.position.compareTo(b.position));
    return [...pinned, ...unpinned];
  }
}

class Schedule {
  String id;
  String day;
  double place;
  DateTime? startDate; // null for records
  String? period; // null -> puntual
  List<String>? includedFts; // null -> all
  bool? skipMatch;

  static const periods = [
    null,
    'day',
    'everyday',
    'week',
    'bi-week',
    'month',
    'year',
  ];

  Schedule({
    required this.id,
    required this.day,
    required this.place,
    this.startDate,
    this.period,
    this.includedFts,
    this.skipMatch,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) => Schedule(
    id: map['id'] as String,
    day: map['day'] as String,
    place: (map['place'] as num).toDouble(),
    startDate: map['start-date'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(map['start-date'] as int),
    period: map['period'] as String?,
    includedFts: map['includedFts'] as List<String>?,
    skipMatch: map['skip-match'],
  );

  factory Schedule.empty({required String day, String? period}) => Schedule(
    day: day,
    period: period,
    id: UniqueKey().toString(),
    place: DateTime.now().millisecondsSinceEpoch.toDouble(),
    startDate: DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    ),
  );

  serialize() => {
    'id': id,
    'day': day,
    'place': place,
    if (startDate != null) 'start-date': startDate!.millisecondsSinceEpoch,
    if (period != null) 'period': period,
    if (includedFts != null) 'includedFts': includedFts,
    if (skipMatch != null) 'skip-match': skipMatch,
  };
}
