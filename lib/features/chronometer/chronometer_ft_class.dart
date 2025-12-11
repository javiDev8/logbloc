import 'dart:async';
import 'package:logbloc/features/feature_class.dart';

class ChronometerFt extends Feature {
  Duration duration;
  bool isRunning;
  DateTime? start;

  ChronometerFt({
    required super.id,
    required super.type,
    required super.title,
    required super.pinned,
    required super.isRequired,
    required super.position,

    required this.duration,
    required this.isRunning,
    this.start,
  });

  @override
  double get completeness => duration.inSeconds > 0 ? 1.0 : 0.0;

  @override
  FutureOr<bool> onSave() async {
    if (isRunning) {
      // Stop the chronometer and update elapsed time when saving
      if (start != null) {
        final elapsed = DateTime.now().difference(start!);
        duration = duration + elapsed;
      }
      isRunning = false;
      start = null;
    }
    return true;
  }

  factory ChronometerFt.fromBareFt(
    Feature ft, {
    required Duration duration,
    required bool isRunning,
    DateTime? start,
  }) {
    return ChronometerFt(
      id: ft.id,
      type: ft.type,
      title: ft.title,
      pinned: ft.pinned,
      isRequired: ft.isRequired,
      position: ft.position,

      duration: duration,
      isRunning: isRunning,
      start: start,
    );
  }

  factory ChronometerFt.empty() => ChronometerFt.fromBareFt(
    Feature.empty('chronometer'),
    duration: Duration.zero,
    isRunning: false,
  );

  factory ChronometerFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) => ChronometerFt.fromBareFt(
    Feature.fromEntry(entry),
    duration: recordFt != null
        ? Duration(seconds: recordFt['duration'] as int)
        : Duration(seconds: (entry.value['duration'] as int?) ?? 0),
    isRunning: recordFt != null
        ? recordFt['isRunning'] as bool
        : entry.value['isRunning'] as bool? ?? false,
    start: recordFt != null && recordFt['start'] != null
        ? DateTime.fromMillisecondsSinceEpoch(recordFt['start'] as int)
        : (entry.value['start'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  entry.value['start'] as int,
                )
              : null),
  );

  @override
  Map<String, dynamic> serialize() => {
    ...super.serialize(),
    'duration': duration.inSeconds,
    'isRunning': isRunning,
    'start': start?.millisecondsSinceEpoch,
  };

  @override
  makeRec() => {
    ...super.makeRec(),
    'duration': duration.inSeconds,
    'isRunning': isRunning,
    'start': start?.millisecondsSinceEpoch,
  };
}
