import 'package:logize/features/feature_class.dart';

class TextFt extends Feature {
  String prompt;
  String content;

  TextFt({
    required super.id,
    required super.type,
    required super.pinned,
    required super.isRequired,

    required this.prompt,
    required this.content,
  });

  factory TextFt.fromBareFt(
    Feature ft, {
    required String prompt,
    required String content,
  }) {
    return TextFt(
      id: ft.id,
      type: ft.type,
      pinned: ft.pinned,
      isRequired: ft.isRequired,
      prompt: prompt,
      content: content,
    );
  }

  @override
  factory TextFt.empty() =>
      TextFt.fromBareFt(Feature.empty('text'), prompt: '', content: '');

  @override
  factory TextFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) => TextFt.fromBareFt(
    Feature.fromEntry(entry),
    prompt: entry.value['prompt'] as String,
    content:
        recordFt != null
            ? recordFt['content'] as String
            : entry.value['content'] as String,
  );

  @override
  Map<String, dynamic> serialize() => {
    ...super.serialize(),
    'prompt': prompt,
    'content': content,
  };

  @override
  makeRec() => {'content': content};

  setPrompt(String newPrompt) => prompt = newPrompt;
  setContent(String newContent) => content = newContent;
}
