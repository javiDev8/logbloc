import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/features/feature_switch.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/utils/warn_dialogs.dart';
import 'package:logbloc/widgets/design/exp.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/design/txt.dart';

class FeatureLock {
  bool model;
  bool record;

  FeatureLock({required this.model, required this.record});
}
//delete: () {
//  modelEditPool.removeFeature(feature.key);
//  modelEditPool.dirt(true);
//  return true;
//},

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
          if (feature.type != 'task_list' || !lock.model)
            Padding(
              padding: EdgeInsets.only(top: lock.model ? 5 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.only(left: 10),
                    child: Icon(
                      featureSwitch(parseType: 'icon', ft: feature)
                          as IconData,
                    ),
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
                                onPressed: () {
                                  warnDelete(
                                    context,
                                    delete: () {
                                      modelEditPool.removeFeature(
                                        feature.key,
                                      );
                                      modelEditPool.dirt(true);
                                      return true;
                                    },
                                    msg: 'Remove feature?',
                                  );
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
