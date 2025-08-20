import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/models/models_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/models/model_records_screen.dart';
import 'package:logize/screens/models/model_screen/add_tag_button.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:logize/widgets/design/txt_field.dart';

class ModelOverView extends StatelessWidget {
  final bool isNew;
  const ModelOverView({super.key, required this.isNew});

  @override
  Widget build(BuildContext context) {
    final color =
        modelEditPool.data.color ??
        modelEditPool.data.tags?.values.first.color;

    final editingNamePool = Pool<bool>(isNew);

    bool editingTags = isNew;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 7, vertical: 20),
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
                    },
                    round: false,
                    label: 'model name',
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
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.palette, color: color ?? Colors.grey),
                ),
              ],
            ),
          ),

          LazySwimmer<Model>(
            pool: modelEditPool,
            listenedEvents: ['tags'],
            builder: (context, model) => StatefulBuilder(
              builder: (context, setSate) {
                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AddTagButton(),
                    if (modelEditPool.data.tags?.isNotEmpty == true) ...[
                      ...(model.tags?.values ?? []).map<Widget>(
                        (t) => editingTags
                            ? Container(
                                margin: EdgeInsets.all(5),
                                padding: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: t.color,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: Wrap(
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                  alignment: WrapAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          modelEditPool.removeTag(t.id),
                                      icon: Icon(Icons.close, size: 17),
                                    ),
                                    Text(
                                      '#${t.name}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                  ],
                                ),
                              )
                            : Txt('#${t.name}', w: 7, color: t.color),
                      ),

                      if (!editingTags)
                        IconButton(
                          onPressed: () =>
                              setSate(() => editingTags = true),
                          icon: Icon(Icons.edit),
                        ),
                    ] else
                      Txt('add tags'),
                  ],
                );
              },
            ),
          ),

          if (!isNew)
            Row(
              children: [
                Exp(),
                Swimmer<Map<String, Model>?>(
                  pool: modelsPool,
                  builder: (context, allModels) => Button(
                    'records (${allModels?[modelEditPool.data.id]?.recordCount ?? ''})',
                    filled: false,
                    lead: MdiIcons.noteMultiple,
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
      ),
    );
  }
}
