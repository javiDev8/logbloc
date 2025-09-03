import 'package:logbloc/features/feature_class.dart';

class ChronometerFt extends Feature {
  Duration? duration;

  ChronometerFt({
    required super.id,
    required super.type,
    required super.title,
    required super.pinned,
    required super.isRequired,
    required super.position,

    this.duration,
  });

  factory ChronometerFt.fromBareFt(
    Feature ft, {
    required Duration? duration,
  }) => ChronometerFt(
    id: ft.id,
    type: ft.type,
    title: ft.title,
    pinned: ft.pinned,
    isRequired: ft.isRequired,
    position: ft.position,

    duration: duration,
  );

  factory ChronometerFt.empty() => ChronometerFt.fromBareFt(
    Feature.empty('chronometer'),
    duration: null,
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
    );
    return res;
  }

  @override
  Map<String, dynamic> serialize() => {
    ...super.serialize(),
    'duration': duration?.inMilliseconds,
  };

  @override
  makeRec() => {...super.makeRec(), 'duration': duration?.inMilliseconds};

  setDuration(Duration newDuration) => duration = newDuration;
}
