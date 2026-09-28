import 'package:reactive_forms/reactive_forms.dart';

class DoubleValidator extends Validator<dynamic> {
  static final RegExp numberRegex = RegExp(r'^-?[0-9]+(\.[0-9]+)?$');

  const DoubleValidator() : super();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    return (control.value == null) ||
            !numberRegex.hasMatch(control.value.toString())
        ? <String, dynamic>{ValidationMessage.number: true}
        : null;
  }
}
