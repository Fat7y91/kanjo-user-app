import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_text_field.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// UI-only sheet: collect a bundle code and return it via [Navigator.pop].
class PutCartInBundleCodeSheet extends StatefulWidget {
  const PutCartInBundleCodeSheet({super.key});

  @override
  State<PutCartInBundleCodeSheet> createState() =>
      _PutCartInBundleCodeSheetState();
}

class _PutCartInBundleCodeSheetState extends State<PutCartInBundleCodeSheet> {
  late final FormGroup _formGroup;

  @override
  void initState() {
    super.initState();
    _formGroup = FormGroup({
      'code': FormControl<String>(
        value: '',
        validators: [Validators.required],
      ),
    });
  }

  @override
  void dispose() {
    _formGroup.dispose();
    super.dispose();
  }

  void _submit() {
    _formGroup.markAllAsTouched();
    if (!_formGroup.valid) return;
    final code = (_formGroup.control('code').value as String? ?? '').trim();
    if (code.isEmpty) return;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: ReactiveForm(
            formGroup: _formGroup,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColor.lightBorder,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'Add items to bundle'.tr,
                    style: AppFont.font18W700Black,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  Text(
                    'Enter the bundle code to add your cart items'.tr,
                    style: AppFont.font14W500Grey2,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(20),
                  CustomTextField<String>(
                    formControlName: 'code',
                    labelText: 'Bundle code'.tr,
                    hintText: 'Enter bundle code'.tr,
                    textInputAction: TextInputAction.done,
                    onEditDone: _submit,
                  ),
                  const Gap(16),
                  CustomFilledButton(
                    text: 'Put in bundle'.tr,
                    gradient: AppColor.defaultPrimaryGradient2,
                    radius: 18,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
