import 'package:flutter/material.dart';
import 'package:logbloc/features/chronometer/chronometer_ft_class.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/utils/fmt_duration.dart';
import 'package:logbloc/utils/warn_dialogs.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';

class ChronometerFtWidget extends StatelessWidget {
  final ChronometerFt ft;
  final FeatureLock lock;
  final bool detailed;
  final void Function()? dirt;

  const ChronometerFtWidget({
    super.key,
    required this.lock,
    required this.ft,
    required this.detailed,
    this.dirt,
  });

  @override
  Widget build(BuildContext context) {
    bool isRunning = false;

    DateTime? pauseStart;
    Duration pausedTime = Duration();

    Duration getTime() {
      final totalTime = DateTime.now().difference(ft.start!);
      return Duration(
        milliseconds: totalTime.inMilliseconds - pausedTime.inMilliseconds,
      );
    }

    return Column(
      children: [
        if (!lock.model)
          TxtField(
            label: 'title',
            initialValue: ft.title,
            round: true,
            onChanged: (txt) {
              ft.setTitle(txt);
              dirt!();
            },
            validator: (str) => str!.isEmpty ? 'write a title' : null,
          ),

        if (lock.model)
          StatefulBuilder(
            builder: (context, setState) => Row(
              children: [
                if (isRunning) ...[
                  IconButton(
                    onPressed: () => setState(() {
                      isRunning = false;
                      ft.duration = getTime();
                      pauseStart = DateTime.now();
                    }),
                    icon: Icon(Icons.pause),
                  ),

                  IconButton(
                    onPressed: () {
                      dirt!();
                      ft.duration = getTime();
                      setState(() {
                        isRunning = false;
                        pauseStart = null;
                        pausedTime = Duration();
                      });
                    },
                    icon: Icon(Icons.square),
                  ),
                ] else if (!lock.record)
                  IconButton(
                    onPressed: () async {
                      play() => setState(() {
                        if (pauseStart == null) {
                          ft.start = DateTime.now();
                        } else {
                          pausedTime = Duration(
                            milliseconds:
                                pausedTime.inMilliseconds +
                                (DateTime.now().difference(
                                  pauseStart!,
                                )).inMilliseconds,
                          );
                        }
                        isRunning = true;
                      });

                      if (ft.duration == null) {
                        play();
                      } else {
                        await warnOverwrite(
                          context,
                          overwrite: () => play(),
                          msg:
                              'This action will overwrite the current value of the chronometer',
                        );
                      }
                    },
                    icon: Icon(Icons.play_arrow),
                  ),

                if ((!detailed && isRunning) || pauseStart != null)
                  StatefulBuilder(
                    builder: (context, ss) {
                      if (isRunning) {
                        Future.delayed(
                          Duration(milliseconds: 10),
                          () => ss(() {}),
                        );
                      }

                      return Txt(fmtDuration(getTime()));
                    },
                  )
                else if (ft.duration != null)
                  Txt(fmtDuration(ft.duration!)),
              ],
            ),
          ),
      ],
    );
  }
}
