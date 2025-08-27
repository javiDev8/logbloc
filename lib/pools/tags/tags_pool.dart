import 'package:logbloc/apis/db.dart';
import 'package:logbloc/pools/pools.dart';

class TagsPool extends Pool<List<String>?> {
  TagsPool(super.def);

  retrieve() async {
    if (data != null) return;
    try {
      data = (await db.tags!.getAllValues()).keys.toList();
      emit();
    } catch (e) {
      throw Exception('tags retrieve exception: $e');
    }
  }

  clean() {
    data = null;
    emit();
  }
}

final tagsPool = TagsPool(null);
