import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/image_picker_cropper.dart';
import 'package:heraj/features/auth/presentation/managers/auth_provuder.dart';
import 'package:heraj/features/auth/presentation/managers/register_actions_mixin.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/gender_selector.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../config/app_font.dart';
import '../../../../../helper/phone_validation_mixin.dart';
import '../../../../../ui/shared_widgets/custom_reactive_form_consumer.dart';
import '../../../../../ui/shared_widgets/custom_text_field.dart';
import 'login_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with PhoneValidationMixin, RegisterActionsMixin {
  @override
  late final FormGroup formGroup;
  final FocusNode phoneNode = FocusNode();
  final profileImageNotifier = ValueNotifier<File?>(null);

  static const _contentWidth = 350.0;

  @override
  void initState() {
    super.initState();
    formGroup = FormGroup({
      'name': FormControl<String>(validators: [Validators.required]),
      'email': FormControl<String>(
        validators: [Validators.required, Validators.email],
      ),
      'country_code': FormControl<String>(
        value: '+20',
        validators: [Validators.required],
      ),
      'phone': FormControl<String>(validators: [Validators.required]),
      'gender': FormControl<String>(validators: [Validators.required]),
      'password': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)],
      ),
      'password_confirmation': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)],
      ),
      'profile_image': FormControl<File>(),
    }, validators: [
      Validators.mustMatch('password', 'password_confirmation'),
    ]);

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
    profileImageNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final imagePicker = getIt<ImagePickerService>();
    final file = await imagePicker.pickImage(crop: true);
    if (file != null) {
      formGroup.control('profile_image').updateValue(file);
      profileImageNotifier.value = file;
    }
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
                top: 40,
                start: 20,
                end: 20,
                bottom: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _contentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create account'.tr,
                      textAlign: TextAlign.center,
                      style: AppFont.font24w600Black.copyWith(
                        color: AppColor.primary,
                      ),
                    ),
                    const Gap(24),
                    Center(
                      child: InkWell(
                        onTap: _pickProfileImage,
                        borderRadius: BorderRadius.circular(50),
                        child: ValueListenableBuilder<File?>(
                          valueListenable: profileImageNotifier,
                          builder: (context, file, _) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColor.lightBorder,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: file != null
                                        ? Image.file(
                                            file,
                                            fit: BoxFit.fill,
                                          )
                                        : const Icon(
                                            Icons.person_outline,
                                            size: 36,
                                            color: AppColor.textGrey,
                                          ),
                                  ),
                                ),
                                PositionedDirectional(
                                  end: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: AppColor.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Profile image'.tr,
                      textAlign: TextAlign.center,
                      style: AppFont.font14W500Black.copyWith(
                        color: AppColor.textGrey,
                      ),
                    ),
                    const Gap(20),
                    Text(
                      'Name'.tr,
                      style: AppFont.font16W600Black,
                    ),
                    const Gap(8),
                    CustomTextField<String>(
                      formControlName: 'name',
                      hintText: 'Full name'.tr,
                      radius: 30,
                      borderWidth: 1,
                      enabledBorderColor: AppColor.lightBorder,
                      focusedBorderColor: AppColor.lightBorder,
                    ),
                    const Gap(16),
                    Text(
                      'Email Address'.tr,
                      style: AppFont.font16W600Black,
                    ),
                    const Gap(8),
                    CustomTextField<String>(
                      formControlName: 'email',
                      hintText: 'Email Address'.tr,
                      inputType: TextInputType.emailAddress,
                      radius: 30,
                      borderWidth: 1,
                      enabledBorderColor: AppColor.lightBorder,
                      focusedBorderColor: AppColor.lightBorder,
                    ),
                    const Gap(16),
                    Text(
                      'Phone number'.tr,
                      style: AppFont.font16W600Black,
                    ),
                    const Gap(8),
                    CustomTextField<String>(
                      formControlName: 'phone',
                      hintText: '01xxxxxxxxx',
                      inputType: TextInputType.phone,
                      inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                      focusNode: phoneNode,
                      radius: 30,
                      borderWidth: 1,
                      enabledBorderColor: AppColor.lightBorder,
                      focusedBorderColor: AppColor.lightBorder,
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
                    ),
                    const Gap(16),
                    const GenderSelector(),
                    const Gap(16),
                    Text(
                      'Password'.tr,
                      style: AppFont.font16W600Black,
                    ),
                    const Gap(8),
                    Consumer(
                      builder: (context, ref, _) {
                        final obscure =
                            ref.watch(securePasswordProvider('register'));
                        return CustomTextField<String>(
                          formControlName: 'password',
                          hintText: 'Password'.tr,
                          obscure: obscure,
                          radius: 30,
                          borderWidth: 1,
                          enabledBorderColor: AppColor.lightBorder,
                          focusedBorderColor: AppColor.lightBorder,
                          iconButton: IconButton(
                            onPressed: () {
                              ref
                                  .read(securePasswordProvider('register')
                                      .notifier)
                                  .state = !obscure;
                            },
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppColor.textGrey,
                            ),
                          ),
                        );
                      },
                    ),
                    const Gap(16),
                    Text(
                      'Confirm password'.tr,
                      style: AppFont.font16W600Black,
                    ),
                    const Gap(8),
                    Consumer(
                      builder: (context, ref, _) {
                        final obscure = ref
                            .watch(securePasswordProvider('register_confirm'));
                        return CustomTextField<String>(
                          formControlName: 'password_confirmation',
                          hintText: 'Confirm password'.tr,
                          obscure: obscure,
                          radius: 30,
                          borderWidth: 1,
                          enabledBorderColor: AppColor.lightBorder,
                          focusedBorderColor: AppColor.lightBorder,
                          iconButton: IconButton(
                            onPressed: () {
                              ref
                                  .read(securePasswordProvider(
                                          'register_confirm')
                                      .notifier)
                                  .state = !obscure;
                            },
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppColor.textGrey,
                            ),
                          ),
                        );
                      },
                    ),
                    const Gap(28),
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
                              text: 'Sign Up'.tr,
                              textSize: 16,
                              height: 54,
                              radius: 30,
                              gradient: AppColor.defaultPrimaryGradient,
                              fontColor: Colors.white,
                              onPressed: onRegisterPressed,
                            );
                          },
                        );
                      },
                    ),
                    const Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? '.tr,
                          style: AppFont.font14W500Black.copyWith(
                            color: AppColor.textGrey,
                          ),
                        ),
                        InkWell(
                          onTap: goToLogin,
                          child: Text(
                            'Login'.tr,
                            style: AppFont.font14W600Black.copyWith(
                              color: AppColor.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.primary,
                            ),
                          ),
                        ),
                      ],
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
