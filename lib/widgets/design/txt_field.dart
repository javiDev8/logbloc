import 'package:flutter/material.dart';

class TxtField extends StatelessWidget {
  final void Function(String)? onChanged;
  final String? hint;
  final bool? round;
  final String? initialValue;
  final String? Function(String?)? validator;
  final String? label;
  final void Function(PointerDownEvent)? onTapOutside;

  const TxtField({
    super.key,
    this.onChanged,
    this.hint,
    this.round,
    this.initialValue,
    this.validator,
    this.onTapOutside,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(7),
      child: TextFormField(
        onTapOutside: onTapOutside,
        validator: validator,
        onChanged: onChanged,
        controller:
            initialValue == null
                ? null
                : TextEditingController(text: initialValue),
        decoration: InputDecoration(
          label: label == null ? null : Text(label!),
          contentPadding: EdgeInsets.only(left: 20, right: 20),
          hintText: hint,
          border:
              round == null || !round!
                  ? null
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
        ),
      ),
    );
  }
}
