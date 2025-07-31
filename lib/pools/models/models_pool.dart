import 'package:logize/apis/db.dart';
import 'package:logize/pools/items/item_class.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/utils/feedback.dart';
import 'package:logize/utils/parse_map.dart';

typedef Models = Map<String, Model>;

class ModelsPool extends Pool<Models?> {
  ModelsPool(super.def);

  clean() {
    data = null;
    emit();
  }

  retrieve() async {
    if (data == null) {
      try {
        final models = await db.models!.getAllValues();
        data = models.map<String, Model>((key, value) {
          try {
            return MapEntry(
              key.toString(),
              Model.fromMap(map: parseMap(value)),
            );
          } catch (e) {
	    feedback('model parse error');
            throw Exception('Failed to parse : $e');
          }
        });
        emit();
      } catch (e) {
        feedback('Failed to retrieve models: $e');
        throw Exception('Failed to retrieve models: $e');
      }
    }
  }

  List<Item>? getModelItemsByDay(String strDay) {
    if (data == null) {
      retrieve();
      return null;
    }
    final ruleTypes = ['week-day', 'day'];

    // get all models for given date classified by rule type
    final Map<String, Map<String, Model>> scheduleMap = Map.fromEntries(
      ruleTypes.map<MapEntry<String, Map<String, Model>>>((ruletype) {
        late final String key;
        switch (ruletype) {
          case 'week-day':
            key = (DateTime.parse(strDay).weekday - 1).toString();
            break;
          case 'day':
            key = strDay;
            break;
        }

        return MapEntry(
          ruletype,
          Map.fromEntries(
            data!.values
                .where((m) => m.scheduleRules?[ruletype]?[key] != null)
                .map<MapEntry<String, Model>>(
                  (m) => MapEntry('$key/${m.id}', m),
                )
                .toList(),
          ),
        );
      }),
    );

    if (scheduleMap['week-day']!.isNotEmpty &&
        scheduleMap['day']!.isNotEmpty) {
      // remove low hierarchy rule matched models,
      // for now is just "day" over "weekly-day"
      scheduleMap['week-day']!.removeWhere((key, weekModel) {
        late Model? modelMatch;
        try {
          modelMatch = scheduleMap['day']!.values.firstWhere(
            (dayModel) => dayModel.id == weekModel.id,
          );
        } catch (e) {
          modelMatch = null;
        }
        if (modelMatch == null) {
          return false;
        }
        return true;
      });
    }

    // apply cancelations
    if (scheduleMap['day']!.isNotEmpty) {
      scheduleMap['day']!.removeWhere(
        (sch, m) => m.scheduleRules!['day']![sch.split('/')[0]] == 'c',
      );
    }

    // parse crazy map to lists of items
    final List<List<Item>> itemLists = scheduleMap.keys
        .map<List<Item>>(
          (type) => scheduleMap[type]!.entries
              .map<Item>(
                (e) => Item(
                  modelId: e.value.id,
                  date: strDay,
                  winnerSchRule: MapEntry(
                    '$type/${e.key}',
                    double.parse(
                      e.value.scheduleRules![type]![e.key.split('/')[0]]!,
                    ),
                  ),
                ),
              )
              .toList(),
        )
        .toList();

    return [...itemLists[0], ...itemLists[1]];
  }
}

// default data is null cause that way can
// mean "entire map is unloaded, not empty"
final modelsPool = ModelsPool(null);
