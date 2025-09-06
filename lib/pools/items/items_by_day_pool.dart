import 'package:logbloc/pools/items/item_class.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/records/records_pool.dart';

// needed for average
// ignore:depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:logbloc/screens/daily/daily_screen.dart';
import 'package:logbloc/utils/feedback.dart';
import 'package:logbloc/utils/fmt_date.dart';

typedef ItemsByDay = Map<String, List<Item>>;

class ItemsByDayPool extends Pool<ItemsByDay> {
  ItemsByDayPool(super.def);

  void retrieve(String strDay) {
    final List<Item> items = [];

    if (data[strDay] == null) {
      final recordItems = recordsPool.getDayItems(strDay);
      final modelItems = modelsPool.getDayItems(strDay);

      if (modelItems == null || recordItems == null) {
        Future.delayed(
          Duration(milliseconds: 100),
          () => retrieve(strDay),
        );
        return;
      }

      items.addAll(recordItems);

      items.addAll(
        modelItems.where((mi) {
          if (mi.model!.cancelledSchedules?[strDay]?.contains(
                mi.schedule.id,
              ) ==
              true) {
            return false;
          }

          final recordMatch = recordItems.firstWhereOrNull(
            (ri) => ri.schedule.id == mi.schedule.id,
          );
          if (recordMatch == null) {
            return true;
          } else {
            return false;
          }
        }),
      );

      data[strDay] = items;
    }
    emit();
  }

  scheduleModel(Model model, DateTime date) async {
    final dateStr = strDate(date);
    if (data[dateStr] == null) data[dateStr] = [];

    final sch = Schedule.empty(day: dateStr);
    model.addSchedule(sch);
    await model.save();

    data[dateStr]!.add(
      Item(modelId: model.id, date: dateStr, schedule: sch),
    );
    controller.sink.add('clean-up');

    agendaFilterPool.data = MapEntry('all', null);
    feedback('${model.name} entry added', type: FeedbackType.success);
  }

  reorderItem({
    required String strDay,
    required Item item,
    required int index,
  }) async {
    final prevIndex = index == 0 ? null : index - 1;
    final nextIndex = index == data[strDay]!.length ? null : index;

    final placeAbove = prevIndex == null
        ? null
        : data[strDay]![prevIndex].schedule.place;
    final placeBelow = nextIndex == null
        ? null
        : data[strDay]![nextIndex].schedule.place;

    late final double newPlace;
    if (prevIndex == null) {
      // if sent to top
      double lowest = double.infinity;
      for (final i in data[strDay]!) {
        if (i.schedule.place < lowest) {
          lowest = i.schedule.place;
        }
      }

      newPlace = [0.0, lowest].average;
    } else if (nextIndex == null) {
      //if sent to bottom
      double greatest = 0;
      for (final i in data[strDay]!) {
        if (i.schedule.place > greatest) {
          greatest = i.schedule.place;
        }
      }
      newPlace = greatest + 1;
    } else {
      newPlace = [placeAbove!, placeBelow!].average;
    }

    if (item.recordId == null) {
      if (item.schedule.period == null) {
        item.model!.schedules![item.schedule.id]?.place = newPlace;
      } else {
        final sch = Schedule.empty(day: item.date);
        sch.place = newPlace;
        sch.includedFts = item.schedule.includedFts;

        item.model!.addSchedule(sch);
        item.model!.cancelSchedule(
          date: item.date,
          schedule: item.schedule,
        );
      }
      modelsPool.data![item.model!.id] = item.model!;
    } else {
      item.record!.schedule.place = newPlace;
      recordsPool.data![item.record!.id] = item.record!;
    }
    item.saveSortPlace();
    itemsByDayPool.data = {};
    retrieve(strDay);
    controller.sink.add('clean-up');
  }

  clean() {
    data = {};
    controller.sink.add('clean-up');
  }
}

final itemsByDayPool = ItemsByDayPool({});
