String fmtDuration(Duration duration, {bool exact = false}) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  final millisecs = twoDigits(duration.inMilliseconds.remainder(1000));

  return '${hours == '00' ? '' : '$hours:'}'
      '$minutes:'
      '$seconds'
      '${exact ? ':$millisecs' : ''}';
}
