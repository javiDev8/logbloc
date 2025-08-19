import 'package:flutter/material.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:logize/widgets/design/txt.dart';

class ModelFeaturesView extends StatelessWidget {
  const ModelFeaturesView({super.key});

  @override
  Widget build(BuildContext context) {
    String showing = 'all';
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
      child: LazySwimmer<Model>(
        pool: modelEditPool,
        listenedEvents: ['features'],
        builder: (context, model) {
          final features = model.getSortedFeatureList();
          return StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.only(top: 15, bottom: 5),
                  child: Row(
                    children: [
                      ...['unpinned', 'pinned', 'all'].map(
                        (s) => Button(
                          s,
                          onPressed: () => setState(() => showing = s),
                          filled: s == showing,
                          variant: 1,
                        ),
                      ),
                      Exp(),
                      AddFtButton(),
                    ],
                  ),
                ),
                Expanded(
                  child: ReorderableListView(
                    onReorder: (oldIndex, newIndex) =>
                        modelEditPool.reorderFeature(
                          newIndex,
                          features[oldIndex].key,
                          features.map<String>((f) => f.key).toList(),
                        ),
                    children: features
                        .where(
                          (ft) => showing == 'all'
                              ? true
                              : (showing == 'pinned'
                                    ? (ft.pinned == true)
                                    : (ft.pinned != true)),
                        )
                        .map(
                          (ft) => FtWid(
                            dirt: () {
                              if (!modelEditPool.dirty) {
                                modelEditPool.dirt(true);
                              }
                            },
                            key: Key(ft.key),
                            feature: ft,
                            lock: FeatureLock(model: false, record: true),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AddFtButton extends StatelessWidget {
  const AddFtButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Button(
      null,
      lead: (Icons.add),
      onPressed: () {
        showModalBottomSheet(
          isDismissible: false,
          showDragHandle: true,
          context: context,
          builder: (context) => SizedBox(
            height: availableFtTypes.length * 50 + 100,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Txt('Pick a feature', w: 7, s: 16),
                          ),
                        ],
                      ),
                    ),

                    ...availableFtTypes.map(
                      (ftType) => ListTile(
                        title: featureSwitch(
                          parseType: 'label',
                          ftType: ftType,
                        ),
                        leading: Icon(
                          (featureSwitch(
                            parseType: 'icon',
                            ftType: ftType,
                          )),
                        ),
                        onTap: () {
                          modelEditPool.setFeature(
                            featureSwitch(
                              parseType: 'class',
                              ftType: ftType,
                            ),
                          );
                          modelEditPool.dirt(true);
                          navPop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
