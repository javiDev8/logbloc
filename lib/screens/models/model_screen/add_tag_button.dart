import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/tags_pool.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/menu_button.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:logize/widgets/design/txt_field.dart';

class AddTagButton extends StatelessWidget {
  const AddTagButton({super.key});

  @override
  Widget build(BuildContext context) {
    Tag tag = Tag.empty();

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
              child: Swimmer<Map<String, Tag>?>(
                pool: tagsPool,
                builder: (context, tags) {
                  if (tags == null) {
                    tagsPool.retrieve();
                    return CircularProgressIndicator();
                  }

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
                                    height: 240,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TxtField(
                                            onChanged: (str) =>
                                                tag.name = str,
                                            round: true,
                                            label: 'tag name',
                                          ),
                                          ColorPicker(
                                            pickerAreaBorderRadius:
                                                BorderRadius.all(
                                                  Radius.circular(20),
                                                ),
                                            pickerAreaHeightPercent: 0.0,
                                            paletteType: PaletteType.hsl,
                                            enableAlpha: false,
                                            labelTypes: [],
                                            pickerColor: Color.fromRGBO(
                                              200,
                                              50,
                                              50,
                                              1,
                                            ),
                                            onColorChanged: (color) =>
                                                tag.color = color,
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
                                                    await tag.save();
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
                              icon: Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),

                      ...tagsPool.data!.entries.map(
                        (tagEntry) => ListTile(
                          onTap: () {
                            modelEditPool.addTag(
                              tagsPool.data![tagEntry.key]!,
                            );
                            Navigator.of(context).pop();
                          },
                          title: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: tagEntry.value.color,
                              ),
                              Expanded(child: Txt(tagEntry.value.name)),
                              MenuButton(options: []),
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
