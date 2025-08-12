import 'package:flutter/material.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/txt.dart';

Future warnDelete(
  BuildContext context, {
  required Future<bool> Function() delete,
}) async => await showDialog(
  context: context,
  builder: (context) => AlertDialog(
    content: Txt('are you sure?'),
    actions: [
      Button(
        'cancel',
        filled: false,
        onPressed: () => Navigator.of(context).pop(),
      ),
      Button(
        'delete',
        lead: Icons.delete,
        onPressed: () async {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop(await delete());
          navPop();
        },
      ),
    ],
  ),
);
