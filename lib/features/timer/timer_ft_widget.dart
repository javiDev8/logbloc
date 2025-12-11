import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/features/timer/timer_ft_class.dart';
import 'package:logbloc/utils/feedback.dart';
import 'package:logbloc/utils/fmt_duration.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/exp.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';
import 'package:logbloc/apis/notifications.dart';
import 'dart:async';

class TimerFtWidget extends StatefulWidget {
  final TimerFt ft;
  final FeatureLock lock;
  final bool detailed;
  final void Function()? dirt;

  const TimerFtWidget({
    super.key,
    required this.lock,
    required this.ft,
    required this.detailed,
    this.dirt,
  });

  @override
  State<TimerFtWidget> createState() => _TimerFtWidgetState();
}

class _TimerFtWidgetState extends State<TimerFtWidget> {
  bool isRunning = false;
  Timer? timer;
  DateTime? startTime;
  Duration remainingTime = Duration.zero;

  bool pickerIsToggled = false;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.ft.duration - widget.ft.passedTime;
    if (remainingTime.isNegative) remainingTime = Duration.zero;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
      startTime = DateTime.now();
    });

    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      final elapsed = DateTime.now().difference(startTime!);
      final totalElapsed = widget.ft.passedTime + elapsed;
      final newRemaining = widget.ft.duration - totalElapsed;

      setState(() {
        remainingTime = newRemaining.isNegative
            ? Duration.zero
            : newRemaining;
      });

      if (newRemaining.isNegative) {
        pauseTimer();
        setState(() {
          remainingTime = Duration.zero;
        });
        widget.ft.passedTime = widget.ft.duration;
        widget.dirt?.call();

        // Show notification when timer finishes
        notif.trigger(
          title: 'Timer Completed!',
          body: '"${widget.ft.title}" has finished',
          id: widget.ft.id.hashCode,
          soundName: 'timer_notification',
        );
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    final elapsed = startTime != null
        ? DateTime.now().difference(startTime!)
        : Duration.zero;
    final totalElapsed = widget.ft.passedTime + elapsed;

    setState(() {
      isRunning = false;
      widget.ft.passedTime = totalElapsed > widget.ft.duration
          ? widget.ft.duration
          : totalElapsed;
      remainingTime = widget.ft.duration - widget.ft.passedTime;
      if (remainingTime.isNegative) remainingTime = Duration.zero;
    });

    widget.dirt?.call();
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      remainingTime = widget.ft.duration;
      widget.ft.passedTime = Duration.zero;
    });
    widget.dirt?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.lock.model && widget.lock.record)
          Row(
            children: [
              Txt(
                '${fmtDuration(widget.ft.passedTime)} / ${fmtDuration(widget.ft.duration)}',
                w: 7,
              ),
              Exp(),
              Txt('${(widget.ft.completeness * 100).toInt()}%'),
            ],
          ),

        if (!widget.lock.model)
          Row(
            children: [
              Expanded(
                child: TxtField(
                  label: 'title',
                  initialValue: widget.ft.title,
                  round: true,
                  onChanged: (txt) {
                    widget.ft.setTitle(txt);
                    widget.dirt!();
                  },
                  validator: (str) =>
                      str!.isEmpty ? 'write a title' : null,
                ),
              ),
              if (!pickerIsToggled)
                Button(
                  fmtDuration(widget.ft.duration, exact: false),
                  lead: Icons.timer,
                  filled: false,
                  onPressed: () async {
                    if ((await notif.requestNotifPermission()) != true) {
                      feedback(
                        'this feature needs permission to send notifications,'
                        ' give it from your device settings',
                        type: FeedbackType.error,
                      );
                      return;
                    }
                    setState(() => pickerIsToggled = true);
                  },
                ),
            ],
          ),

        if (pickerIsToggled) ...[
          SizedBox(
            height: 100,
            child: CupertinoTimerPicker(
              initialTimerDuration: widget.ft.duration,
              onTimerDurationChanged: (d) {
                widget.ft.duration = d;
                if (!isRunning) {
                  setState(() {
                    remainingTime = d;
                  });
                }
                widget.dirt!();
              },
            ),
          ),
          Button(
            'ok',
            lead: Icons.check,
            onPressed: () => setState(() => pickerIsToggled = false),
          ),
        ],

        if (widget.lock.model && !widget.lock.record)
          StatefulBuilder(
            builder: (context, ss) {
              if (isRunning) {
                Future.delayed(
                  Duration(milliseconds: 100),
                  () => ss(() {}),
                );
              }

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isRunning)
                        IconButton(
                          onPressed: () => pauseTimer(),
                          icon: Icon(Icons.pause),
                        )
                      else if (widget.ft.passedTime != widget.ft.duration)
                        IconButton(
                          onPressed: () async {
                            startTimer();
                          },
                          icon: Icon(Icons.play_arrow),
                        ),

                      Txt(
                        fmtDuration(remainingTime, exact: false),
                        s: 20,
                        w: 6,
                      ),

                      Expanded(
                        child: LinearProgressIndicator(
                          value:
                              1 -
                              (remainingTime.inSeconds /
                                  (widget.ft.duration.inSeconds == 0
                                      ? 1
                                      : widget.ft.duration.inSeconds)),
                        ),
                      ),
                      if (widget.ft.passedTime == Duration.zero &&
                          !isRunning)
                        IconButton(
                          onPressed: () =>
                              setState(() => pickerIsToggled = true),
                          icon: Icon(Icons.timer),
                        ),

                      IconButton(
                        onPressed: () => resetTimer(),
                        icon: Icon(MdiIcons.backupRestore),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
