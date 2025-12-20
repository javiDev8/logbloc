import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/screens/models/model_records_screen.dart';
import 'package:logbloc/screens/models/model_screen/add_tag_button.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:logbloc/utils/nav.dart';
import 'package:logbloc/widgets/design/act_button.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/mini_overview_grid.dart';
import 'package:logbloc/widgets/design/none.dart';
import 'package:logbloc/widgets/design/section_divider.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';

class ModelOverView extends StatelessWidget {
  final void Function() goToFeatures;
  final bool isNew;
  const ModelOverView({
    super.key,
    required this.isNew,
    required this.goToFeatures,
  });

  @override
  Widget build(BuildContext context) {
    final editingNamePool = Pool<bool>(isNew);

    bool editingTags = isNew;

    final showNextPool = Pool<bool>(false);

    return Stack(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: 7,
            vertical: 20,
          ),
          child: ListView(
            children: [
              Swimmer<bool>(
                pool: editingNamePool,
                builder: (context, editing) => Row(
                  children: [
                    Expanded(
                      child: TxtField(
                        validator: (str) =>
                            str!.isEmpty ? 'give your model a name' : null,
                        onChanged: (str) {
                          modelEditPool.setName(str);
                          modelEditPool.dirt(true);

                          if (isNew &&
                              modelEditPool.data.name.isNotEmpty) {
                            showNextPool.set((_) => true);
                          }
                        },
                        round: true,
                        label: 'logbook name',
                        initialValue: modelEditPool.data.name,
                        enabled: editing,
                      ),
                    ),
                    if (!editing)
                      IconButton(
                        onPressed: () {
                          editingNamePool.set((_) => true);
                        },
                        icon: Icon(Icons.edit),
                      ),
                  ],
                ),
              ),

              LazySwimmer<Model>(
                pool: modelEditPool,
                listenedEvents: ['tags'],
                builder: (context, model) => StatefulBuilder(
                  builder: (context, setSate) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            AddTagButton(),
                            if (modelEditPool.data.tags?.isNotEmpty ==
                                true) ...[
                              if (!editingTags)
                                IconButton(
                                  onPressed: () =>
                                      setSate(() => editingTags = true),
                                  icon: Icon(Icons.edit),
                                ),

                              ...(model.tags ?? []).map<Widget>(
                                (t) => editingTags
                                    ? Container(
                                        margin: EdgeInsets.all(1),
                                        padding: EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          //color: t.color,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                        child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          alignment:
                                              WrapAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                              padding:
                                                  EdgeInsetsGeometry.zero,
                                              onPressed: () =>
                                                  modelEditPool.removeTag(
                                                    t,
                                                  ),
                                              icon: Icon(
                                                Icons.close,
                                                size: 17,
                                              ),
                                            ),
                                            Text(
                                              '#$t',
                                              style: TextStyle(
                                                fontWeight:
                                                    FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                          ],
                                        ),
                                      )
                                    : Txt('#$t', w: 7),
                              ),
                            ] else
                              Txt('add tags'),
                          ],
                        ),

                        // palette button
                        LazySwimmer<Model>(
                          pool: modelEditPool,
                          listenedEvents: ['color'],
                          builder: (context, model) => IconButton(
                            onPressed: () async {
                              Color newColor = Colors.red;
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: SizedBox(
                                    height: 140,
                                    child: Column(
                                      children: [
                                        ColorPicker(
                                          pickerColor: newColor,
                                          pickerAreaBorderRadius:
                                              BorderRadius.all(
                                                Radius.circular(20),
                                              ),
                                          pickerAreaHeightPercent: 0.0,
                                          paletteType: PaletteType.hsl,
                                          enableAlpha: false,
                                          labelTypes: [],
                                          onColorChanged: (c) =>
                                              newColor = c,
                                        ),
                                        Row(
                                          children: [
                                            Button(
                                              'cancel',
                                              filled: false,
                                              onPressed: () =>
                                                  Navigator.of(
                                                    context,
                                                  ).pop(),
                                            ),
                                            Expanded(
                                              child: Button(
                                                'save',
                                                lead: Icons
                                                    .check_circle_outline,
                                                onPressed: () {
                                                  modelEditPool.setColor(
                                                    newColor,
                                                  );
                                                  modelEditPool.dirt(true);
                                                  Navigator.of(
                                                    context,
                                                  ).pop();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.palette, color: model.color),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              if (!isNew) ...[
                SectionDivider(string: 'Details'),

                Padding(
                  padding: EdgeInsetsGeometry.only(
                    left: 20,
                    right: 20,
                    bottom: 10,
                  ),
                  child: Column(
                    children:
                        ({
                              'created at': hdate(
                                modelEditPool.data.createdAt,
                              ),
                              'records': modelEditPool.data.recordCount
                                  .toString(),
                              'features': modelEditPool
                                  .data
                                  .features
                                  .length
                                  .toString(),
                            }.entries.map<Widget>(
                              (detailEntry) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Txt(detailEntry.key),
                                  Txt(detailEntry.value, w: 8),
                                ],
                              ),
                            ))
                            .toList(),
                  ),
                ),

                if (modelEditPool.data.recordCount > 0) ...[
                  SectionDivider(string: 'Records'),
                  MiniOverviewGrid(modelId: modelEditPool.data.id),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Swimmer<Map<String, Model>?>(
                        pool: modelsPool,
                        builder: (context, allModels) => Button(
                          'Records Insights',
                          lead: Icons.bar_chart,
                          onPressed: () => navPush(
                            screen: ModelRecordsScreen(
                              model: modelEditPool.data,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),

        Swimmer<bool>(
          pool: showNextPool,
          builder: (context, show) => show
              ? ActButton(
                  onPressed: goToFeatures,
                  icon: Icon(MdiIcons.arrowRight),
                )
              : None(),
        ),
      ],
    );
  }
}
