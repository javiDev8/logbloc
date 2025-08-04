import 'package:logize/features/feature_class.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/topbar_pool.dart';
import 'package:logize/screens/models/model_lead_menu_widget.dart';
import 'package:logize/screens/root_screen_switch.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:flutter/material.dart';

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
    data.features[ft.key] = ft;
    controller.sink.add('features');
  }

  removeFeature(String key) {
    data.features.remove(key);
    controller.sink.add('features');
  }

  addScheduleRuleKey(String key) {
    data.scheduleRules ??= {};
    if (data.scheduleRules!.containsKey(key)) return;
    data.scheduleRules![key] = {};
    controller.sink.add('schedule-rules');
  }

  removeScheduleKey(String key) {
    data.scheduleRules!.remove(key);
    controller.sink.add('schedule-rules');
  }

  addSchedule(map) {
    data.addScheduleRule(map);
    controller.sink.add('schedule-rules');
  }

  removeSchedule(Map<String, dynamic> map) {
    data.scheduleRules![map.keys.first]!.remove(map.values.first);
    controller.sink.add('schedule-rules');
  }

  setColor(Color color) {
    data.color = color;
    controller.sink.add('color');
  }

  clean() {
    data = Model.empty();
  }
}

final modelEditPool = ModelEditPool(Model.empty());
