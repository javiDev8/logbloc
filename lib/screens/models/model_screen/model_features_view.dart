import 'package:flutter/material.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/topbar_pool.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/section_divider.dart';

class ModelFeaturesView extends StatelessWidget {
  const ModelFeaturesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
      child: LazySwimmer<Model>(
        pool: modelEditPool,
        listenedEvents: ['features'],
        builder: (context, model) {
          final features = model.getSortedFeatureList();
          return Column(
            children: [
              SectionDivider(lead: AddFtButton()),
              Expanded(
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) => modelEditPool
                      .reorderFeature(newIndex, features[oldIndex].key),
                  children: features
                      .map(
                        (ft) => FtWid(
                          key: Key(ft.key),
                          feature: ft,
                          lock: FeatureLock(model: false, record: true),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
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
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        topbarPool.pushTitle(Text('features'));
        showModalBottomSheet(
          isDismissible: false,
          enableDrag: false,
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
                            child: Text(
                              'Select a feature',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => navPop(),
                            icon: Icon(Icons.close),
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
