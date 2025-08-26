import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:logize/features/feature_class.dart';
import 'package:logize/utils/feedback.dart';
import 'package:path_provider/path_provider.dart';

class PictureFt extends Feature {
  String? path;
  XFile? tmpFile;

  PictureFt({
    required super.id,
    required super.type,
    required super.title,
    required super.pinned,
    required super.isRequired,
    required super.position,

    this.tmpFile,
    this.path,
  });

  factory PictureFt.fromBareFt(Feature ft, {required String? path}) =>
      PictureFt(
        id: ft.id,
        type: ft.type,
        title: ft.title,
        pinned: ft.pinned,
        isRequired: ft.isRequired,
        position: ft.position,

        path: path,
      );

  factory PictureFt.empty() =>
      PictureFt.fromBareFt(Feature.empty('picture'), path: null);

  factory PictureFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) {
    final ft = Feature.fromEntry(entry);
    final res = PictureFt.fromBareFt(
      ft,
      path: entry.value['path'] ?? recordFt?['path'] as String?,
    );
    return res;
  }

  @override
  Map<String, dynamic> serialize() => {...super.serialize(), 'path': path};

  @override
  Map<String, dynamic> makeRec() {
    return {...super.makeRec(), 'path': path};
  }

  @override
  FutureOr<bool> onSave({String? modelId}) async {
    if (tmpFile == null) {
      if (isRequired && path == null) {
        feedback('picture "$title" is required', type: FeedbackType.error);
        return false;
      }
      return true;
    }

    try {
      final file = File(tmpFile!.path);
      final dir = await getApplicationDocumentsDirectory();
      path =
          '${dir.path}/logize-pic-${DateTime.now().millisecondsSinceEpoch}';
      await file.copy(path!);
      return true;
    } catch (e) {
      throw Exception('img saving failed! e: $e');
    }
  }

  setFile(XFile file) {
    tmpFile = file;
  }
}
