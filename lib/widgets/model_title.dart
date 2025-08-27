import 'package:flutter/material.dart';
import 'package:logbloc/features/feature_switch.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/utils/nav.dart';
import 'package:logbloc/utils/warn_dialogs.dart';
import 'package:logbloc/widgets/design/exp.dart';
import 'package:logbloc/widgets/design/menu_button.dart';
import 'package:logbloc/widgets/design/none.dart';
import 'package:logbloc/widgets/design/txt.dart';

List<Widget> makeModelTitle({bool? isNew}) => [
  SizedBox(
    width: 200,
    child: LazySwimmer<Model>(
      pool: modelEditPool,
      listenedEvents: ['name'],
      builder: (context, model) => Txt(model.name),
    ),
  ),
  Exp(),
  LazySwimmer<Model>(
    pool: modelEditPool,
    listenedEvents: ['dirty'],
    builder: (context, model) => modelEditPool.dirty
        ? IconButton(
            onPressed: () async {
              if (await modelEditPool.save()) {
                if (isNew != false) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
              }
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
          //MenuOption(
          //  value: 'archive',
          //  widget: ListTile(
          //    title: Text('archive'),
          //    leading: Icon(Icons.archive),
          //  ),
          //),
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
