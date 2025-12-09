import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/features/mood/mood_ft_class.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class MoodFtWidget extends StatelessWidget {
  final MoodFt ft;
  final FeatureLock lock;
  final bool detailed;
  final void Function()? dirt;

  const MoodFtWidget({
    super.key,
    required this.lock,
    required this.ft,
    required this.detailed,
    this.dirt,
  });

  @override
  Widget build(BuildContext context) {
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

        if (lock.model)
          StatefulBuilder(
            builder: (context, setState) {
              if (ft.moodId == null) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: moods.entries
                      .map(
                        (me) => IconButton(
                          onPressed: () => setState(() {
                            ft.moodId = me.key;
                            dirt!();
                          }),
                          icon: Icon(
                            size: 33,
                            me.value['icon'] as IconData,
                            color: (me.value['color'] as Color).withAlpha(
                              (255 * 0.75).toInt(),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              } else {
                return Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        moods[ft.moodId]!['icon'] as IconData,
                        size: 45,
                        color: (moods[ft.moodId]!['color'] as Color)
                            .withAlpha((ft.opacity).toInt()),
                      ),
                      Txt(ft.intensity.toString(), w: 7),

                      if (!lock.record) ...[
                        Expanded(
                          child: SfSlider(
                            min: 1.0,
                            max: 10.0,
                            value: ft.intensity!.toDouble(),
                            onChanged: (val) {
                              setState(() => ft.intensity = val.toInt());
                              dirt!();
                            },
                          ),
                        ),

                        if (ft.completeness > 0)
                          IconButton(
                            onPressed: () =>
                                setState(() => ft.moodId = null),
                            icon: Icon(MdiIcons.backupRestore),
                          ),
                      ],
                    ],
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}
