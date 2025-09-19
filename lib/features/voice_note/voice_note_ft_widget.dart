import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/features/voice_note/voice_note_ft_class.dart';
import 'package:logbloc/utils/fmt_duration.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceNoteFtWidget extends StatelessWidget {
  final VoiceNoteFt ft;
  final FeatureLock lock;
  final bool detailed;
  final void Function()? dirt;

  VoiceNoteFtWidget({
    super.key,
    required this.ft,
    required this.lock,
    required this.detailed,
    this.dirt,
  });

  final recorder = AudioRecorder();
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    //Duration counter = Duration();
    DateTime? start;
    bool isRecording = false;
    bool isPlaying = false;

    return StatefulBuilder(
      builder: (context, setState) {
        player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            //if (!isRecording) counter = Duration();
            if (!isRecording) start = null;
            setState(() {
              isPlaying = false;
            });
          }
        });

        Future startRecording() async {
          if (!(await ft.requestPermissions(context))) return;

          final tmpDir = await getTemporaryDirectory();
          final tmpPath = '${tmpDir.path}/${ft.genFileName()}';
          await recorder.start(RecordConfig(), path: tmpPath);
          setState(() {
            start = DateTime.now();
            isRecording = true;
          });
        }

        Future<void> playRecording() async {
          await player.setFilePath(ft.tmpPath ?? ft.path!);
          //counter = Duration();
          start = DateTime.now();
          setState(() => isPlaying = true);
          await player.play();
        }

        Future pause() async {
          await player.pause();
          setState(() => isPlaying = false);
        }

        Future stopRecording() async {
          //counter = Duration();

          final duration = DateTime.now().difference(start!);
          final path = await recorder.stop();
          if (path != null) {
            ft.duration = duration;
            setState(() {
              ft.tmpPath = path;
              isRecording = false;
              dirt?.call();
            });
          }
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

            if (lock.model)
              Row(
                children: [
                  if (!detailed) ...[
                    if (isRecording)
                      IconButton(
                        onPressed: stopRecording,
                        icon: Icon(Icons.square),
                      )
                    else if (!isPlaying && !lock.record)
                      IconButton(
                        onPressed: startRecording,
                        icon: Icon(Icons.circle, color: Colors.red),
                      ),

                    if (isPlaying)
                      IconButton(
                        onPressed: pause,
                        icon: Icon(Icons.pause),
                      ),

                    if ((!isRecording && !isPlaying) &&
                        (ft.tmpPath != null || ft.path != null))
                      IconButton(
                        onPressed: playRecording,
                        icon: Icon(Icons.play_arrow),
                      ),

                    if (isPlaying || isRecording)
                      StatefulBuilder(
                        builder: (context, ss) {
                          Future.delayed(
                            Duration(seconds: 1),
                            () => ss(() {}),
                          );
                          return Txt(
                            fmtDuration(
                              DateTime.now().difference(start!),
                              exact: false,
                            ),
                          );
                        },
                      ),
                  ],

                  if (!isRecording && ft.duration != null)
                    Txt(fmtDuration(ft.duration!, exact: false)),
                ],
              ),
          ],
        );
      },
    );
  }
}
