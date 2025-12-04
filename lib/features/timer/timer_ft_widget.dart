import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/features/timer/timer_ft_class.dart';
import 'package:logbloc/utils/fmt_duration.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/txt_field.dart';

class TimerFtWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    bool pickerIsToggled = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

        if (!lock.record || !lock.model)
          StatefulBuilder(
            builder: (context, setState) => pickerIsToggled
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 100,
                        child: CupertinoTimerPicker(
                          initialTimerDuration: ft.duration,
                          onTimerDurationChanged: (d) => ft.duration = d,
                        ),
                      ),
                      Button(
                        'ok',
                        lead: Icons.check,
                        onPressed: () =>
                            setState(() => pickerIsToggled = false),
                      ),
                    ],
                  )
                : Button(
                    fmtDuration(ft.duration),
                    onPressed: () {
                      setState(() => pickerIsToggled = true);
                      dirt!();
                    },
                  ),
          ),
      ],
    );
  }
}
