import 'package:flutter/material.dart';
import 'package:logbloc/apis/db.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/tags/tags_pool.dart';
import 'package:logbloc/utils/warn_dialogs.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/menu_button.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';

class AddTagButton extends StatelessWidget {
  const AddTagButton({super.key});

  @override
  Widget build(BuildContext context) {
    String tag = '';

    return IconButton(
      onPressed: () => showModalBottomSheet(
        showDragHandle: true,
        isDismissible: false,
        context: context,
        builder: (context) => SizedBox(
          height: 250,
          child: Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Center(
              child: Swimmer<List<String>?>(
                pool: tagsPool,
                builder: (context, tags) {
                  if (tags == null) {
                    tagsPool.retrieve();
                    return CircularProgressIndicator();
                  }

                  final formKey = GlobalKey<FormState>();
                  return ListView(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: 20,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Txt('Pick a tag', w: 7, s: 16),
                            ),
                            IconButton(
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: SizedBox(
                                    height: 130,
                                    child: Center(
                                      child: Form(
                                        key: formKey,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceEvenly,
                                          children: [
                                            TxtField(
                                              validator: (str) {
                                                if (str!.isEmpty) {
                                                  return 'give your tag a name!';
                                                }
                                                if (tagsPool.data
                                                        ?.where(
                                                          (t) => t == str,
                                                        )
                                                        .isNotEmpty ==
                                                    true) {
                                                  return 'that name is already taken!';
                                                }
                                                return null;
                                              },
                                              onChanged: (str) =>
                                                  tag = str,
                                              round: true,
                                              label: 'tag name',
                                            ),
                                            Row(
                                              children: [
                                                Button(
                                                  'cancel',
                                                  filled: false,
                                                  onPressed: () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                                ),
                                                Expanded(
                                                  child: Button(
                                                    'save',
                                                    lead: Icons
                                                        .check_circle_outline,
                                                    lg: true,
                                                    onPressed: () async {
                                                      if (!formKey
                                                          .currentState!
                                                          .validate()) {
                                                        return;
                                                      }
                                                      await db.saveTag(
                                                        tag,
                                                      );
                                                      tagsPool.data = null;
                                                      tagsPool.retrieve();
                                                      Navigator.of(
                                                        // ignore: use_build_context_synchronously
                                                        context,
                                                      ).pop();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              icon: Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),

                      ...tagsPool.data!.map(
                        (tag) => ListTile(
                          onTap: () {
                            modelEditPool.addTag(tag);
                            Navigator.of(context).pop();
                          },
                          title: Row(
                            children: [
                              Expanded(child: Txt(tag)),
                              MenuButton(
                                onSelected: (val) async {
                                  switch (val) {
                                    case 'delete':
                                      await warnDelete(
                                        context,
                                        delete: () async {
                                          modelEditPool.removeTag(tag);
                                          await db.tags!.delete(tag);
                                          return false;
                                        },
                                        msg:
                                            'The tag "$tag" will be '
                                            'removed in all models, do you want to delete it?',
                                      );

                                      break;
                                  }
                                },
                                options: [
                                  MenuOption(
                                    value: 'delete',
                                    widget: ListTile(
                                      title: Txt('delete'),
                                      leading: Icon(Icons.delete),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      icon: Icon(Icons.add),
    );
  }
}
