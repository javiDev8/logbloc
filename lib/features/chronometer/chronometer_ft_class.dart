import 'dart:async';
import 'package:logbloc/features/feature_class.dart';

class ChronometerFt extends Feature {
  Duration elapsedTime;
  bool isRunning;
  DateTime? startTime;

  ChronometerFt({
    required super.id,
    required super.type,
    required super.title,
    required super.pinned,
    required super.isRequired,
    required super.position,

    required this.elapsedTime,
    required this.isRunning,
    this.startTime,
  });

  @override
  double get completeness => elapsedTime.inSeconds > 0 ? 1.0 : 0.0;

  @override
  FutureOr<bool> onSave() async {
    if (isRunning) {
      // Stop the chronometer and update elapsed time when saving
      if (startTime != null) {
        final elapsed = DateTime.now().difference(startTime!);
        elapsedTime = elapsedTime + elapsed;
      }
      isRunning = false;
      startTime = null;
    }
    return true;
  }

  factory ChronometerFt.fromBareFt(
    Feature ft, {
    required Duration elapsedTime,
    required bool isRunning,
    DateTime? startTime,
  }) {
    return ChronometerFt(
      id: ft.id,
      type: ft.type,
      title: ft.title,
      pinned: ft.pinned,
      isRequired: ft.isRequired,
      position: ft.position,

      elapsedTime: elapsedTime,
      isRunning: isRunning,
      startTime: startTime,
    );
  }

  factory ChronometerFt.empty() => ChronometerFt.fromBareFt(
    Feature.empty('chronometer'),
    elapsedTime: Duration.zero,
    isRunning: false,
  );

  factory ChronometerFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) => ChronometerFt.fromBareFt(
    Feature.fromEntry(entry),
    elapsedTime: recordFt != null
        ? Duration(seconds: recordFt['elapsedTime'] as int)
        : Duration(seconds: entry.value['elapsedTime'] as int),
    isRunning: recordFt != null
        ? recordFt['isRunning'] as bool
        : entry.value['isRunning'] as bool,
    startTime: recordFt != null && recordFt['startTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(recordFt['startTime'] as int)
        : (entry.value['startTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  entry.value['startTime'] as int,
                )
              : null),
  );

  @override
  Map<String, dynamic> serialize() => {
    ...super.serialize(),
    'elapsedTime': elapsedTime.inSeconds,
    'isRunning': isRunning,
    'startTime': startTime?.millisecondsSinceEpoch,
  };

  @override
  makeRec() => {
    ...super.makeRec(),
    'elapsedTime': elapsedTime.inSeconds,
    'isRunning': isRunning,
    'startTime': startTime?.millisecondsSinceEpoch,
  };
}
