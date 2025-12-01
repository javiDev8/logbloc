import 'dart:async';
import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/features/feature_switch.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/pools/records/record_class.dart';
import 'package:logbloc/pools/records/records_pool.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/screens/daily/item_screen.dart';
import 'package:logbloc/utils/feedback.dart';

class Item {
  final String id;
  final String modelId;
  String? recordId;
  String date;
  Features stagedFeatures;
  Schedule schedule;

  Item({
    required this.modelId,
    required this.schedule,
    this.recordId,
    required this.date,
  }) : stagedFeatures = {},
       id = UniqueKey().toString();

  Model? get model => modelsPool.data?[modelId];

  Rec? get record => recordsPool.data?[recordId];

  String? get modelName => model?.name;

  Features get features => Map.fromEntries(
    model?.features.entries
            .where(
              (ft) =>
                  schedule.includedFts == null ||
                  schedule.includedFts?.contains(ft.key) == true,
            )
            .map((entry) {
              final modelFt = entry.value;
              final serializedEntry = MapEntry(
                entry.key,
                entry.value.serialize(),
              );
              final parsedFt =
                  featureSwitch(
                        parseType: 'class',
                        entry: serializedEntry,
                        recordFt: record?.features[entry.key],
                      )
                      as Feature;
              return MapEntry(
                entry.key,
                record?.features[entry.key] != null ? parsedFt : modelFt,
              );
            }) ??
        [],
  );

  FutureOr<bool> save() async {
    if (!itemFormKey.currentState!.validate()) {
      feedback('check your inputs!', type: FeedbackType.error);
      return false;
    }
    dirtItemFlagPool.data = false;

    // run save hooks
    for (final ft in stagedFeatures.values) {
      final res = await ft.onSave();
      if (res != true) {
        return false;
      }
    }

    final serializedFeatures = Map.fromEntries(
      stagedFeatures.entries.map(
        (e) => MapEntry(e.key, e.value.makeRec()),
      ),
    );
    try {
      if (recordId == null) {
        await Rec(
          schedule: Schedule(
            id: schedule.id,
            day: date,
            includedFts: schedule.includedFts,
            place: schedule.place,
          ),
          id: UniqueKey().toString(),
          modelId: modelId,
          features: serializedFeatures,
	  completeness: getCompleteness(modelId: modelId, features: serializedFeatures)
        ).save();
      } else {
        recordsPool.data![recordId]!.features = serializedFeatures;
        await recordsPool.data![recordId]!.save();
      }

      feedback('${model!.name} record saved', type: FeedbackType.success);
      stagedFeatures = {};
      return true;
    } catch (e) {
      throw Exception('Item save failed: $e');
    }
  }

  saveSortPlace() async {
    if (recordId == null) {
      await model!.save(silent: true);
    } else {
      await record!.save(silent: true);
    }
  }

  List<Feature> getSortedFts({bool staged = false}) {
    final fts = staged
        ? stagedFeatures.values.toList()
        : features.values.toList();
    fts.sort((a, b) => a.position.compareTo(b.position));
    return fts;
  }
}
