import 'package:logbloc/features/feature_class.dart';

class TimerFt extends Feature {
  Duration passedTime;
  Duration duration;

  TimerFt({
    required super.id,
    required super.type,
    required super.title,
    required super.pinned,
    required super.isRequired,
    required super.position,

    required this.passedTime,
    required this.duration,
  });

  @override
  double get completeness =>
      (passedTime.inSeconds >= duration.inSeconds &&
          duration.inSeconds > 0)
      ? 1
      : passedTime.inSeconds / duration.inSeconds;

  factory TimerFt.fromBareFt(
    Feature ft, {
    required Duration passedTime,
    required Duration duration,
  }) {
    return TimerFt(
      id: ft.id,
      type: ft.type,
      title: ft.title,
      pinned: ft.pinned,
      isRequired: ft.isRequired,
      position: ft.position,

      passedTime: passedTime,
      duration: duration,
    );
  }

  factory TimerFt.empty() => TimerFt.fromBareFt(
    Feature.empty('timer'),
    passedTime: Duration.zero,
    duration: Duration(minutes: 5),
  );

  factory TimerFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) => TimerFt.fromBareFt(
    Feature.fromEntry(entry),
    passedTime: recordFt != null
        ? Duration(seconds: recordFt['passedTime'] as int)
        : Duration(seconds: entry.value['passedTime'] as int),
    duration: recordFt != null
        ? Duration(seconds: recordFt['duration'] as int)
        : Duration(seconds: entry.value['duration'] as int),
  );

  @override
  Map<String, dynamic> serialize() => {
    ...super.serialize(),
    'passedTime': passedTime.inSeconds,
    'duration': duration.inSeconds,
  };

  @override
  makeRec() => {
    ...super.makeRec(),
    'passedTime': passedTime.inSeconds,
    'duration': duration.inSeconds,
  };
}
