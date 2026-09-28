import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/auth/presentation/managers/auth_provuder.dart';
import 'package:heraj/features/auth/presentation/managers/reset_password_actions_mixin.dart';
import 'package:heraj/features/auth/presentation/view/login_page.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_otp.dart';
import 'package:heraj/ui/shared_widgets/custom_reactive_form_consumer.dart';
import 'package:heraj/ui/shared_widgets/custom_text_field.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage>
    with ResetPasswordActionsMixin {
  @override
  late final FormGroup formGroup;

  @override
  String get phone => widget.phone;

  final TextEditingController _otpController = TextEditingController();

  static const _contentWidth = 350.0;

  @override
  void initState() {
    super.initState();
    formGroup = FormGroup(
      {
        'otp_code': FormControl<String>(
          validators: [
            Validators.required,
            Validators.minLength(6),
            Validators.maxLength(6),
          ],
        ),
        'password': FormControl<String>(
          validators: [Validators.required, Validators.minLength(6)],
        ),
        'password_confirmation': FormControl<String>(
          validators: [Validators.required, Validators.minLength(6)],
        ),
      },
      validators: [
        Validators.mustMatch('password', 'password_confirmation'),
      ],
    );
  }

  @override
  void dispose() {
    formGroup.dispose();
    _otpController.dispose();
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
                      'Reset password'.tr,
                      style: AppFont.font16W600Black.copyWith(
                        color: AppColor.textDark,
                        fontSize: 22,
                        height: 1.2,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Enter the code sent to your phone and choose a new password'
                          .tr,
                      style: AppFont.font14W500Black.copyWith(
                        color: AppColor.textGrey,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      phone,
                      textDirection: TextDirection.ltr,
                      style: AppFont.font14W600Black.copyWith(
                        color: AppColor.primary,
                      ),
                    ),
                    const Gap(24),
                    Text(
                      'OTP'.tr,
                      style: AppFont.font16W600Black.copyWith(
                        color: AppColor.textDark,
                        height: 1.2,
                      ),
                    ),
                    const Gap(8),
                    CustomOTP(
                      controller: _otpController,
                      onChanged: (value) {
                        formGroup.control('otp_code').updateValue(value);
                      },
                    ),
                    const Gap(8),
                    Text(
                      'New password'.tr,
                      style: AppFont.font16W600Black.copyWith(
                        color: AppColor.textDark,
                        height: 1.2,
                      ),
                    ),
                    const Gap(8),
                    Consumer(
                      builder: (context, ref, _) {
                        final obscure =
                            ref.watch(securePasswordProvider('reset'));
                        return CustomTextField<String>(
                          formControlName: 'password',
                          hintText: 'New password'.tr,
                          obscure: obscure,
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
                                  .read(securePasswordProvider('reset').notifier)
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
                    const Gap(20),
                    Text(
                      'Confirm password'.tr,
                      style: AppFont.font16W600Black.copyWith(
                        color: AppColor.textDark,
                        height: 1.2,
                      ),
                    ),
                    const Gap(8),
                    Consumer(
                      builder: (context, ref, _) {
                        final obscure =
                            ref.watch(securePasswordProvider('reset_confirm'));
                        return CustomTextField<String>(
                          formControlName: 'password_confirmation',
                          hintText: 'Confirm password'.tr,
                          obscure: obscure,
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
                                      .read(securePasswordProvider(
                                              'reset_confirm')
                                          .notifier)
                                      .state =
                                  !obscure;
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
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: InkWell(
                        onTap: onResendResetCode,
                        child: Text(
                          'Resend'.tr,
                          style: AppFont.font14W600Black.copyWith(
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                    ),
                    const Gap(24),
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
                              text: 'Reset password'.tr,
                              textSize: 16,
                              height: 54,
                              radius: 30,
                              gradient: AppColor.defaultPrimaryGradient,
                              fontColor: Colors.white,
                              onPressed: onResetPasswordPressed,
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
