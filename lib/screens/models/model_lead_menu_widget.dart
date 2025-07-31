import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/screen_index_pool.dart';
import 'package:logize/pools/topbar_pool.dart';
import 'package:logize/screens/models/edit/model_edit_screen.dart';
import 'package:logize/screens/root_screen_switch.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/menu_button.dart';
import 'package:logize/widgets/model_edit_title.dart';
import 'package:flutter/material.dart';

class ModelLeadMenuWidget extends StatelessWidget {
  final Model model;
  final BuildContext parentCtx;
  const ModelLeadMenuWidget({
    super.key,
    required this.model,
    required this.parentCtx,
  });

  @override
  Widget build(BuildContext context) {
    return MenuButton(
      onSelected: (val) {
        String opt = val as String;
        switch (opt) {
          case 'edit':
            rootScreens[screenIndexPool.data].nav.currentState!.push(
              MaterialPageRoute(
                builder: (_) => ModelEditScreen(existingModel: model),
              ),
            );
            topbarPool.pushTitle(
              // ignore: sized_box_for_whitespace
              Container(
                width: 290,
                child: ModelEditTitle(title: 'editing ${model.name}'),
              ),
            );
            break;
          case 'delete':
            model.delete();
            navPop();
            return;
        }
      },
      options: [
        MenuOption(
          value: 'edit',
          widget: ListTile(title: Text('edit'), leading: Icon(Icons.edit)),
        ),
        MenuOption(
          value: 'delete',
          widget: ListTile(
            title: Text('delete'),
            leading: Icon(Icons.delete),
          ),
        ),
      ],
    );
  }
}
