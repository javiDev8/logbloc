import 'package:flutter/material.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/records/records_pool.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:logbloc/widgets/design/none.dart';
import 'package:logbloc/widgets/time_stats.dart';

class MiniOverviewGrid extends StatelessWidget {
  final String modelId;
  const MiniOverviewGrid({super.key, required this.modelId});

  @override
  Widget build(BuildContext context) {
    return Swimmer(
      pool: recordsPool,
      builder: (context, _) {
        final model = modelsPool.data?[modelId];

        if (model == null || recordsPool.data == null) {
          return None();
        }

        final records = recordsPool.data!.values
            .where((rc) => rc.modelId == modelId)
            .toList();

        if (records.isEmpty) return None();

        final recordFts = records
            .map(
              (r) => {
                'date': DateTime.parse(r.schedule.day),
                'value': r.completeness,
              },
            )
            .toList();

        final defaultColor = Theme.of(
          context,
        ).colorScheme.tertiaryContainer;

        final now = DateTime.now();
        final currentMonday = now.subtract(
          Duration(days: now.weekday - 1),
        );

        double maxVal = 0;

        // First pass to find maxVal
        for (int week = 0; week < 13; week++) {
          final monday = currentMonday.subtract(
            Duration(days: (12 - week) * 7),
          );
          for (int day = 0; day < 7; day++) {
            final date = monday.add(Duration(days: day));
            final matches = recordFts.where(
              (rf) => strDate(rf['date'] as DateTime) == strDate(date),
            );
            if (matches.isNotEmpty) {
              final value = operate(
                matches,
                ChartOperation.average,
                (rf) => rf['value'] as double,
              );
              if (value > maxVal) maxVal = value;
            }
          }
        }

        final List<Widget> squares = [];

        for (int day = 0; day < 7; day++) {
          for (int week = 0; week < 13; week++) {
            final monday = currentMonday.subtract(
              Duration(days: (12 - week) * 7),
            );
            final date = monday.add(Duration(days: day));
            final matches = recordFts.where(
              (rf) => strDate(rf['date'] as DateTime) == strDate(date),
            );

            double dayValue = 0;
            if (matches.isNotEmpty) {
              dayValue = operate(
                matches,
                ChartOperation.average,
                (rf) => rf['value'] as double,
              );
            }

            squares.add(
              Container(
                decoration: BoxDecoration(
                  color: (model.color ?? defaultColor).withAlpha(
                    maxVal == 0
                        ? 0
                        : dayValue == 0
                        ? 0
                        : (((dayValue / maxVal) * 155).toInt()) + 100,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            );
          }
        }

        return SizedBox(
          height: 150,
	  width: 300,
          child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 10, left: 120),
            child: GridView.count(
              crossAxisCount: 13,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: squares,
            ),
          ),
        );
      },
    );
  }
}
