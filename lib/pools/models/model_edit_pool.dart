import 'package:logize/features/feature_class.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/models/model_screen/model_screen.dart';
import 'package:logize/utils/feedback.dart';
import 'package:logize/utils/nav.dart';

// needed for average
// ignore:depend_on_referenced_packages
import 'package:collection/collection.dart';

class ModelEditPool extends Pool<Model> {
  bool dirty;

  ModelEditPool(super.def) : dirty = false;

  dirt(bool? d) {
    dirty = d ?? true;
    controller.sink.add('dirty');
  }

  save() async {
    if (modelEditPool.data.name.isEmpty ||
        !editModelFormKey.currentState!.validate() ||
        data.features.values.firstWhereOrNull((f) => f.title.isEmpty) !=
            null) {
      feedback('check your inputs', type: FeedbackType.error);
      return;
    }
    if (modelEditPool.data.features.isEmpty) {
      feedback('add at least one feature', type: FeedbackType.error);
      return;
    }
    final saveType = await data.save();
    feedback('model saved', type: FeedbackType.success);
    dirt(false);
    if (saveType == 'add') {
      navPop();
    }
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
    if (data.features[ft.key] == null && data.features.isNotEmpty) {
      // means feature is being added, so ensure appears on top
      ft.position = data.getSortedFeatureList()[0].position - 1;
    }
    data.features[ft.key] = ft;
    controller.sink.add('features');
  }

  removeFeature(String key) {
    data.features.remove(key);
    controller.sink.add('features');
  }

  addSchedule(Schedule sch) {
    data.addSchedule(sch);
    controller.sink.add('schedules');
  }

  reorderFeature(int index, String ftKey) {
    final prevIndex = index == 0 ? null : index - 1;
    final nextIndex = index == data.features.length ? null : index;

    if (prevIndex == null) {
      double lowest = double.infinity;
      for (final f in data.features.values) {
        if (f.position < lowest) lowest = f.position;
      }
      data.features[ftKey]!.position = lowest - 1;
    } else if (nextIndex == null) {
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
}

final modelEditPool = ModelEditPool(Model.empty());
