import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/models_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/models/model_screen/model_features_view.dart';
import 'package:logize/screens/models/model_screen/model_over_view.dart';
import 'package:logize/screens/models/model_screen/model_schedules_view.dart';
import 'package:logize/widgets/design/txt.dart';

class ModelScreen extends StatefulWidget {
  final Model model;
  const ModelScreen({super.key, required this.model});

  @override
  State<ModelScreen> createState() => ModelScreenState();
}

class ModelScreenState extends State<ModelScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Swimmer(
        pool: modelsPool,
        builder: (context, models) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: tabController,
                      dividerColor: Colors.transparent,
                      tabs: [
                        'overview',
                        'features',
                        'schedules',
                      ].map((t) => Txt(t)).toList(),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    ModelOverView(model: widget.model),
                    ModelFeaturesView(model: widget.model),
                    ModelSchedulesView(model: widget.model),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
