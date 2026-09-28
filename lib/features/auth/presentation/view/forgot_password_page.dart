import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/auth/presentation/managers/auth_provuder.dart';
import 'package:heraj/features/auth/presentation/managers/forgot_password_actions_mixin.dart';
import 'package:heraj/helper/phone_validation_mixin.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_reactive_form_consumer.dart';
import 'package:heraj/ui/shared_widgets/custom_text_field.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage>
    with PhoneValidationMixin, ForgotPasswordActionsMixin {
  @override
  late final FormGroup formGroup;

  final FocusNode phoneNode = FocusNode();

  static const _contentWidth = 350.0;

  @override
  void initState() {
    super.initState();
    formGroup = FormGroup({
      'country_code': FormControl<String>(
        value: '+20',
        validators: [Validators.required],
      ),
      'phone': FormControl<String>(
        validators: [Validators.required],
      ),
    });

    formGroup.control('phone').setValidators([
      Validators.required,
      Validators.minLength(getPhoneLengthForCountryCode(
          formGroup.control('country_code').value)!),
      Validators.maxLength(getPhoneLengthForCountryCode(
          formGroup.control('country_code').value)!),
    ]);

    formGroup.control('country_code').valueChanges.listen((_) {
      final length = getPhoneLengthForCountryCode(
          formGroup.control('country_code').value);
      formGroup.control('phone').setValidators([
        Validators.required,
        if (length != null) Validators.minLength(length),
        if (length != null) Validators.maxLength(length),
      ]);
      formGroup.control('phone').updateValueAndValidity();
    });
  }

  @override
  void dispose() {
    formGroup.dispose();
    phoneNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ReactiveForm(
          formGroup: formGroup,
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.only(
                top: 12,
                start: 20,
                end: 20,
                bottom: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _contentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: BackButton(color: AppColor.textDark),
                    ),
                    const Gap(16),
                    Text(
                      'Forgot password?'.tr,
                      style: AppFont.font16W600Black.copyWith(
                        color: AppColor.textDark,
                        fontSize: 22,
                        height: 1.2,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Enter your phone number to reset your password'.tr,
                      style: AppFont.font14W500Black.copyWith(
                        color: AppColor.textGrey,
                      ),
                    ),
                    const Gap(24),
                    Text(
                      'Phone number'.tr,
                      style: AppFont.font16W600Black.copyWith(
                        color: AppColor.textDark,
                        height: 1.2,
                      ),
                    ),
                    const Gap(8),
                    CustomTextField<String>(
                      formControlName: 'phone',
                      hintText: '10xxxxxxxxx',
                      inputType: TextInputType.phone,
                      inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                      focusNode: phoneNode,
                      radius: 30,
                      borderWidth: 1,
                      enabledBorderColor: AppColor.lightBorder,
                      focusedBorderColor: AppColor.lightBorder,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      hintStyle: AppFont.font16W500Black.copyWith(
                        color: AppColor.textGrey,
                      ),
                      iconDataPrefix: ReactiveValueListenableBuilder<String>(
                        formControlName: 'country_code',
                        builder: (context, countryCodeControl, child) {
                          final phoneCode =
                              ((countryCodeControl.value?.trim().isNotEmpty ??
                                          false)
                                      ? countryCodeControl.value!.trim()
                                      : '+20')
                                  .replaceAll(' ', '');
                          final normalizedCode = phoneCode.startsWith('+')
                              ? phoneCode
                              : '+$phoneCode';
                          final country =
                              getCountryFromPhoneCode(normalizedCode);

                          return Padding(
                            padding:
                                const EdgeInsetsDirectional.only(start: 10),
                            child: InkWell(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  onSelect: (Country selectedCountry) {
                                    formGroup
                                        .control('country_code')
                                        .updateValue(
                                          '+${selectedCountry.phoneCode}',
                                          emitEvent: true,
                                        );
                                  },
                                  countryListTheme: CountryListThemeData(
                                    flagSize: 24,
                                    backgroundColor: Colors.white,
                                    textStyle: AppFont.font14W500Black,
                                    inputDecoration: InputDecoration(
                                      labelText: 'Search'.tr,
                                      hintText: 'Start typing to search'.tr,
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColor.grey1,
                                        ),
                                      ),
                                    ),
                                    searchTextStyle: AppFont.font14W500Black,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsetsDirectional.symmetric(
                                    horizontal: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      country.flagEmoji,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      normalizedCode,
                                      style: AppFont.font14W500Black,
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: AppColor.textGrey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      iconButton: const Padding(
                        padding: EdgeInsetsDirectional.only(end: 12),
                        child: Icon(
                          Icons.phone,
                          size: 20,
                          color: AppColor.textGrey,
                        ),
                      ),
                    ),
                    const Gap(32),
                    CustomReactiveFormValidationConsumer(
                      formGroup: formGroup,
                      builder: (context, _, child) {
                        return Consumer(
                          builder: (context, ref, child) {
                            final isLoading = ref.watch(authNotifierProvider);
                            return CustomFilledButton(
                              isLoading: isLoading,
                              isValid: formGroup.valid,
                              ignorePressOnNotValid: true,
                              text: 'Continue'.tr,
                              textSize: 16,
                              height: 54,
                              radius: 30,
                              gradient: AppColor.defaultPrimaryGradient,
                              fontColor: Colors.white,
                              onPressed: onContinuePressed,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
