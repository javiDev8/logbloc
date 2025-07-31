import 'package:logize/features/feature_widget.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/models_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/models/model_records_screen.dart';
import 'package:logize/screens/models/model_stats_screen.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/section_divider.dart';
import 'package:flutter/material.dart';

class FullModelScreen extends StatelessWidget {
  final Model model;
  const FullModelScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7),
      child: Swimmer<Models?>(
        pool: modelsPool,
        builder: (_, models) {
          if (models == null || models[model.id] == null) {
            modelsPool.retrieve();
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('created at'),
                      Text('20/Jul/25 14:52'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        models[model.id]!.recordsQuantity.toString(),
                        style: TextStyle(fontSize: 40),
                      ),
                      Text('records'),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Button(
                    'records',
                    onPressed:
                        () => navPush(
                          context: context,
                          screen: ModelRecordsScreen(model: model),
                          title: Text('records'),
                        ),
                  ),
                  Button(
                    'stats',
                    onPressed:
                        () => navPush(
                          context: context,
                          screen: ModelStatsScreen(model: model),
                          title: Text('analysis'),
                        ),
                  ),
                ],
              ),

              SectionDivider(
                string: 'features (${model.features.length.toString()})',
              ),

              ...models[model.id]!.features.entries.map(
                (ft) => FeatureWidget(
                  detailed: true,
                  lock: FeatureLock(model: true, record: true),
                  feature: ft.value,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
