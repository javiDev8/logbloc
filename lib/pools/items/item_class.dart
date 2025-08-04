import 'package:logize/features/feature_class.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/models_pool.dart';
import 'package:logize/pools/records/record_class.dart';
import 'package:logize/pools/records/records_pool.dart';
import 'package:flutter/material.dart';

class Item {
  final String id;
  final String modelId;
  String? recordId;
  String? date;
  Features stagedFeatures;
  MapEntry<String, double> winnerSchRule;

  Item({
    required this.modelId,
    this.recordId,
    this.date,
    required this.winnerSchRule,
  }) : stagedFeatures = {},
       id = UniqueKey().toString();

  Model? get model => modelsPool.data?[modelId];

  Rec? get record => recordsPool.data?[recordId];

  String? get modelName => model?.name;

  Features get features => Map.fromEntries(
    model?.features.entries.map((entry) {
          final modelFt = entry.value;
          final serializedEntry = MapEntry(
            entry.key,
            entry.value.serialize(),
          );
          return MapEntry(
            entry.key,
            record?.features[entry.key] != null
                ? featureSwitch(
                        parseType: 'class',
                        entry: serializedEntry,
                        recordFt: record?.features[entry.key],
                      )
                      as Feature
                : modelFt,
          );
        }) ??
        [],
  );

  save() async {
    final serializedFeatures = Map.fromEntries(
      stagedFeatures.entries.map(
        (e) => MapEntry(e.key, e.value.makeRec()),
      ),
    );
    try {
      if (recordId == null) {
        await Rec(
          sortPlace: winnerSchRule.value,
          id: UniqueKey().toString(),
          modelId: modelId,
          features: serializedFeatures,
          date: date!,
        ).save();
      } else {
        recordsPool.data![recordId]!.features = serializedFeatures;
        await recordsPool.data![recordId]!.save();
      }
      stagedFeatures = {};
    } catch (e) {
      throw Exception('Item save failed: $e');
    }
  }

  saveSortPlace() async {
    if (recordId == null) {
      await model!.save();
    } else {
      await record!.save();
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
