import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logbloc/apis/membership.dart';
import 'package:logbloc/config/locales.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/screen_index_pool.dart';
import 'package:logbloc/screens/models/model_screen/model_screen.dart';
import 'package:logbloc/utils/app_review_manager.dart';
import 'package:logbloc/utils/nav.dart';
import 'package:logbloc/widgets/design/act_button.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/section_divider.dart';
import 'package:logbloc/widgets/design/topbar_wrap.dart';
import 'package:logbloc/widgets/design/txt.dart';

final GlobalKey addModelButtonKey = GlobalKey();

class ModelsScreen extends StatelessWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: wrapBar(
        children: [
          Padding(padding: EdgeInsets.all(10), child: TrText(Tr.models)),
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
            key: addModelButtonKey,
            icon: Icon(MdiIcons.notebookPlusOutline, size: 30),
            onPressed: () async {
              if (membershipApi.currentPlan == 'free' &&
                  modelsPool.data!.length == 3) {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: SizedBox(
                      height: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Txt(
                            'Your 3 free logbooks are already in use!',
                            s: 18,
                            w: 8,
                          ),
                          Txt(
                            'Unlock unlimited logbooks forever '
                            'with a single, low-cost purchase.',
                            s: 16,
                            w: 6,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Button(
                                  'L E T S   G O',
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
              // Check for review after creating a new model
              AppReviewManager.checkAndRequestReview(context);
            },
          ),
        ],
      ),
    );
  }
}
