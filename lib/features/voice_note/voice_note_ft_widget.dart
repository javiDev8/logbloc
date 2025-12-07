import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/features/voice_note/voice_note_ft_class.dart';
import 'package:logbloc/utils/fmt_duration.dart';
import 'package:logbloc/utils/warn_dialogs.dart';
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
    Duration currentPosition = Duration.zero;
    Duration totalDuration = Duration.zero;

    return StatefulBuilder(
      builder: (context, setState) {
        // Listen to player position updates
        player.positionStream.listen((position) {
          setState(() {
            currentPosition = position;
          });
        });

        // Listen to player duration updates
        player.durationStream.listen((duration) {
          if (duration != null) {
            setState(() {
              totalDuration = duration;
            });
          }
        });

        player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            //if (!isRecording) counter = Duration();
            if (!isRecording) start = null;
            setState(() {
              isPlaying = false;
              currentPosition = Duration.zero;
            });
          }
        });

        Future startRecording() async {
          if (!(await ft.requestPermissions(context))) return;

          rec() async {
            final tmpDir = await getTemporaryDirectory();
            final tmpPath = '${tmpDir.path}/${ft.genFileName()}';
            await recorder.start(RecordConfig(), path: tmpPath);
            setState(() {
              start = DateTime.now();
              isRecording = true;
            });
          }

          if (ft.duration == null) {
            await rec();
          } else {
            warnOverwrite(
              // ignore: use_build_context_synchronously
              context,
              overwrite: () => rec(),
              msg: 'This action will overwirte an already recorded audio',
            );
          }
        }

        Future<void> playRecording() async {
          await player.setFilePath(ft.tmpPath ?? ft.path!);
          //counter = Duration();
          start = DateTime.now();
          setState(() => isPlaying = true);
          await player.play();
        }

        Future<void> seekToPosition(double value) async {
          final position = Duration(
            milliseconds: (value * totalDuration.inMilliseconds).round(),
          );
          await player.seek(position);
        }

        Future pause() async {
          await player.pause();
          setState(() => isPlaying = false);
        }

        Future<void> stopRecording() async {
          final path = await recorder.stop();
          if (path != null) {
            final tmpFile = File(path);
            final dir = await getApplicationDocumentsDirectory();
            final permanentPath = '${dir.path}/${ft.genFileName()}';
            await tmpFile.copy(permanentPath);

            final player = AudioPlayer();
            final duration = await player.setFilePath(permanentPath);

            ft.tmpPath = permanentPath;
            ft.duration = duration;

            setState(() {
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
              Column(
                children: [
                  // Playback controls row
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
                          IconButton(onPressed: pause, icon: Icon(Icons.pause)),

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

                  // Audio slider and time display
                  if (!isRecording && (ft.tmpPath != null || ft.path != null))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          // Time display
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Txt(
                                  fmtDuration(
                                    isPlaying ? currentPosition : Duration.zero,
                                    exact: false,
                                  ),
                                ),
                                Txt(
                                  fmtDuration(
                                    totalDuration.inMilliseconds > 0
                                        ? totalDuration
                                        : (ft.duration ?? Duration.zero),
                                    exact: false,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 6.0,
                              ),
                              trackHeight: 4.0,
                            ),
                            child: Slider(
                              min: 0.0,
                              max: totalDuration.inMilliseconds > 0
                                  ? totalDuration.inMilliseconds.toDouble()
                                  : (ft.duration?.inMilliseconds.toDouble() ??
                                        1000.0),
                              value: currentPosition.inMilliseconds.toDouble(),
                              onChanged: (ft.tmpPath != null || ft.path != null)
                                  ? (value) {
                                      seekToPosition(
                                        value / totalDuration.inMilliseconds,
                                      );
                                    }
                                  : null,
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              inactiveColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}
