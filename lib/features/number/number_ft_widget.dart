import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/features/number/number_ft_class.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';
import 'package:flutter/material.dart';

class NumberFtWidget extends StatelessWidget {
  final NumberFt ft;
  final FeatureLock lock;
  final bool detailed;
  final void Function()? dirt;

  const NumberFtWidget({
    super.key,
    required this.lock,
    required this.ft,
    required this.detailed,
    this.dirt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //if (detailed) Expanded(child: Text('title:')),
        if (!lock.model)
          Expanded(
            child: TxtField(
              label: 'title',
              round: true,
              initialValue: ft.title,
              onChanged: (txt) {
                ft.setTitle(txt);
                dirt!();
              },
              validator: (str) => str!.isEmpty ? 'write a title' : null,
            ),
          ),

        if (ft.value != null && !detailed && lock.model && lock.record)
          Txt(ft.value?.toString() ?? '', w: 8),

        if (!lock.record)
          Expanded(
            child: TxtField(
              number: true,
              label: 'value',
              round: true,
              initialValue: ft.value.toString() == 'null'
                  ? ''
                  : ft.value.toString(),
              onChanged: (str) {
                dirt!();
                final parsedNum = double.tryParse(str);
                if (parsedNum != null) {
                  ft.setValue(parsedNum);
                }
              },
              validator: ft.isRequired
                  ? (str) {
                      if (str!.isEmpty) {
                        return 'empty';
                      }
                      if (double.tryParse(str) == null) {
                        return 'invalid';
                      }
                      return null;
                    }
                  : null,
            ),
          ),

        if (detailed) Expanded(child: Text('unit:')),

        if (ft.unit.isNotEmpty)
          Expanded(
            child: lock.model
                ? Text(' ${ft.unit}')
                : TxtField(
                    label: 'unit',
                    round: true,
                    initialValue: ft.unit,
                    onChanged: (txt) {
                      ft.setUnit(txt);
                      dirt!();
                    },
                  ),
          ),
      ],
    );
  }
}
