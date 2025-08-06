import 'package:flutter/material.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/models_pool.dart';

class ModelFeaturesView extends StatelessWidget {
  final Model model;
  const ModelFeaturesView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(7),
      child: ListView(
        children: [
          ...modelsPool.data![model.id]!.getSortedFeatureList().map(
            (ft) => FeatureWidget(
              detailed: true,
              lock: FeatureLock(model: true, record: true),
              feature: ft,
            ),
          ),
        ],
      ),
    );
  }
}
