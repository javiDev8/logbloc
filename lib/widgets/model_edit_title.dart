import 'package:logize/pools/models/model_edit_pool.dart';
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
          onPressed: () async => await modelEditPool.save(),
          icon: Icon(Icons.save),
        ),
      ],
    );
  }
}
