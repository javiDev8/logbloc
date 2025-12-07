import 'package:flutter/material.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/features/chronometer/chronometer_ft_class.dart';
import 'package:logbloc/utils/fmt_duration.dart';
import 'package:logbloc/widgets/design/exp.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';
import 'dart:async';

class ChronometerFtWidget extends StatefulWidget {
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
  State<ChronometerFtWidget> createState() => _ChronometerFtWidgetState();
}

class _ChronometerFtWidgetState extends State<ChronometerFtWidget> {
  Timer? timer;
  Duration currentElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    currentElapsed = widget.ft.elapsedTime;
    if (widget.ft.isRunning && widget.ft.startTime != null) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (widget.ft.isRunning && widget.ft.startTime != null) {
      timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        final now = DateTime.now();
        final totalElapsed =
            widget.ft.elapsedTime + now.difference(widget.ft.startTime!);

        setState(() {
          currentElapsed = totalElapsed;
        });
      });
    }
  }

  void startChronometer() {
    setState(() {
      widget.ft.isRunning = true;
      widget.ft.startTime = DateTime.now();
    });
    _startTimer();
    widget.dirt?.call();
  }

  void pauseChronometer() {
    timer?.cancel();
    if (widget.ft.startTime != null) {
      final elapsed = DateTime.now().difference(widget.ft.startTime!);
      setState(() {
        widget.ft.elapsedTime = widget.ft.elapsedTime + elapsed;
        currentElapsed = widget.ft.elapsedTime;
        widget.ft.isRunning = false;
        widget.ft.startTime = null;
      });
    }
    widget.dirt?.call();
  }

  void resetChronometer() {
    timer?.cancel();
    setState(() {
      widget.ft.elapsedTime = Duration.zero;
      currentElapsed = Duration.zero;
      widget.ft.isRunning = false;
      widget.ft.startTime = null;
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
              Txt(fmtDuration(currentElapsed), w: 7),
              Exp(),
              Txt(widget.ft.isRunning ? 'Running' : 'Stopped'),
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
            ],
          ),

        if (widget.lock.model && !widget.lock.record)
          StatefulBuilder(
            builder: (context, ss) {
              if (widget.ft.isRunning) {
                Future.delayed(
                  Duration(milliseconds: 100),
                  () => ss(() {}),
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.ft.isRunning)
                    IconButton(
                      onPressed: () => pauseChronometer(),
                      icon: Icon(Icons.pause),
                    )
                  else
                    IconButton(
                      onPressed: () => startChronometer(),
                      icon: Icon(Icons.play_arrow),
                    ),
                  Txt(
                    fmtDuration(currentElapsed, exact: false),
                    s: 20,
                    w: 6,
                  ),

                  IconButton(
                    onPressed: () => resetChronometer(),
                    icon: Icon(Icons.refresh),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
