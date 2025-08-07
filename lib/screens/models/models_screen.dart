import 'package:logize/config/locales.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/models_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/models/model_screen/model_screen.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/act_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:logize/widgets/model_title.dart';

class ModelsScreen extends StatelessWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      Expanded(child: Divider(indent: 20, endIndent: 20)),
                    ],
                  ),
                ),
                ...models.entries.map<Widget>(
                  (m) => ListTile(
                    key: Key(m.value.name),
                    title: Text(m.value.name),
                    onTap: () => navPush(
                      context: context,
                      screen: ModelScreen(model: m.value),
                      title: ModelTitle(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        ActButton(
          icon: Icon(Icons.layers, size: 30),
          onPressed: () => navPush(
            context: context,
            screen: ModelScreen(),
            title: ModelTitle(),
          ),
        ),
      ],
    );
  }
}
