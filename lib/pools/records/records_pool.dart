import 'package:logize/apis/db.dart';
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
          return MapEntry(key, Rec.fromMap(parseMap(value)));
        });
      }
      emit();
    } catch (e) {
      throw Exception('Records retrieval failed: $e');
    }
  }

  List<Rec>? getRecordsByDay(String strday) {
    if (data == null) {
      retrieve();
      return null;
    }

    return data!.entries
        .where((rec) => rec.value.date == strday)
        .map<Rec>((re) => re.value)
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
