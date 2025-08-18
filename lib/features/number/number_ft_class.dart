import 'package:logize/features/feature_class.dart';

class NumberFt extends Feature {
  double? value;
  String unit;

  NumberFt({
    required super.id,
    required super.type,
    required super.title,
    required super.pinned,
    required super.isRequired,
    required super.position,

    this.value,
    required this.unit,
  });

  factory NumberFt.fromBareFt(
    Feature ft, {
    required double? value,
    required String unit,
  }) {
    return NumberFt(
      id: ft.id,
      type: ft.type,
      title: ft.title,
      pinned: ft.pinned,
      isRequired: ft.isRequired,
      position: ft.position,

      value: value,
      unit: unit,
    );
  }

  @override
  factory NumberFt.empty() =>
      NumberFt.fromBareFt(Feature.empty('number'), value: null, unit: '');

  @override
  factory NumberFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) => NumberFt.fromBareFt(
    Feature.fromEntry(entry),
    value: recordFt != null
        ? (recordFt['value'] as num?)?.toDouble()
        : (entry.value['value'] as num?)?.toDouble(),
    unit: entry.value['unit'],
  );

  @override
  Map<String, dynamic> serialize() => {
    ...super.serialize(),
    'value': value,
    'unit': unit,
  };

  @override
  Map<String, dynamic> makeRec() => {...super.makeRec(), 'value': value};

  setUnit(String newUnit) => unit = newUnit;
  setValue(double newValue) => value = newValue;
}
