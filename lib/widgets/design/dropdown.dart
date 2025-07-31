import 'package:flutter/material.dart';

class Dropdown extends StatelessWidget {
  final List<DropdownMenuEntry> entries;
  final dynamic init;
  final void Function(dynamic) onSelect;
  const Dropdown({
    super.key,
    required this.entries,
    this.init,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      dropdownMenuEntries: entries,
      onSelected: onSelect,
      initialSelection: init,
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.only(right: 20, left: 20),
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
    );
  }
}
