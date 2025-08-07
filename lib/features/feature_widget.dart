import 'package:logize/features/feature_class.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/utils/noticable_print.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:flutter/material.dart';
import 'package:logize/widgets/design/menu_button.dart';
import 'package:logize/widgets/design/txt.dart';

class FeatureLock {
  bool model;
  bool record;

  FeatureLock({required this.model, required this.record});
}

class ReadOnlyFtWidget extends StatelessWidget {
  final Feature feature;
  final Function setEditing;
  const ReadOnlyFtWidget({
    super.key,
    required this.feature,
    required this.setEditing,
  });

  @override
  Widget build(BuildContext context) {
    bool expanded = false;
    final isBright = themeModePool.data == ThemeMode.light;
    final b = isBright ? 210 : 80;
    final color = Color.fromRGBO(b, b, b, isBright ? 0.3 : 0.5);
    return StatefulBuilder(
      builder: (context, setState) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.all(Radius.circular(20)),
        ),
        color: color,
        child: InkWell(
          child: Padding(
            padding: EdgeInsetsGeometry.all(10),
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
                    Txt(feature.title, w: 8),
                    Exp(),
                    expanded
                        ? MenuButton(
                            options: [
                              MenuOption(
                                value: false,
                                widget: ListTile(
                                  onTap: () {
                                    modelEditPool.dirt(true);
                                    setEditing((_) => true);
                                    Navigator.of(context).pop();
                                  },
                                  title: Text('edit'),
                                  leading: Icon(Icons.edit),
                                ),
                              ),
                            ],
                          )
                        : IconButton(
                            onPressed: () =>
                                setState(() => expanded = true),
                            icon: Icon(Icons.arrow_drop_down_outlined),
                          ),
                  ],
                ),
                if (expanded)
                  Row(
                    children: [
                      Button(
                        'records',
                        lead: Icons.arrow_forward,
                        onPressed: () {},
                        filled: false,
                      ),
                      Exp(),
                      IconButton(
                        onPressed: () => setState(() => expanded = false),
                        icon: Icon(Icons.arrow_drop_up_outlined),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FtWid extends StatelessWidget {
  final Feature feature;
  final FeatureLock lock;
  const FtWid({super.key, required this.feature, required this.lock});

  @override
  Widget build(BuildContext context) {
    nPrint('feature is new? ${feature.isNew}');
    final editingPool = Pool<bool>(feature.isNew == true);

    return Swimmer<bool>(
      pool: editingPool,
      builder: (context, editing) => editing
          ? FeatureWidget(lock: lock, feature: feature)
          : ReadOnlyFtWidget(
              feature: feature,
              setEditing: editingPool.set,
            ),
    );
  }
}

class FeatureWidget extends StatelessWidget {
  final FeatureLock lock;
  final Feature feature;
  final bool detailed;
  final bool compact;

  const FeatureWidget({
    super.key,
    required this.lock,
    required this.feature,
    this.detailed = false,
    this.compact = false,
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
                              onPressed: () => setState(
                                () => feature.isRequired =
                                    !feature.isRequired,
                              ),
                              icon: Icon(
                                feature.isRequired
                                    ? Icons.error
                                    : Icons.error_outline,
                              ),
                            ),
                          IconButton(
                            onPressed: () => setState(
                              () => feature.pinned = !feature.pinned,
                            ),
                            icon: Icon(
                              feature.pinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                modelEditPool.removeFeature(feature.key),
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
