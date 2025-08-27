import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logbloc/config/locales.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/screens/models/model_screen/model_screen.dart';
import 'package:logbloc/utils/nav.dart';
import 'package:logbloc/widgets/design/act_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:logbloc/widgets/design/section_divider.dart';
import 'package:logbloc/widgets/design/topbar_wrap.dart';

class ModelsScreen extends StatelessWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: wrapBar(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: TrText(Tr.models),
          ),
        ],
        backable: false,
      ),
      body: Stack(
        children: [
          Swimmer<Map<String, Model>?>(
            pool: modelsPool,
            builder: (context, models) {
              if (models == null) {
                modelsPool.retrieve();
                return Center(child: CircularProgressIndicator());
              }

              if (models.isEmpty) {
                return Center(child: Text(Tr.noModels.getString(context)));
              }

              return ListView(
                children: [
                  SectionDivider(),
                  ...models.entries.map<Widget>(
                    (m) => ListTile(
                      key: Key(m.value.name),
                      title: Text(m.value.name),
                      onTap: () => navPush(
                        screen: ModelScreen(
                          // necessary deep copy
                          model: Model.fromMap(map: m.value.serialize()),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          ActButton(
            icon: Icon(MdiIcons.notebookPlusOutline, size: 30),
            onPressed: () => navPush(screen: ModelScreen()),
          ),
        ],
      ),
    );
  }
}
