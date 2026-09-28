import 'package:heraj/helper/responsive.dart';
import 'package:heraj/ui/shared_widgets/scaffold_back_ground.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../config/app_font.dart';
import '../../../../../main.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';
import '../../../../../ui/shared_widgets/custom_reactive_form_consumer.dart';
import '../../../../../ui/shared_widgets/custom_text_field.dart';
import '../../../verify/domain/repositories/verification_repo.dart';
import '../../../verify/presentation/pages/verify_view.dart';

class ForgetPasswordView extends ConsumerStatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  ConsumerState<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends ConsumerState<ForgetPasswordView> {
  late final FormGroup formGroup;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    formGroup = FormGroup({
      'phone': FormControl(validators: [Validators.required,Validators.minLength(6)]),
    });
  }

  @override
  void dispose() {
    formGroup.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBackGround(
      title: "Forget password".tr,
      child: ReactiveForm(
        formGroup: formGroup,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Gap(32.h),
                Text("Did you forget your password".tr,style: AppFont.font20W600Black,),
                Gap(8.h),
                Text(
                  "please enter your number to send a verification code and retrieve your account data"
                      .tr,
                  style: AppFont.font12w500Grey2,
                ),
                Gap(32.h),
                CustomTextField(
                  formControlName: "phone",
                  hintText: "Phone number".tr,
                  inputType: TextInputType.number,
                  iconButton: Icon(Icons.phone,color: AppColor.black,),
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11)
                  ],
                ),
                // Row(
                //   children: [
                //     const CountyCodeContainer(),
                //     Gap(10.w),
                //     Expanded(
                //       child: CustomTextField(
                //         hintText: "000 000 000",
                //         inputType: TextInputType.number,
                //         control: phoneController,
                //         inputFormatter: [
                //           FilteringTextInputFormatter.digitsOnly,
                //           LengthLimitingTextInputFormatter(8)
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                Gap(48.h),
                CustomReactiveFormValidationConsumer(
                    formGroup: formGroup,
                    builder: (context, form, _) {
                      bool isValid = form.valid;
                      return CustomFilledButton(
                        text: 'next'.tr,
                        isValid: isValid,
                        onPressed: () {
                          Get.to(
                            () => VerifyView(
                              repo: getIt<VerificationRepo>(
                                instanceName: "forget",
                                param1: form.control("phone").value,
                              ),
                            ),
                          );
                        },
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
