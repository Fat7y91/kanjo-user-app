import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/auth_service.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_outlined_button.dart';
import 'package:country_picker/country_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../config/app_font.dart';
import '../../../../../helper/phone_validation_mixin.dart';
import '../../../../../ui/shared_widgets/custom_reactive_form_consumer.dart';
import '../../../../../ui/shared_widgets/custom_text_field.dart';
import '../managers/auth_provuder.dart';
import '../managers/login_actions_mixin.dart';

final securePasswordProvider =
    StateProvider.family.autoDispose<bool, dynamic>((ref, _) => true);

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with PhoneValidationMixin, LoginActionsMixin {
  @override
  late final FormGroup formGroup;
  final FocusNode phoneNode = FocusNode();
  final FocusNode passwordNode = FocusNode();

  static const _contentWidth = 350.0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dataManager.getFingerprintEnabled() &&
          ref.read(userProvider)?.id != null) {
        authenticateWithFingerprint();
      }
    });

    formGroup = FormGroup({
      'country_code': FormControl<String>(
        value: '+20',
        validators: [Validators.required],
      ),
      'phone': FormControl<String>(
        validators: [Validators.required],
      ),
      'password': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)],
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

    super.initState();
  }

  @override
  void dispose() {
    formGroup.dispose();
    phoneNode.dispose();
    passwordNode.dispose();
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
                top: 86,
                start: 20,
                end: 20,
                bottom: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _contentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        AppAssets.logoOnly,
                        width: 110.37,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Gap(40),
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
                    const Gap(20),
                    Text(
                      'Password'.tr,
                      style: AppFont.font16W600Black.copyWith(
                        color: AppColor.textDark,
                        height: 1.2,
                      ),
                    ),
                    const Gap(8),
                    Consumer(
                      builder: (context, ref, _) {
                        final obscure =
                            ref.watch(securePasswordProvider('login'));
                        return CustomTextField<String>(
                          formControlName: 'password',
                          hintText: 'Password'.tr,
                          obscure: obscure,
                          focusNode: passwordNode,
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
                          iconButton: IconButton(
                            onPressed: () {
                              ref
                                  .read(securePasswordProvider('login').notifier)
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
                    const Gap(12),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: InkWell(
                        onTap: onForgotPasswordPressed,
                        child: Text(
                          'Forgot password?'.tr,
                          style: AppFont.font14W600Black.copyWith(
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
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
                              text: 'Login'.tr,
                              textSize: 16,
                              height: 54,
                              radius: 30,
                              gradient: AppColor.defaultPrimaryGradient,
                              fontColor: Colors.white,
                              onPressed: onLoginPressed,
                            );
                          },
                        );
                      },
                    ),
                    const Gap(24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ".tr,
                          style: AppFont.font14W500Black.copyWith(
                            color: AppColor.textGrey,
                          ),
                        ),
                        InkWell(
                          onTap: goToRegister,
                          child: Text(
                            'Sign Up'.tr,
                            style: AppFont.font14W600Black.copyWith(
                              color: AppColor.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    TextButton(
                      onPressed: continueAsGuest,
                      child: Text('Continue as guest'.tr,style: AppFont.font16W700Primary.copyWith(decoration: TextDecoration.underline),),
                    ),
                    if (dataManager.getFingerprintEnabled() &&
                        ref.watch(userProvider)?.id != null) ...[
                      const Gap(32),
                      InkWell(
                        onTap: authenticateWithFingerprint,
                        child: Center(
                          child: SvgPicture.asset(
                            AppAssets.eye,
                            width: 48,
                            height: 48,
                          ),
                        ),
                      ),
                    ],
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
