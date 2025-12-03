import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logbloc/features/feature_class.dart';

//
final moods = {
  'happy': {
    'label': 'Happy',
    'color': Color(0xFFFFD700),
    'icon': (FluentIcons.emoji_smile_slight_24_filled),
  },
  'angry': {
    'label': 'Angry',
    'color': Color(0xFFFF4500),
    'icon': (FluentIcons.emoji_angry_24_filled),
  },
  'fear': {
    'label': 'Frown',
    'color': Color(0xFF8A2BE2),
    'icon': (MdiIcons.emoticonFrown),
  },
  'surprise': {
    'label': 'Excited',
    'color': Color(0xFFFF69B4),
    'icon': (FluentIcons.emoji_surprise_24_filled),
  },
  'disgust': {
    'label': 'Disgusted',
    'color': Color(0xFF32CD32),
    'icon': (MdiIcons.emoticonSick),
  },
  'sad': {
    'label': 'Sad',
    'color': Color(0xFF1E90FF),
    'icon': (FluentIcons.emoji_sad_24_filled),
  },
  'neutral': {
    'label': 'Neutral',
    'color': Color(0xFFDEB887),
    'icon': (FluentIcons.emoji_meh_24_filled),
  },
};

class MoodFt extends Feature {
  String? moodId;
  int? intensity; // 0 to 10

  MoodFt({
    required super.id,
    required super.type,
    required super.title,
    required super.pinned,
    required super.isRequired,
    required super.position,

    this.moodId,
    this.intensity,
  });

  @override
  double get completeness => moodId == null ? 0 : 1;

  factory MoodFt.fromBareFt(
    Feature ft, {
    required String? moodId,
    required int? intensity,
  }) {
    return MoodFt(
      id: ft.id,
      type: ft.type,
      title: ft.title,
      pinned: ft.pinned,
      isRequired: ft.isRequired,
      position: ft.position,

      moodId: moodId,
      intensity: intensity,
    );
  }

  factory MoodFt.empty() =>
      MoodFt.fromBareFt(Feature.empty('mood'), moodId: null, intensity: 5);

  factory MoodFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) => MoodFt.fromBareFt(
    Feature.fromEntry(entry),
    moodId: recordFt != null
        ? recordFt['moodId'] as String?
        : entry.value['moodId'] as String?,

    intensity: recordFt != null
        ? recordFt['intensity'] as int?
        : entry.value['intensity'] as int?,
  );

  // in 0-255 color alpha format
  get opacity => intensity!.toDouble() * 12.55 + 125.5;

  @override
  Map<String, dynamic> serialize() => {
    ...super.serialize(),
    'moodId': moodId,
    'intensity': intensity,
  };

  @override
  makeRec() => {
    ...super.makeRec(),
    'moodId': moodId,
    'intensity': intensity,
  };
}
