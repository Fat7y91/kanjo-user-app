import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:heraj/helper/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../config/app_font.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../ui/shared_widgets/container_button.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';
import '../../../../../ui/shared_widgets/custom_logo_app_bar.dart';
import '../../../../../ui/shared_widgets/custom_reactive_form_consumer.dart';
import '../../../../../ui/shared_widgets/custom_text_field.dart';
import '../../../../../ui/shared_widgets/image_or_svg.dart';
import '../../../../../ui/shared_widgets/select_language_tile.dart';
import '../../../../../ui/shared_widgets/toggle_show_password_icon.dart';
import '../../../../../ui/ui.dart';
import '../../../auth/presentation/view/login_page.dart';
import '../../../verify/presentation/manager/verify_provider.dart';
import '../../domain/repositories/forget_password_repo.dart';
import '../manager/forget_password_provider.dart';

class ResetPasswordView extends ConsumerStatefulWidget {
  const ResetPasswordView(this.forgetRepo, {super.key});

  final ForgetPasswordRepo forgetRepo;

  @override
  ConsumerState<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends ConsumerState<ResetPasswordView> {
  final form = FormGroup({
    'password': FormControl<String>(
      validators: [
        Validators.required,
        Validators.minLength(1),
        Validators.maxLength(20),
      ],
    ),
    'confirmPassword': FormControl<String>(
      validators: [
        Validators.required,
        Validators.minLength(1),
        Validators.maxLength(20),
      ],
    ),
  }, validators: [
    Validators.mustMatch('password', 'confirmPassword'),
  ]);
  final securePasswordProvider =
      StateProvider.autoDispose.family<bool, String>((ref, form) {
    return true;
  });

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateProvider = ref.watch(forgetPasswordProvider(widget.forgetRepo));
    final notifier =
        ref.watch(forgetPasswordProvider(widget.forgetRepo).notifier);
    ref.listen(forgetPasswordProvider(widget.forgetRepo), (previous, next) {
      if (next is ErrorState) {
        UIHelper.showSnackBar(next.message, context);
      } else if (next is CloseState) {
        Future asdsa() async {
          if (next.message != null) {
            await UIHelper.showAlert(
              next.message!,
              context: context,
              type: next.isSuccess! ? DialogType.success : DialogType.error,
            );
          }

          if (next.isSuccess == true) {
            Get.offAll(() => const LoginPage());
          } else {
            Get.back();
          }
        }

        asdsa();
      }
    });

    responsiveInit(context);
    return Scaffold(
      appBar: CustomLogoAppbar(
        customTitleWidget: ImageOrSvg(
          AppAssets.logo,
          isLocal: true,
          height: 65.h,
        ),
        isCenterTitle: false,
        hideBackButton: true,
        buttonWidget: const Padding(
          padding: EdgeInsets.only(bottom: 18, top: 2),
          child: SelectLanguageTile(),
        ),
      ),
      body: ReactiveForm(
        formGroup: form,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Gap(20.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Gap(24.h),
                  Row(
                    children: [
                      ContainerButton(
                        size: 40,
                        onTap: () => Get.back(),
                        icon: Icons.arrow_back,
                        color: Colors.transparent,
                      ),
                      Gap(8.w),
                      Text(
                        "retrieve your account".tr,
                        style: AppFont.font20W700Black,
                      ),
                    ],
                  ),
                  Gap(16.h),
                  Consumer(
                    builder: (context, ref, child) {
                      return CustomTextField(
                        formControlName: 'password',
                        labelText: "new password".tr,
                        hintText: "********",
                        obscure: ref.watch(securePasswordProvider("password")),
                        iconButton: ToggleShowPasswordButton(
                          onTap: () {
                            ref
                                    .read(securePasswordProvider("password")
                                        .notifier)
                                    .state =
                                !ref.read(securePasswordProvider("password"));
                          },
                          showPass:
                              ref.watch(securePasswordProvider("password")),
                        ),
                      );
                    },
                  ),
                  Gap(20.h),
                  Consumer(
                    builder: (context, ref, child) {
                      return CustomTextField(
                        obscure: ref
                            .watch(securePasswordProvider("confirmPassword")),
                        iconButton: ToggleShowPasswordButton(
                          onTap: () {
                            ref
                                    .read(securePasswordProvider(
                                            "confirmPassword")
                                        .notifier)
                                    .state =
                                !ref.read(
                                    securePasswordProvider("confirmPassword"));
                          },
                          showPass: ref
                              .watch(securePasswordProvider("confirmPassword")),
                        ),
                        formControlName: 'confirmPassword',
                        labelText: "confirm new password".tr,
                        hintText: "********",
                      );
                    },
                  ),
                ],
              ),
            ),
            Gap(32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 26.w),
              child: CustomReactiveFormValidationConsumer(
                builder: (context, form, child) {
                  return CustomFilledButton(
                    isLoading: stateProvider is LoadingState,
                    text: "done".tr,
                    isValid: form.valid,
                    onPressed: () {
                      if (form.valid) {
                        notifier.reset(form.control('password').value);
                      } else {
                        form.markAllAsTouched();
                      }
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
