import 'package:logize/apis/db.dart';
import 'package:logize/pools/items/item_class.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/records/record_class.dart';
import 'package:logize/utils/parse_map.dart';

class RecordsPool extends Pool<Map<String, Rec>?> {
  RecordsPool(super.def);

  retrieve() async {
    try {
      if (data == null) {
        final records = await db.records!.getAllValues();
        if (records.isEmpty) {
          data = {};
          emit();
          return;
        }
        data = records.map<String, Rec>((key, value) {
          final map = MapEntry(key, Rec.fromMap(parseMap(value)));
          return map;
        });
      }
      emit();
    } catch (e) {
      throw Exception('Records retrieval failed: $e');
    }
  }

  List<Item>? getDayItems(String strDay) {
    if (data == null) {
      retrieve();
      return null;
    }

    return data!.values
        .where((rec) => rec.schedule.day == strDay)
        .map<Item>(
          (rec) => Item(
            recordId: rec.id,
            modelId: rec.modelId,
            schedule: rec.schedule,
            date: strDay,
          ),
        )
        .toList();
  }

  List<Rec>? getRecordsByModel(String modelId) {
    if (data == null) {
      retrieve();
      return null;
    }

    return data!.entries
        .where((rec) => rec.value.modelId == modelId)
        .map<Rec>((re) => re.value)
        .toList();
  }

  clean() {
    data = null;
    emit();
  }
}

final recordsPool = RecordsPool(null);
