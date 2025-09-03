import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/utils/feedback.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceNoteFt extends Feature {
  String? path;
  String? tmpPath;
  Duration? duration;

  VoiceNoteFt({
    required super.id,
    required super.type,
    required super.title,
    required super.pinned,
    required super.isRequired,
    required super.position,

    this.path,
    this.tmpPath,
    this.duration,
  });

  factory VoiceNoteFt.fromBareFt(
    Feature ft, {
    required String? path,
    required Duration? duration,
  }) => VoiceNoteFt(
    id: ft.id,
    type: ft.type,
    title: ft.title,
    pinned: ft.pinned,
    isRequired: ft.isRequired,
    position: ft.position,

    path: path,
    duration: duration,
  );

  factory VoiceNoteFt.empty() => VoiceNoteFt.fromBareFt(
    Feature.empty('voice_note'),
    path: null,
    duration: null,
  );

  factory VoiceNoteFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) {
    final ft = Feature.fromEntry(entry);
    final res = VoiceNoteFt.fromBareFt(
      ft,
      path: entry.value['path'] ?? recordFt?['path'] as String?,
      duration:
          entry.value['duration'] != null || recordFt?['duration'] != null
          ? Duration(
              milliseconds:
                  ((entry.value['duration'] ?? recordFt?['duration'])
                      as int?) ??
                  0,
            )
          : null,
    );
    return res;
  }

  @override
  Map<String, dynamic> serialize() => {
    ...super.serialize(),
    'path': path,
    if (duration != null) 'duration': duration?.inMilliseconds,
  };

  @override
  Map<String, dynamic> makeRec() => {
    ...super.makeRec(),
    'path': path,
    if (duration != null) 'duration': duration!.inMilliseconds,
  };

  String genFileName() =>
      'logbloc-audio-${DateTime.now().millisecondsSinceEpoch}';

  Future<bool> requestPermissions() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  @override
  FutureOr<bool> onSave({String? modelId}) async {
    if (tmpPath == null) {
      if (isRequired && path == null) {
        feedback(
          'voice note "$title" is required',
          type: FeedbackType.error,
        );
        return false;
      }
      return true;
    }

    try {
      final player = AudioPlayer();
      duration = await player.setFilePath(tmpPath!);

      final file = File(tmpPath!);
      final dir = await getApplicationDocumentsDirectory();
      path = '${dir.path}/${genFileName()}';
      await file.copy(path!);
      return true;
    } catch (e) {
      throw Exception('audio saving failed error: $e');
    }
  }
}
