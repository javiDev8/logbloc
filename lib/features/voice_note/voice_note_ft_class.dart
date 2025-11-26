import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/utils/feedback.dart';
import 'package:logbloc/widgets/design/button.dart';
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

  @override
  get isEmpty => path == null;

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
      'logbloc-audio-${DateTime.now().millisecondsSinceEpoch}.m4a';

  Future<bool> requestPermissions(BuildContext context) async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Microphone Access Required'),
          content: const Text(
            'To record voice notes in your logbook, this app needs access to your microphone. '
            'You can enable this by going to Settings > Privacy > Microphone, and toggling on the setting for Logbloc.',
          ),
	  actionsAlignment: MainAxisAlignment.spaceAround,
          actions: <Widget>[
            Button(
	      'cancel',
	      filled: false,
              onPressed: () => Navigator.of(context).pop(),
            ),
            Button(
	      'open settings',
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        ),
      );
      return false;
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

    path = tmpPath;
    return true;
  }
}
