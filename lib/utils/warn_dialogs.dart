import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/button.dart';

FutureOr<bool?> warnUnsavedChanges(
  BuildContext context, {
  required FutureOr<bool> Function() save,
}) async => await showDialog(
  context: context,
  builder: (context) => Builder(
    builder: (context) => AlertDialog(
      content: Padding(
        padding: EdgeInsetsGeometry.only(top: 10),
        child: Text(
          'you have unsaved changes!',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 20,
        top: 0,
      ),
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
  required FutureOr<bool> Function() delete,
  required String msg,
  bool? preventPop,
}) async => await showDialog(
  context: context,
  builder: (context) => AlertDialog(
    content: Padding(
      padding: EdgeInsetsGeometry.only(top: 10),
      child: Text(msg, style: TextStyle(fontWeight: FontWeight.w700)),
    ),
    actionsAlignment: MainAxisAlignment.spaceEvenly,
    actionsPadding: EdgeInsets.only(
      left: 10,
      right: 10,
      bottom: 20,
      top: 0,
    ),
    actions: [
      Button(
        'cancel',
        lead: Icons.close,
        filled: false,
        onPressed: () => Navigator.of(context).pop(),
      ),
      Button(
        'delete',
        lead: Icons.delete,
        onPressed: () async {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop(await delete());
          if (preventPop != true) {
            navPop();
          }
        },
      ),
    ],
  ),
);
