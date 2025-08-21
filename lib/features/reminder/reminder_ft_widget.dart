import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logize/config/notifications.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/features/reminder/reminder_ft_class.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:logize/widgets/design/txt_field.dart';

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
                  onChanged: (str) {
                    ft.setTitle(str);
                    dirt!();
                  },
                ),
              ),
              Button(
                'set time',
                lead: MdiIcons.clock,
                onPressed: () async {
		  await notif.requestNotifPermission();

                  final time = await showTimePicker(
		    // ignore: use_build_context_synchronously
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    dirt!();
                    ft.time = time;
                  }
                },
              ),
            ],
          ),
        Row(
          children: lock.model
              ? [Txt('${ft.time.hour}:${ft.time.minute}')]
              : [
                  Expanded(
                    child: TxtField(
                      label: 'content',
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
