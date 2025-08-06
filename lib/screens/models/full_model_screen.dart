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
          final modelName = models[model.id]!.name;
          return ListView(
            children: [
              Row(
                children: [
                  Button(
                    'records (${models[model.id]!.recordCount.toString()})',
                    onPressed: () => navPush(
                      context: context,
                      screen: ModelRecordsScreen(model: model),
                      title: Text('$modelName records'),
                    ),
                  ),
                  Button(
                    'stats',
                    onPressed: () => navPush(
                      context: context,
                      screen: ModelStatsScreen(model: model),
                      title: Text('$modelName stats'),
                    ),
                  ),
                ],
              ),

              SectionDivider(
                string: 'features (${model.features.length.toString()})',
              ),

              ...models[model.id]!.getSortedFeatureList().map(
                (ft) => FeatureWidget(
                  detailed: true,
                  lock: FeatureLock(model: true, record: true),
                  feature: ft,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
