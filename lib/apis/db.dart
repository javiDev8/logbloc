import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/models_pool.dart';
import 'package:logize/pools/records/record_class.dart';
import 'package:logize/pools/tags/tag_class.dart';
import 'package:logize/utils/feedback.dart';
import 'package:logize/utils/parse_map.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

typedef Col = CollectionBox<Map>?;

class HiveDB {
  Col records;
  Col models;
  Col tags;
  BoxCollection? hdb;

  init() async {
    try {
      await Hive.initFlutter();
      hdb = await BoxCollection.open('/logizehivedb', {
        'records',
        'models',
        'tags',
      });
      records = await hdb!.openBox<Map>('records');
      models = await hdb!.openBox<Map>('models');
      tags = await hdb!.openBox<Map>('tags');

      if (records == null || models == null || tags == null) {
        throw Exception('null boxes');
      }

      // CLEAR DATABASE (DEV PURPOSES ONLY)
      await records!.clear();
      await models!.clear();
      await tags!.clear();
    } catch (e) {
      feedback('failed to init db: $e');
    }
  }

  // models

  Future<String> saveModel(Model model) async {
    final saveType = (await models!.get(model.id) == null)
        ? 'add'
        : 'update';
    await models!.put(model.id, model.serialize());
    return saveType;
  }

  updateModel({required Map<String, dynamic> modelMap}) async {
    await models!.put(modelMap['id'], modelMap);
  }

  deleteModel(String id) async {
    await hdb!.transaction(() async {
      final recs = (await records!.getAllValues()).values;
      if (recs.isEmpty) return;
      final recordsToDelete = recs
          .where((record) => record['modelId'] == id)
          .toList();
      for (final record in recordsToDelete) {
        await records!.delete(record['id']);
      }
    });
    // must be outside transaction
    await models!.delete(id);
  }

  // records

  Future<String> saveRecord(Rec record) async {
    if (await records!.get(record.id) == null) {
      await records!.put(record.id, record.serialize());
      await hdb!.transaction(() async {
        final modelMatch = (await models!.get(record.modelId))!;
        final model = Model.fromMap(map: parseMap(modelMatch));
        model.recordCount++;
        await models!.put(model.id, model.serialize());
      });
      return 'add';
    } else {
      await records!.put(record.id, record.serialize());
      return 'update';
    }
  }

  deleteRecord(Rec record) async {
    records!.delete(record.id);

    await hdb!.transaction(() async {
      final modelMap = await models!.get(record.modelId);
      final model = Model.fromMap(map: parseMap(modelMap!));
      model.recordCount--;
      models!.put(model.id, model.serialize());
    });
  }

  // tags

  saveTag(Tag tag) async => await tags!.put(tag.id, tag.serialize());

  deleteTag(String key) async {
    await tags!.delete(key);

    final taggedModelIds = modelsPool.data!.values
        .where((model) => model.tags?.containsKey(key) == true)
        .map((model) => model.id)
        .toList();

    await models!.deleteAll(taggedModelIds);
  }
}

final db = HiveDB();
