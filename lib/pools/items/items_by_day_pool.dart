import 'package:logize/pools/items/item_class.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/models_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/records/records_pool.dart';
import 'package:logize/utils/fmt_date.dart';

// needed for average
// ignore:depend_on_referenced_packages
import 'package:collection/collection.dart';

typedef ItemsByDay = Map<String, List<Item>>;

class ItemsByDayPool extends Pool<ItemsByDay> {
  ItemsByDayPool(super.def);

  void retrieve(String strDay) {
    final List<Item> items = [];

    if (data[strDay] == null) {
      final records = recordsPool.getRecordsByDay(strDay);
      // model items are fetched with its own pool method because
      // schedule rule winner has to be got from comparision
      final modelItems = modelsPool.getModelItemsByDay(strDay);

      if (modelItems == null || records == null) {
        Future.delayed(Duration(seconds: 1), () => retrieve(strDay));
        return;
      }

      final recordItems =
          records.map<Item>((record) {
            // "swallow" model
            try {
              modelItems.removeAt(
                modelItems.indexOf(
                  modelItems.firstWhere(
                    (m) => m.model!.id == record.modelId,
                  ),
                ),
              );
              // ignore: empty_catches
            } catch (e) {}

            return Item(
              date: strDay,
              modelId: record.modelId,
              recordId: record.id,
              winnerSchRule: MapEntry('day/$strDay', record.sortPlace),
            );
          }).toList();

      items.addAll([...modelItems, ...recordItems]);
      data[strDay] = items;
      emit();
    } else {
      emit();
    }
  }

  scheduleModel(Model model, DateTime date) async {
    final dateStr = strDate(date);
    if (data[dateStr] == null) data[dateStr] = [];

    model.addScheduleRule({'day': dateStr});
    await model.save();

    data[dateStr]!.add(
      Item(
        modelId: model.id,
        date: dateStr,
        winnerSchRule: MapEntry(dateStr, 0.0),
      ),
    );
    controller.sink.add('clean-up');
  }

  reorderItem({
    required String strDay,
    required Item item,
    required int index,
  }) async {
    final prevIndex = index == 0 ? null : index - 1;
    final nextIndex = index == data[strDay]!.length ? null : index;

    // "place" here means a value used for sorting

    final placeAbove =
        prevIndex == null
            ? null
            : data[strDay]![prevIndex].winnerSchRule.value;
    final placeBelow =
        nextIndex == null
            ? null
            : data[strDay]![nextIndex].winnerSchRule.value;

    // list is built from top to bottom, so
    // lowest sort place means top and
    // greatest sort place means bottom

    late final double newSortPlace;
    if (prevIndex == null) {
      // if sent to top
      double lowest = double.infinity;
      for (final i in data[strDay]!) {
        if (i.winnerSchRule.value < lowest) {
          lowest = i.winnerSchRule.value;
        }
      }

      newSortPlace = [0.0, lowest].average;
    } else if (nextIndex == null) {
      //if sent to bottom
      double greatest = 0;
      for (final i in data[strDay]!) {
        if (i.winnerSchRule.value > greatest) {
          greatest = i.winnerSchRule.value;
        }
      }
      newSortPlace = greatest + 1;
    } else {
      newSortPlace = [placeAbove!, placeBelow!].average;
    }

    final ruleType = item.winnerSchRule.key.split('/')[0];
    final ruleKey = item.winnerSchRule.key.split('/')[1];

    if (item.recordId == null) {
      if (ruleType == 'day') {
        item.model!.scheduleRules![ruleType]![ruleKey] =
            newSortPlace.toString();
      } else {
        // add 'day' type sch rule to override sort place for
        // the given day
        item.model!.scheduleRules!['day'] ??= {};
        item.model!.scheduleRules!['day']![strDay] =
            newSortPlace.toString();
      }
    } else {
      item.record!.sortPlace = newSortPlace;
    }
    await item.saveSortPlace();
    controller.sink.add('clean-up');
  }

  clean() {
    data = {};
    controller.sink.add('clean-up');
  }
}

final itemsByDayPool = ItemsByDayPool({});
