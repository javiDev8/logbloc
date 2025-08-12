import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/txt.dart';

FutureOr<bool?> warnUnsavedChanges(
  BuildContext context, {
  required FutureOr<bool> Function() save,
}) async => await showDialog(
  context: context,
  builder: (context) => Builder(
    builder: (context) => AlertDialog(
      content: Txt('you have unsaved changes!'),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        Button(
          'discard',
          lead: Icons.close,
          filled: false,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        Button(
          'save',
          lead: Icons.check_circle_outline,
          onPressed: () async {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop(await save());
          },
        ),
      ],
    ),
  ),
);

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
