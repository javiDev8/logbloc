import 'package:flutter/material.dart';

class MenuOption {
  dynamic value;
  Widget widget;
  MenuOption({required this.value, required this.widget});
}

class MenuButton extends StatelessWidget {
  final List<MenuOption> options;
  final dynamic Function(dynamic)? onSelected;
  const MenuButton({super.key, required this.options, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onSelected: onSelected,
      itemBuilder:
          (context) =>
              options
                  .map(
                    (option) => PopupMenuItem(
                      value: option.value,
                      child: option.widget,
                    ),
                  )
                  .toList(),
    );
  }
}
