enum FieldType { text, currency, phone }

extension FieldTypeExtension on FieldType {
  bool get isCurrency => this == FieldType.currency;

  bool get isPhone => this == FieldType.phone;
}
