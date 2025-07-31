import 'package:logize/assets/icons.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/config/locales.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/models/edit/actions/add_ft_button.dart';
import 'package:logize/screens/models/edit/actions/set_color_button.dart';
import 'package:logize/screens/models/edit/schedule_rules_widget.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/section_divider.dart';
import 'package:logize/widgets/design/txt_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ModelEditScreen extends StatelessWidget {
  final Model? existingModel;
  const ModelEditScreen({super.key, this.existingModel});

  @override
  Widget build(BuildContext context) {
    modelEditPool.data = existingModel ?? Model.empty();

    final formKey = GlobalKey<FormState>();

    final tabIndexPool = Pool<int>(0);

    return Padding(
      padding: EdgeInsets.only(right: 5, left: 5),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height,
        ),
        child: LazySwimmer<Model>(
          pool: modelEditPool,
          listenedEvents: ['features'],
          builder:
              (context, model) => Form(
                key: formKey,
                child: ListView(
                  children: [
                    TxtField(
                      onChanged: (str) => modelEditPool.setName(str),
                      validator:
                          (str) =>
                              str!.isEmpty
                                  ? 'give your model a name'
                                  : null,
                      hint: Tr.newModelNameHint.getString(context),
                      initialValue: modelEditPool.data.name,
                      round: true,
                    ),

                    Swimmer<int>(
                      pool: tabIndexPool,
                      builder:
                          (c, index) => Row(
                            children: [
                              Button(
                                null,
                                filled: index == 0,
                                onPressed:
                                    () => tabIndexPool.set((_) => 0),
                                lead: addFtIcon,
                              ),
                              Button(
                                null,
                                variant: 2,
                                filled: index == 1,
                                onPressed:
                                    () => tabIndexPool.set((_) => 1),
                                lead: Icons.calendar_month,
                              ),
                              SetColorButton(),
                            ],
                          ),
                    ),

                    Swimmer<int>(
                      pool: tabIndexPool,
                      builder:
                          (c, index) =>
                              [
                                Column(
                                  children: [
                                    SectionDivider(
                                      string: 'Features',
                                      lead: AddFtButton(),
                                    ),

                                    ...modelEditPool.data.features.entries
                                        .map(
                                          (ftEntry) => FeatureWidget(
                                            key: Key(ftEntry.key),
                                            lock: FeatureLock(
                                              model: false,
                                              record: true,
                                            ),
                                            feature: ftEntry.value,
                                          ),
                                        ),
                                  ],
                                ),
                                ScheduleRulesWidget(key: UniqueKey()),
                              ][index],
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
