import 'package:logize/features/feature_class.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:flutter/material.dart';

class FeatureLock {
  bool model;
  bool record;

  FeatureLock({required this.model, required this.record});
}

class FeatureWidget extends StatelessWidget {
  final FeatureLock lock;
  final Feature feature;
  final bool detailed;

  const FeatureWidget({
    super.key,
    required this.lock,
    required this.feature,
    this.detailed = false,
  });

  @override
  Widget build(BuildContext context) {
    final isBright = themeModePool.data == ThemeMode.light;
    final b = isBright ? 210 : 80;
    final color = Color.fromRGBO(b, b, b, isBright ? 0.3 : 0.5);
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  size: 25,
                  featureSwitch(parseType: 'icon', ft: feature)
                      as IconData,
                ),
              ),
              featureSwitch(parseType: 'label', ft: feature) as Widget,
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
                              onPressed:
                                  () => setState(
                                    () =>
                                        feature.isRequired =
                                            !feature.isRequired,
                                  ),
                              icon: Icon(
                                feature.isRequired
                                    ? Icons.error
                                    : Icons.error_outline,
                              ),
                            ),
                          IconButton(
                            onPressed:
                                () => setState(
                                  () => feature.pinned = !feature.pinned,
                                ),
                            icon: Icon(
                              feature.pinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                            ),
                          ),
                          IconButton(
                            onPressed:
                                () => modelEditPool.removeFeature(
                                  feature.key,
                                ),
                            icon: Icon(Icons.close),
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
              )
              as Widget,
        ],
      ),
    );
  }
}
