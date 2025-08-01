import 'package:logize/features/feature_widget.dart';
import 'package:logize/features/text/text_ft_class.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:logize/widgets/design/txt_field.dart';
import 'package:flutter/material.dart';

class TextFtWidget extends StatelessWidget {
  final TextFt ft;
  final FeatureLock lock;
  final bool detailed;
  const TextFtWidget({
    super.key,
    required this.lock,
    required this.ft,
    required this.detailed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        lock.model
            ? Row(
              children: [
                if (detailed) Expanded(child: Text('prompt:')),
                Expanded(child: Txt(ft.prompt, w: 8)),
              ],
            )
            : TxtField(
              hint: 'prompt',
              initialValue: ft.prompt,
              round: true,
              onChanged: (txt) => ft.setPrompt(txt),
              validator: (str) => str!.isEmpty ? 'write a prompt' : null,
            ),
        if (!lock.record)
          TxtField(
	    maxLines: null,
            initialValue: ft.content,
            round: true,
            hint: 'content',
            onChanged: (str) => ft.setContent(str),
            validator:
                ft.isRequired
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
