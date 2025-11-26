import 'dart:async';

import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/utils/feedback.dart';

class ChronometerFt extends Feature {
  DateTime? start;
  Duration? duration;

  @override
  get isEmpty => start == null && duration == null;

  ChronometerFt({
    required super.id,
    required super.type,
    required super.title,
    required super.pinned,
    required super.isRequired,
    required super.position,

    this.duration,
    this.start,
  });

  factory ChronometerFt.fromBareFt(
    Feature ft, {
    required Duration? duration,
    required DateTime? start,
  }) => ChronometerFt(
    id: ft.id,
    type: ft.type,
    title: ft.title,
    pinned: ft.pinned,
    isRequired: ft.isRequired,
    position: ft.position,

    duration: duration,
    start: start,
  );

  factory ChronometerFt.empty() => ChronometerFt.fromBareFt(
    Feature.empty('chronometer'),
    duration: null,
    start: null,
  );

  factory ChronometerFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) {
    final ft = Feature.fromEntry(entry);
    final res = ChronometerFt.fromBareFt(
      ft,
      duration:
          entry.value['duration'] != null || recordFt?['duration'] != null
          ? Duration(
              milliseconds:
                  ((entry.value['duration'] ?? recordFt?['duration'])
                      as int),
            )
          : null,

      start: entry.value['start'] != null || recordFt?['start'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              ((entry.value['start'] ?? recordFt?['start']) as int),
            )
          : null,
    );
    return res;
  }

  @override
  Map<String, dynamic> serialize() => {
    ...super.serialize(),
    'duration': duration?.inMilliseconds,
    'start': start?.millisecondsSinceEpoch,
  };

  @override
  makeRec() => {
    ...super.makeRec(),
    'duration': duration?.inMilliseconds,
    'start': start?.millisecondsSinceEpoch,
  };

  @override
  FutureOr<bool> onSave({String? modelId}) async {
    if (isRequired && duration == null) {
      feedback(
        'chronometer "$title" is required',
        type: FeedbackType.error,
      );
      return false;
    }
    return true;
  }
}
