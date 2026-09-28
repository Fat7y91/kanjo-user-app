import 'package:flutter/foundation.dart';
import 'package:reactive_forms/reactive_forms.dart';

class MapNotEqualsValidator extends Validator<dynamic> {
  final Map<String, dynamic>? value;
  final String validationMessage;

  const MapNotEqualsValidator(
    this.value, {
    this.validationMessage = ValidationMessage.equals,
  }) : super();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    return !mapEquals(control.value, value)
        ? null
        : <String, dynamic>{
            validationMessage: <String, dynamic>{
              'required': value,
              'actual': control.value,
            }
          };
  }
}
