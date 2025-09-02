import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/features/voice_note/voice_note_ft_class.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceNoteFtWidget extends StatelessWidget {
  final VoiceNoteFt ft;
  final FeatureLock lock;
  final bool detailed;
  final void Function()? dirt;

  const VoiceNoteFtWidget({
    super.key,
    required this.ft,
    required this.lock,
    required this.detailed,
    this.dirt,
  });

  @override
  Widget build(BuildContext context) {
    final recorder = AudioRecorder();
    final player = AudioPlayer();
    Duration? duration;

    Duration counter = Duration();

    bool isRecording = false;
    bool isPlaying = false;

    return StatefulBuilder(
      builder: (context, setState) {
        Future startRecording() async {
          if (!(await ft.requestPermissions())) return;

          final tmpDir = await getTemporaryDirectory();
          final tmpPath = '${tmpDir.path}/${ft.genFileName()}';
          await recorder.start(RecordConfig(), path: tmpPath);
          setState(() => isRecording = true);
        }

        Future stopRecording() async {
          final path = await recorder.stop();
          if (path != null) {
            setState(() {
              ft.tmpPath = path;
              isRecording = false;
              dirt?.call();
            });
          }
        }

        Future<void> playRecording() async {
          duration = await player.setFilePath(ft.tmpPath ?? ft.path!);
          setState(() => isPlaying = true);
          await player.play();
          counter = Duration();
          setState(() => isPlaying = false);
        }

        return Column(
          children: [
            if (!lock.model)
              TxtField(
                label: 'title',
                round: true,
                onChanged: (str) => ft.setTitle(str),
                validator: (str) =>
                    str?.isNotEmpty != true ? 'write a title' : null,
                initialValue: ft.title,
              ),

            if (!lock.record)
              Row(
                children: [
                  if (isRecording)
                    IconButton(
                      onPressed: stopRecording,
                      icon: Icon(Icons.square),
                    )
                  else
                    IconButton(
                      onPressed: startRecording,
                      icon: Icon(Icons.circle, color: Colors.red),
                    ),

                  if (!isRecording &&
                      (ft.tmpPath != null || ft.path != null))
                    IconButton(
                      onPressed: playRecording,
                      icon: Icon(Icons.play_arrow),
                    ),

                  if (isPlaying)
                    StatefulBuilder(
                      builder: (context, ss) {
                        Future.delayed(
                          Duration(milliseconds: 1),
                          () => ss(() {
                            counter = Duration(
                              milliseconds: counter.inMilliseconds + 1,
                            );
                          }),
                        );
                        return Txt(
                          '${counter.inMinutes}:${counter.inSeconds}:${counter.inMilliseconds}/'
                          '${duration!.inMinutes}:${duration!.inSeconds}:${duration!.inMilliseconds}',
                        );
                      },
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}
