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
}
