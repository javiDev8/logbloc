import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/features/feature_switch.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/screens/models/model_screen/feature_stats_screen.dart';
import 'package:logbloc/utils/nav.dart';
import 'package:logbloc/utils/warn_dialogs.dart';
import 'package:logbloc/widgets/design/exp.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/design/menu_button.dart';
import 'package:logbloc/widgets/design/txt.dart';

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
    final b = 130;
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
            child: Padding(
              padding: EdgeInsetsGeometry.all(10),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      featureSwitch(parseType: 'icon', ft: feature)
                          as IconData,
                    ),
                  ),
                  Txt(feature.title, w: 8),
                ],
              ),
            ),
          ),

          if (modelsPool.data?[modelEditPool.data.id] != null)
            FtMenuBtn(feature: feature, expanded: false)
          else
            IconButton(
              onPressed: () {
                modelEditPool.removeFeature(feature.key);
                modelEditPool.dirt(true);
              },
              icon: Icon(Icons.close),
            ),
        ],
      ),
    );
  }
}

class FtMenuBtn extends StatelessWidget {
  final Feature feature;
  final bool expanded;

  const FtMenuBtn({
    super.key,
    required this.feature,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(right: 10),
      child: MenuButton(
        onSelected: (val) {
          switch (val) {
            case 'expand':
              if (expanded) {
                modelEditPool.editingFts.remove(feature.id);
                modelEditPool.controller.sink.add('features');
              } else {
                modelEditPool.editingFts.add(feature.id);
                modelEditPool.controller.sink.add('features');
              }
              break;

            case 'stats':
              navPush(screen: FeatureStatsScreen(ftKey: feature.key));
              break;

            case 'delete':
              warnDelete(
                context,
                delete: () {
                  modelEditPool.removeFeature(feature.key);
                  modelEditPool.dirt(true);
                  return true;
                },
                msg: 'Delete feature?',
              );
              break;
          }
        },
        options: [
          MenuOption(
            value: 'stats',
            widget: ListTile(
              title: Text('check stats'),
              leading: Icon(Icons.bar_chart),
            ),
          ),
          MenuOption(
            value: 'expand',
            widget: ListTile(
              title: Text(expanded ? 'compact' : 'expand'),
              leading: Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
              ),
            ),
          ),

          MenuOption(
            value: 'delete',
            widget: ListTile(
              title: Text('delete'),
              leading: Icon(Icons.delete),
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          if (feature.type !=
              'task_list') // add more non headed fts as wanted
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    featureSwitch(parseType: 'icon', ft: feature)
                        as IconData,
                  ),
                  SizedBox(
                    width: lock.model ? null : 90,
                    child: lock.model
                        ? Txt(feature.title, w: 8)
                        : Padding(
                            padding: EdgeInsetsGeometry.only(left: 7),
                            child: featureSwitch(
                              parseType: 'label',
                              ftType: feature.type,
                            ),
                          ),
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

                              if (modelsPool.data?[modelEditPool
                                      .data
                                      .id] !=
                                  null)
                                FtMenuBtn(feature: feature, expanded: true)
                              else
                                IconButton(
                                  onPressed: () {
                                    modelEditPool.removeFeature(
                                      feature.key,
                                    );
                                    modelEditPool.dirt(true);
                                  },
                                  icon: Icon(Icons.close),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
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
