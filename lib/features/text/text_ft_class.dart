import 'package:logize/features/feature_class.dart';

class TextFt extends Feature {
  String content;

  TextFt({
    required super.id,
    required super.type,
    required super.title,
    required super.pinned,
    required super.isRequired,
    required super.position,

    required this.content,
  });

  factory TextFt.fromBareFt(Feature ft, {required String content}) {
    return TextFt(
      id: ft.id,
      type: ft.type,
      title: ft.title,
      pinned: ft.pinned,
      isRequired: ft.isRequired,
      position: ft.position,

      content: content,
    );
  }

  @override
  factory TextFt.empty() =>
      TextFt.fromBareFt(Feature.empty('text'), content: '');

  @override
  factory TextFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) => TextFt.fromBareFt(
    Feature.fromEntry(entry),
    content: recordFt != null
        ? recordFt['content'] as String
        : entry.value['content'] as String,
  );

  @override
  Map<String, dynamic> serialize() => {
    ...super.serialize(),
    'content': content,
  };

  @override
  makeRec() => {...super.makeRec(), 'content': content};

  setContent(String newContent) => content = newContent;
}
