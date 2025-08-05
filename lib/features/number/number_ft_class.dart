import 'package:logize/features/feature_class.dart';

class NumberFt extends Feature {
  String label;
  double? value;
  String unit;

  NumberFt({
    required super.id,
    required super.type,
    required super.pinned,
    required super.isRequired,
    required super.position,

    required this.label,
    this.value,
    required this.unit,
  });

  factory NumberFt.fromBareFt(
    Feature ft, {
    required String label,
    required double? value,
    required String unit,
  }) {
    return NumberFt(
      id: ft.id,
      type: ft.type,
      pinned: ft.pinned,
      isRequired: ft.isRequired,
      position: ft.position,

      label: label,
      value: value,
      unit: unit,
    );
  }

  @override
  factory NumberFt.empty() => NumberFt.fromBareFt(
    Feature.empty('number'),
    label: '',
    value: null,
    unit: '',
  );

  @override
  factory NumberFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) => NumberFt.fromBareFt(
    Feature.fromEntry(entry),
    label: entry.value['label'] as String,
    value: recordFt != null
        ? (recordFt['value'] as num?)?.toDouble()
        : (entry.value['value'] as num?)?.toDouble(),
    unit: entry.value['unit'],
  );

  @override
  Map<String, dynamic> serialize() => {
    ...super.serialize(),
    'label': label,
    'value': value,
    'unit': unit,
  };

  @override
  Map<String, dynamic> makeRec() => {'value': value};

  setLabel(String newLabel) => label = newLabel;
  setUnit(String newUnit) => unit = newUnit;
  setValue(double newValue) => value = newValue;
}
