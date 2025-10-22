import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logbloc/apis/membership.dart';
import 'package:logbloc/config/locales.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/screen_index_pool.dart';
import 'package:logbloc/screens/models/model_screen/model_screen.dart';
import 'package:logbloc/utils/nav.dart';
import 'package:logbloc/widgets/design/act_button.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/section_divider.dart';
import 'package:logbloc/widgets/design/topbar_wrap.dart';
import 'package:logbloc/widgets/design/txt.dart';

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
                return Center(child: Text('no logbooks'));
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
            onPressed: () async {
              if (membershipApi.currentPlan == 'free' &&
                  modelsPool.data!.length == 3) {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: SizedBox(
                      height: 220,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Txt(
                            'You have only 3 free logbooks and are already in use',
                            s: 18,
                            w: 8,
                          ),
                          Txt('Buy unlimited logbooks to use more'),
                          Row(
                            children: [
                              Expanded(
                                child: Button(
                                  'Buy app',
                                  onPressed: () {
                                    screenIndexPool.set((_) => 2);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                return;
              }

              navPush(screen: ModelScreen());
            },
          ),
        ],
      ),
    );
  }
}
