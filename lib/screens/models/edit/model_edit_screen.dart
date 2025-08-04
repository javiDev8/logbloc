import 'package:logize/assets/icons.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/config/locales.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/screens/models/edit/actions/add_ft_button.dart';
import 'package:logize/screens/models/edit/schedule_rules_widget.dart';
import 'package:logize/utils/color_convert.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/section_divider.dart';
import 'package:logize/widgets/design/txt_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

final editModelFormKey = GlobalKey<FormState>();

class ModelEditScreen extends StatelessWidget {
  final Model? existingModel;
  const ModelEditScreen({super.key, this.existingModel});

  @override
  Widget build(BuildContext context) {
    modelEditPool.data = existingModel ?? Model.empty();

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

          builder: (context, model) {
            final sortedFts = modelEditPool.data.getSortedFeatureList();
            return Form(
              key: editModelFormKey,
              child: Column(
                children: [
                  TxtField(
                    onChanged: (str) => modelEditPool.setName(str),
                    validator: (str) =>
                        str!.isEmpty ? 'give your model a name' : null,
                    hint: Tr.newModelNameHint.getString(context),
                    initialValue: modelEditPool.data.name,
                    round: true,
                  ),

                  Swimmer<int>(
                    pool: tabIndexPool,
                    builder: (c, index) => Row(
                      children: [
                        Button(
                          null,
                          filled: index == 0,
                          onPressed: () => tabIndexPool.set((_) => 0),
                          lead: addFtIcon,
                        ),
                        Button(
                          null,
                          variant: 2,
                          filled: index == 1,
                          onPressed: () => tabIndexPool.set((_) => 1),
                          lead: Icons.calendar_month,
                        ),
                        LazySwimmer<Model>(
                          pool: modelEditPool,
                          listenedEvents: ['color'],
                          builder: (context, m) => Button(
                            null,
                            overwrittenColor: m.color ?? Colors.grey,
                            filled: index == 2,
                            onPressed: () => tabIndexPool.set((_) => 2),
                            lead: Icons.palette,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Swimmer<int>(
                    pool: tabIndexPool,
                    builder: (c, index) => [
                      Expanded(
                        child: Column(
                          children: [
                            SectionDivider(
                              string: 'Features',
                              lead: AddFtButton(),
                            ),

                            Expanded(
                              child: ReorderableListView(
                                onReorder: (oldIndex, newIndex) =>
                                    modelEditPool.reorderFeature(
                                      newIndex,
                                      sortedFts[oldIndex].key,
                                    ),
                                children: sortedFts
                                    .map(
                                      (ft) => FeatureWidget(
                                        key: Key(ft.key),
                                        lock: FeatureLock(
                                          model: false,
                                          record: true,
                                        ),
                                        feature: ft,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ScheduleRulesWidget(key: UniqueKey()),

                      Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 15),
                        child: Column(
                          children: [
                            SectionDivider(string: 'Color picker'),
                            ...[0, 1, 2].map<Widget>(
                              (k) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children:
                                    List.generate(
                                      7,
                                      (i) => (130 / 7).round() * (i + 1),
                                    ).map<Widget>((j) {
                                      List<int> ca = [0, 0, 0];
                                      final prev = k == 0 ? 2 : k - 1;
                                      final next = k == 2 ? 0 : k + 1;
                                      ca[k] = 130;
                                      ca[prev] = j > 3 ? 50 : j;
                                      ca[next] = j > 3 ? j : 50;

                                      final c = Color.fromRGBO(
                                        ca[0],
                                        ca[1],
                                        ca[2],
                                        1,
                                      );
                                      final color =
                                          themeModePool.data ==
                                              ThemeMode.dark
                                          ? c
                                          : enbrightColor(c);
                                      return IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                        color: color,
                                        onPressed: () {
                                          modelEditPool.setColor(color);
                                        },
                                        icon: Icon(Icons.circle),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ][index],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
