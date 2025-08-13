import 'package:logize/apis/db.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/tags/tag_class.dart';

class TagsPool extends Pool<Map<String, Tag>?> {
  TagsPool(super.def);

  retrieve() async {
    if (data != null) return;
    try {
      final tags = await db.tags!.getAllValues();
      data = Map.fromEntries(
        tags.entries.map(
          (t) => MapEntry(
            t.key,
            Tag.fromMap(Map<String, dynamic>.from(t.value)),
          ),
        ),
      );

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
