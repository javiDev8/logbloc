import 'package:logize/features/feature_class.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/topbar_pool.dart';
import 'package:logize/screens/models/model_lead_menu_widget.dart';
import 'package:logize/screens/root_screen_switch.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:flutter/material.dart';

// needed for average
// ignore:depend_on_referenced_packages
import 'package:collection/collection.dart';

class ModelEditPool extends Pool<Model> {
  ModelEditPool(super.def);

  save() async {
    final modelCopy = Model.fromMap(map: data.serialize());
    final saveType = await data.save();
    topbarPool.popTitle();
    rootScreens[topbarPool.rootIndex].nav.currentState!.pop();
    if (saveType == 'update') {
      topbarPool.setCurrentTitle(
        // ignore: sized_box_for_whitespace
        Container(
          width: 290,
          child: Row(
            children: [
              Text(data.name),
              Exp(),
              Builder(
                builder: (context) => ModelLeadMenuWidget(
                  model: modelCopy,
                  parentCtx: context,
                ),
              ),
            ],
          ),
        ),
      );
    }

    clean();
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
  }

  clean() {
    data = Model.empty();
  }
}

final modelEditPool = ModelEditPool(Model.empty());
