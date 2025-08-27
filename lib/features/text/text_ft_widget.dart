import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/features/text/text_ft_class.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';
import 'package:flutter/material.dart';

class TextFtWidget extends StatelessWidget {
  final TextFt ft;
  final FeatureLock lock;
  final bool detailed;
  final void Function()? dirt;

  const TextFtWidget({
    super.key,
    required this.lock,
    required this.ft,
    required this.detailed,
    this.dirt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!lock.model)
          TxtField(
            label: 'title',
            initialValue: ft.title,
            round: true,
            onChanged: (txt) {
              ft.setTitle(txt);
              dirt!();
            },
            validator: (str) => str!.isEmpty ? 'write a title' : null,
          ),
        if (!lock.record)
          TxtField(
	    borderless: true,
            maxLines: null,
            initialValue: ft.content,
            label: 'content',
            onChanged: (str) {
              ft.setContent(str);
              dirt!();
            },
            validator: ft.isRequired
                ? (str) => str!.isEmpty ? 'empty' : null
                : null,
          ),

        if (lock.record &&
            lock.model &&
            !detailed &&
            ft.content.isNotEmpty)
          Txt(
            ft.content,
            p: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          ),
      ],
    );
  }
}
