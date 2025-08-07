import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/models/models_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/models/model_records_screen.dart';
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
                    onChanged: (str) => modelEditPool.setName(str),
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
                      modelEditPool.dirt(true);
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

          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.add)),
              if (modelEditPool.data.tags?.isNotEmpty == true)
                ...modelEditPool.data.tags!.values.map<Widget>(
                  (t) => Txt(t.name),
                )
              else
                Txt('add tags'),
            ],
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
                    lead: Icons.arrow_forward,
                    onPressed: () => navPush(
                      context: context,
                      screen: ModelRecordsScreen(
                        model: modelEditPool.data,
                      ),
                      title: Text('${modelEditPool.data.name} records'),
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
