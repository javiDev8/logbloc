String fmtDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  final millisecs = twoDigits(duration.inMilliseconds.remainder(1000));

  final ms = millisecs.split('');

  return '${hours == '00' ? '' : '$hours:'}${minutes == '00' ? '' : '$minutes:'}$seconds:${ms[0]}${ms[1]}';
}
