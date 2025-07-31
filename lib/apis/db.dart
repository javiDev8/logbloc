import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/records/record_class.dart';
import 'package:logize/utils/parse_map.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

typedef Col = CollectionBox<Map>?;

class HiveDB {
  Col records;
  Col models;
  BoxCollection? hdb;

  init() async {
    await Hive.initFlutter();
    hdb = await BoxCollection.open('deta-hive', {'records', 'models'});
    records = await hdb!.openBox<Map>('records');
    models = await hdb!.openBox<Map>('models');

    // CLEAR DATABASE (DEV PURPOSES ONLY)
    //await records!.clear();
    //await models!.clear();
  }

  Future<String> saveModel(Model model) async {
    final saveType =
        (await models!.get(model.id) == null) ? 'add' : 'update';
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
      final recordsToDelete =
          recs.where((record) => record['modelId'] == id).toList();
      for (final record in recordsToDelete) {
        await records!.delete(record['id']);
      }
      await models!.delete(id);
    });
  }

  // records

  Future<String> saveRecord(Rec record) async {
    if (await records!.get(record.id) == null) {
      await records!.put(record.id, record.serialize());
      await hdb!.transaction(() async {
        final modelMatch = (await models!.get(record.modelId))!;
        final model = Model.fromMap(map: parseMap(modelMatch));
        model.recordsQuantity++;
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
      model.recordsQuantity--;
      models!.put(model.id, model.serialize());
    });
  }
}

final db = HiveDB();
