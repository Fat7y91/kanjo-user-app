import 'package:reactive_forms/reactive_forms.dart';

class NotEqualsValidator<T> extends Validator<dynamic> {
  final T value;
  final String validationMessage;

  const NotEqualsValidator(
    this.value, {
    this.validationMessage = "Must be different",
  }) : super();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    return control.value != value
        ? null
        : <String, dynamic>{
            validationMessage: <String, dynamic>{
              'required': value,
              'actual': control.value,
            }
          };
  }
}
