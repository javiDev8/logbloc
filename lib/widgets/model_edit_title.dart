import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/screens/models/edit/model_edit_screen.dart';
import 'package:logize/utils/feedback.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:flutter/material.dart';

class ModelEditTitle extends StatelessWidget {
  final String title;
  const ModelEditTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title),
        Exp(),
        IconButton(
          onPressed: () async {
            if (!editModelFormKey.currentState!.validate()) {
              feedback('check your inputs');
              return;
            }
            if (modelEditPool.data.features.isEmpty) {
              feedback('add at least one feature');
              return;
            }
            await modelEditPool.save();
          },
          icon: Icon(Icons.save),
        ),
      ],
    );
  }
}
