import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logbloc/apis/notifications.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/features/reminder/reminder_ft_class.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/exp.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';

class ReminderFtWidget extends StatelessWidget {
  final ReminderFt ft;
  final FeatureLock lock;
  final bool detailed;
  final void Function()? dirt;

  const ReminderFtWidget({
    super.key,
    required this.lock,
    required this.ft,
    required this.detailed,
    this.dirt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!lock.model)
          Row(
            children: [
              Expanded(
                child: TxtField(
                  round: true,
                  label: 'title',
                  initialValue: ft.title,
                  onChanged: (str) {
                    ft.setTitle(str);
                    dirt!();
                  },
                ),
              ),
              StatefulBuilder(
                builder: (context, setState) => Button(
                  '${ft.time.hour}:${ft.time.minute}',
                  lead: MdiIcons.clockOutline,
                  onPressed: () async {
                    await notif.requestNotifPermission();

                    final time = await showTimePicker(
                      // ignore: use_build_context_synchronously
                      context: context,
                      initialTime: ft.time,
                    );
                    if (time != null) {
                      dirt!();
                      ft.time = time;
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
        lock.model
            ? Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(MdiIcons.clockOutline, size: 20),
                    Txt('${ft.time.hour}:${ft.time.minute}', w: 8),
                    Exp(),
                    Txt(ft.content),
                  ],
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: TxtField(
                      round: true,
                      label: 'content',
                      initialValue: ft.content,
                      onChanged: (str) {
                        ft.content = str;
                        dirt!();
                      },
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
