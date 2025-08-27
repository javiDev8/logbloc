import 'package:logbloc/widgets/design/header.dart';
import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  final String? string;
  final Widget? lead;
  const SectionDivider({super.key, this.string, this.lead});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          string != null ? Header(string!) : SizedBox.shrink(),
          Expanded(child: Divider(indent: 20, endIndent: 20)),
          if (lead != null) lead!,
        ],
      ),
    );
  }
}
