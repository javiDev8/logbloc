import 'package:flutter/material.dart';
import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/features/feature_switch.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/utils/color_convert.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:logbloc/widgets/design/txt.dart';

List<Widget> dumpFtRecords({
  required Feature ft,
  required List<Map<String, dynamic>> recordFts,
}) {
  return recordFts
      .where(
        (rft) =>
            (featureSwitch(
                      parseType: 'class',
                      entry: MapEntry(ft.key, ft.serialize()),
                      recordFt: rft,
                    )
                    as Feature)
                .completeness >
            0,
      )
      .map((rft) {
        final date = rft['date'];
        return Card(
          color: themeModePool.data == ThemeMode.dark
              ? endarkColor(Colors.grey)
              : enbrightColor(Colors.grey),
          child: Padding(
            padding: EdgeInsetsGeometry.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt('${weekdays[date.weekday]} ${date.day}', w: 8),
                featureSwitch(
                  parseType: 'widget',
                  ft: featureSwitch(
                    parseType: 'class',
                    recordFt: rft,
                    entry: MapEntry(ft.key, ft.serialize()),
                  ),
                  lock: FeatureLock(model: true, record: true),
                ),
              ],
            ),
          ),
        );
      })
      .toList();
}
