import 'package:flutter/material.dart';

class Dropdown extends StatelessWidget {
  final List<DropdownMenuEntry> entries;
  final dynamic init;
  final void Function(dynamic) onSelect;
  final Widget? label;
  const Dropdown({
    super.key,
    required this.entries,
    required this.onSelect,
    this.init,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsGeometry.all(5),
        child: DropdownMenu(
          label: label,
          dropdownMenuEntries: entries,
          onSelected: onSelect,
          initialSelection: init,
          expandedInsets: EdgeInsets.zero,
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(right: 0, left: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          menuStyle: MenuStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
