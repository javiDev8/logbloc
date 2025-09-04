import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/screens/models/model_screen/model_screen.dart';
import 'package:logbloc/utils/feedback.dart';

// needed for average
// ignore:depend_on_referenced_packages
import 'package:collection/collection.dart';

class ModelEditPool extends Pool<Model> {
  bool dirty;

  List<String> editingFts = [];
  List<String> editingSchs = [];

  ModelEditPool(super.def) : dirty = false;

  dirt(bool? d) {
    if (dirty == (d ?? true)) return;
    dirty = d ?? true;
    controller.sink.add('dirty');
  }

  FutureOr<bool> save() async {
    if (!editModelFormKey.currentState!.validate() ||
        modelEditPool.data.name.isEmpty ||
        data.features.values.firstWhereOrNull((f) => f.title.isEmpty) !=
            null) {
      feedback('check your inputs', type: FeedbackType.error);
      return false;
    }
    if (modelEditPool.data.features.isEmpty) {
      feedback('add at least one feature', type: FeedbackType.error);
      return false;
    }
    await data.save();
    editingFts = [];
    editingSchs = [];
    dirt(false);
    feedback('logbook saved', type: FeedbackType.success);
    return true;
  }

  editExistingModel(Model model) {
    data = model;
    emit();
  }

  setName(String name) {
    data.name = name;
    controller.sink.add('name');
  }

  setFeature(Feature ft) {
    if (data.features[ft.key] == null) {
      // means feature is being added, so ensure appears on top
      ft.position = data.features.isNotEmpty
          ? data
                    .getSortedFeatureList()
                    .where((ft) => !ft.pinned)
                    .toList()[0]
                    .position -
                1
          : 0;
      editingFts.add(ft.id);
    }
    data.features[ft.key] = ft;
    controller.sink.add('features');
  }

  removeFeature(String key) {
    data.features.remove(key);
    editingFts.remove(key);
    controller.sink.add('features');
  }

  addSchedule(Schedule sch) {
    data.addSchedule(sch);
    editingSchs.add(sch.id);
    controller.sink.add('schedules');
    dirt(true);
  }

  List<Schedule>? getScheduleMatches(
    Schedule sch, {
    List<Schedule>? schList,
  }) => (schList ?? data.schedules?.values)
      ?.where(
        (s) => schList?.isNotEmpty == true
            ? (s.day == sch.day)
            : (s.period == sch.period && s.day == sch.day),
      )
      .toList();

  toggleSimpleSchedule(Schedule sch, {required List<Schedule>? matches}) {
    if (matches?.isNotEmpty == true) {
      for (final match in matches!) {
        data.schedules?.remove(match.id);
      }
      controller.sink.add('schedules');
    } else {
      addSchedule(sch);
    }
  }

  removeSchedule(String id) {
    data.schedules!.remove(id);
    controller.sink.add('schedules');
    dirt(true);
  }

  reorderFeature(int index, String ftKey, List<String> currentKeys) {
    final prevIndex = index == 0 ? null : index - 1;
    final nextIndex = index == data.features.length ? null : index;

    if (prevIndex == null ||
        (data.features[currentKeys[prevIndex]]!.pinned &&
            !data.features[ftKey]!.pinned)) {
      double lowest = double.infinity;
      for (final f in data.features.values) {
        if (f.position < lowest) lowest = f.position;
      }
      data.features[ftKey]!.position = lowest - 1;
    } else if (nextIndex == null ||
        (data.features[ftKey]!.pinned &&
            !data.features[currentKeys[nextIndex]]!.pinned)) {
      double greatest = 0;
      for (final f in data.features.values) {
        if (f.position > greatest) greatest = f.position;
      }
      data.features[ftKey]!.position = greatest + 1;
    } else {
      final sortedFts = data.getSortedFeatureList();
      data.features[ftKey]!.position = <double>[
        sortedFts[prevIndex].position,
        sortedFts[nextIndex].position,
      ].average;
    }

    controller.sink.add('features');
    dirt(true);
  }

  addTag(String tag) {
    if (data.tags?.contains(tag) == true) return;
    data.tags ??= [];
    data.tags!.add(tag);
    controller.sink.add('tags');
    dirt(true);
  }

  void removeTag(String key) {
    if (data.tags?.contains(key) == true) {
      data.tags!.remove(key);
      if (data.tags!.isEmpty) data.tags = null;
      controller.sink.add('tags');
      dirt(true);
    }
  }

  void setColor(Color c) {
    data.color = c;
    controller.sink.add('color');
  }

  setSchedulePeriod({required String period, required bool simple}) {
    if (simple) {
      data.simplePeriods ??= [];
      data.simplePeriods!.add(period);
    } else {
      data.simplePeriods!.removeWhere((p) => p == period);
    }
    controller.sink.add('schedules');
  }

  removeSimplePeriod({required String period}) {
    data.simplePeriods?.remove(period);
    data.schedules?.removeWhere((_, s) => s.period == period);
    controller.sink.add('schedules');
  }
}

final modelEditPool = ModelEditPool(Model.empty());
