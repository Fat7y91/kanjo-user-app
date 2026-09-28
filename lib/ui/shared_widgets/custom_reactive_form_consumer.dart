import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../helper/responsive.dart';

class CustomReactiveFormConsumer extends StatelessWidget {
  final Widget? child;
  final ReactiveFormConsumerBuilder builder;
  final bool listen;

  const CustomReactiveFormConsumer({
    super.key,
    required this.builder,
    this.child,
    this.listen = true,
  });

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    final form = ReactiveForm.of(context, listen: listen);
    if (form is! FormGroup) {
      throw FormControlParentNotFoundException(this);
    }
    return builder(context, form, child);
  }
}

typedef ReactiveConsumerBuilder = Widget Function(
    BuildContext context, AbstractControl<dynamic> control, Widget? child);

class CustomReactiveFormValidationConsumer extends StatelessWidget {
  final Widget? child;
  final FormGroup? formGroup;
  final ReactiveFormConsumerBuilder builder;

  const CustomReactiveFormValidationConsumer({
    super.key,
    required this.builder,
    this.formGroup,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    final form = formGroup ?? ReactiveForm.of(context, listen: false);
    if (form is! FormGroup) {
      throw FormControlParentNotFoundException(this);
    }
    return StreamBuilder<ControlStatus>(
        stream: form.statusChanged.distinct(),
        initialData: form.status,
        builder: (context, snapshot) {
          return builder(context, form, child);
        });
  }
}

class CustomReactiveControlValidationConsumer extends StatelessWidget {
  final Widget? child;
  final ReactiveConsumerBuilder builder;
  final AbstractControl<dynamic> control;

  const CustomReactiveControlValidationConsumer({
    super.key,
    required this.builder,
    required this.control,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    final form = control;
    return StreamBuilder<ControlStatus>(
        stream: form.statusChanged.distinct(),
        initialData: form.status,
        builder: (context, snapshot) {
          return builder(context, form, child);
        });
  }
}
