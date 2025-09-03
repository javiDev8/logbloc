import 'package:flutter/material.dart';
import 'package:logbloc/features/chronometer/chronometer_ft_class.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/utils/fmt_duration.dart';
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
    Duration counter = Duration();
    bool isRunning = false;
    bool isPaused = false;

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
                      isPaused = true;
                    }),
                    icon: Icon(Icons.pause),
                  ),

                  IconButton(
                    onPressed: () {
                      dirt!();
                      setState(() {
                        isRunning = false;
                        isPaused = false;
                        ft.duration = counter;
                        counter = Duration();
                      });
                    },
                    icon: Icon(Icons.square),
                  ),
                ] else
                  IconButton(
                    onPressed: () => setState(() {
                      isRunning = true;
                    }),
                    icon: Icon(Icons.play_arrow),
                  ),

                if ((!detailed && isRunning) || isPaused)
                  StatefulBuilder(
                    builder: (context, ss) {
                      if (isRunning) {
                        Future.delayed(
                          Duration(milliseconds: 10),
                          () => ss(() {
                            counter = Duration(
                              milliseconds: counter.inMilliseconds + 10,
                            );
                          }),
                        );
                      }

                      return Txt(fmtDuration(counter));
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
