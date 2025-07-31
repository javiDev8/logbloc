import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

class DateChart extends StatelessWidget {
  final double Function(Map<String, dynamic>) getRecordValue;
  final List<Map<String, dynamic>> recordFts;
  const DateChart({
    super.key,
    required this.recordFts,
    required this.getRecordValue,
  });

  @override
  Widget build(BuildContext context) {
    if (recordFts.isEmpty) return Text('no records');

    final referenceDate = recordFts.first['date'];

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = referenceDate.add(
                    Duration(days: value.toInt()),
                  );
                  return Text('${date.day}/${date.month}');
                },
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  if (val == val.toInt()) {
                    return Text('${val.toInt()}');
                  } else {
                    return Text(val.toStringAsFixed(1));
                  }
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots:
                  recordFts.asMap().entries.toList().map<FlSpot>((
                    rftEntry,
                  ) {
                    final rft = rftEntry.value;
                    final DateTime date = rft['date'];

                    return FlSpot(
                      date.difference(referenceDate).inDays.toDouble(),
                      getRecordValue(rft),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
