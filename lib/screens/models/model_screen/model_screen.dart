import 'package:flutter/material.dart';
import 'package:logbloc/apis/membership.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/screens/models/model_screen/model_features_view.dart';
import 'package:logbloc/screens/models/model_screen/model_over_view.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/model_schedules_view.dart';
import 'package:logbloc/utils/feedback.dart';
import 'package:logbloc/utils/nav.dart';
import 'package:logbloc/utils/warn_dialogs.dart';
import 'package:logbloc/widgets/design/topbar_wrap.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/model_title.dart';

final editModelFormKey = GlobalKey<FormState>();

final modelScreenKey = GlobalKey();

class ModelScreen extends StatefulWidget {
  final Model? model;
  const ModelScreen({super.key, this.model});

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
    final isNew = widget.model == null;

    if (membershipApi.currentPlan == 'free' &&
        isNew &&
        modelsPool.data!.length == 3) {
      feedback(
        'you have already 3 logbooks! buy the app to get unlimited logbooks',
      );
      navPop();
    }

    modelEditPool.data = widget.model ?? Model.empty();
    //modelEditPool.dirty = isNew;
    return Scaffold(
      key: modelScreenKey,
      appBar: PreferredSize(
        preferredSize: Size(290, 80),
        child: LazySwimmer<Model>(
          listenedEvents: ['name'],
          pool: modelEditPool,
          builder: (context, model) => wrapBar(
            backable: true,
            onBack: () async {
              modelEditPool.editingSchs = [];
              modelEditPool.editingFts = [];
              if (!modelEditPool.dirty) return true;
              return (await warnUnsavedChanges(
                    context,
                    save: modelEditPool.save,
                  )) ??
                  false;
            },
            children: makeModelTitle(isNew: isNew),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Swimmer<Map<String, Model>?>(
          pool: modelsPool,
          builder: (context, models) {
            if (modelsPool.data?.containsKey(modelEditPool.data.id) ==
                true) {
              modelEditPool.data = Model.fromMap(
                map: modelsPool.data![modelEditPool.data.id]!.serialize(),
              );
            }
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
                  child: Form(
                    key: editModelFormKey,
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        ModelOverView(isNew: isNew),
                        ModelFeaturesView(),
                        ModelSchedulesView(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
