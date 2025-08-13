import 'package:flutter/material.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/utils/warn_dialogs.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:logize/widgets/design/menu_button.dart';
import 'package:logize/widgets/design/none.dart';
import 'package:logize/widgets/design/txt.dart';

List<Widget> makeModelTitle({bool? isNew}) => [
  LazySwimmer<Model>(
    pool: modelEditPool,
    listenedEvents: ['name'],
    builder: (context, model) => Txt(model.name),
  ),
  Exp(),
  LazySwimmer<Model>(
    pool: modelEditPool,
    listenedEvents: ['dirty'],
    builder: (context, model) => modelEditPool.dirty
        ? IconButton(
            onPressed: () {
              modelEditPool.save();
            },
            icon: Icon(Icons.check_circle_outlined),
          )
        : None(),
  ),

  if (isNew != true)
    Builder(
      builder: (context) => MenuButton(
        onSelected: (val) async {
          switch (val) {
            case 'delete':
              try {
                await warnDelete(
                  context,
                  delete: modelEditPool.data.delete,
                  msg: modelEditPool.data.recordCount > 0
                      ? '${modelEditPool.data.recordCount} records will be deleted,'
                            ' do you still want to delete the model "${modelEditPool.data.name}"?'
                      : 'Are yoy sure you want to delete this model?',
                );
                break;
              } catch (e) {
                throw Exception(e);
              }
            default:
              throw Exception('option not implemented');
          }
        },

        options: [
          MenuOption(
            value: 'archive',
            widget: ListTile(
              title: Text('archive'),
              leading: Icon(Icons.archive),
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
    ),
];

openFts(BuildContext context) {
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
                        style: TextStyle(fontWeight: FontWeight.w600),
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
                  title: featureSwitch(parseType: 'label', ftType: ftType),
                  leading: Icon(
                    (featureSwitch(parseType: 'icon', ftType: ftType)),
                  ),
                  onTap: () {
                    modelEditPool.setFeature(
                      featureSwitch(parseType: 'class', ftType: ftType),
                    );
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
}
