import 'package:logize/apis/db.dart';
import 'package:logize/pools/items/item_class.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/tags/tags_pool.dart';
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
        await tagsPool.retrieve();
        final models = await db.models!.getAllValues();
        data = models.map<String, Model>((key, value) {
          try {
            final model = Model.fromMap(map: parseMap(value));
            return MapEntry(key.toString(), model);
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

  List<Item>? getDayItems(String strDay) {
    if (data == null) {
      retrieve();
      return null;
    }
    final List<Item> items = [];

    for (final period in Schedule.periods) {
      final date = DateTime.parse(strDay);
      late final String day;
      switch (period) {
        case null:
          day = strDay;
          break;
        case 'week':
          day = date.weekday.toString();
          break;
        case 'month':
          day = date.day.toString();
          break;
        case 'year':
          date.year.toString();
          break;
      }

      for (final model in data!.values) {
        if (model.schedules?.isNotEmpty == true) {
          final schMatches = model.schedules!.values.where(
            (sch) => sch.period == period && sch.day == day,
          );
          items.addAll(
            schMatches.map(
              (s) => Item(modelId: model.id, schedule: s, date: strDay),
            ),
          );
        }
      }
    }

    return items;
  }
}

// default data is null cause that way can
// mean "entire map is unloaded, not empty"
final modelsPool = ModelsPool(null);
