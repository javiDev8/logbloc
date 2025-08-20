import 'package:logize/features/feature_class.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/screens/models/model_screen/feature_stats_screen.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/utils/warn_dialogs.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:flutter/material.dart';
import 'package:logize/widgets/design/txt.dart';

class FeatureLock {
  bool model;
  bool record;

  FeatureLock({required this.model, required this.record});
}

class ReadOnlyFtWidget extends StatelessWidget {
  final Feature feature;
  const ReadOnlyFtWidget({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final isBright = themeModePool.data == ThemeMode.light;
    final b = isBright ? 150 : 100;
    final color = Color.fromRGBO(b, b, b, isBright ? 0.3 : 0.5);
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                navPush(screen: FeatureStatsScreen(ftKey: feature.key));
              },
              child: Padding(
                padding: EdgeInsetsGeometry.all(10),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        size: 25,
                        featureSwitch(parseType: 'icon', ft: feature)
                            as IconData,
                      ),
                    ),
                    Txt(feature.title, w: 8),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(right: 15),
            child: IconButton(
              onPressed: () {
                modelEditPool.editingFts.add(feature.id);
                modelEditPool.controller.sink.add('features');
              },
              icon: Icon(Icons.expand_more),
            ),
          ),
        ],
      ),
    );
  }
}

class FtWid extends StatelessWidget {
  final Feature feature;
  final FeatureLock lock;
  final void Function()? dirt;
  const FtWid({
    super.key,
    required this.feature,
    required this.lock,
    this.dirt,
  });

  @override
  Widget build(BuildContext context) {
    final editing = modelEditPool.editingFts.contains(feature.id);
    return editing
        ? FeatureWidget(
            lock: lock,
            feature: feature,
            dirt: dirt,
            compactable: true,
          )
        : ReadOnlyFtWidget(feature: feature);
  }
}

class FeatureWidget extends StatelessWidget {
  final FeatureLock lock;
  final Feature feature;
  final bool detailed;
  final void Function()? dirt;
  final bool? compactable;

  const FeatureWidget({
    super.key,
    required this.lock,
    required this.feature,
    this.detailed = false,
    this.dirt,
    this.compactable,
  });

  @override
  Widget build(BuildContext context) {
    final isBright = themeModePool.data == ThemeMode.light;
    final b = 130;
    final color = Color.fromRGBO(b, b, b, isBright ? 0.3 : 0.5);
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Icon(
                  size: 20,
                  featureSwitch(parseType: 'icon', ft: feature)
                      as IconData,
                ),
              ),
              SizedBox(
                width: lock.model ? null : 110,
                child: Txt(feature.title, w: 8),
              ),
              Exp(),
              if (!lock.record && feature.pinned)
                Icon(Icons.push_pin)
              else if (!lock.model)
                StatefulBuilder(
                  builder: (_, setState) {
                    return SizedBox(
                      child: Wrap(
                        children: [
                          if (![
                            // non requirable features
                            'task_list',
                            'reminder',
                          ].contains(feature.type))
                            IconButton(
                              onPressed: () {
                                setState(
                                  () => feature.isRequired =
                                      !feature.isRequired,
                                );
                                modelEditPool.dirt(true);
                              },
                              icon: Icon(
                                feature.isRequired
                                    ? Icons.error
                                    : Icons.error_outline,
                              ),
                            ),
                          IconButton(
                            onPressed: () {
                              setState(
                                () => feature.pinned = !feature.pinned,
                              );
                              modelEditPool.controller.sink.add(
                                'features',
                              );
                              modelEditPool.dirt(true);
                            },
                            icon: Icon(
                              feature.pinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                            ),
                          ),
                          IconButton(
                            onPressed: () => warnDelete(
                              context,
                              preventPop: true,
                              delete: () {
                                modelEditPool.removeFeature(feature.key);
                                return true;
                              },
                              msg: 'Delete feature?',
                            ),
                            icon: Icon(Icons.close),
                          ),

                          if (compactable == true)
                            IconButton(
                              onPressed: () {
                                modelEditPool.editingFts.remove(
                                  feature.id,
                                );
                                modelEditPool.controller.sink.add(
                                  'features',
                                );
                              },
                              icon: Icon(Icons.expand_less),
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          featureSwitch(
                parseType: 'widget',
                ft: feature,
                lock: lock,
                detailed: detailed,
                dirt: dirt,
              )
              as Widget,
        ],
      ),
    );
  }
}
