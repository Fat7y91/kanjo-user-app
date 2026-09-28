import 'package:heraj/features/auth/presentation/managers/auth_provuder.dart';
import 'package:heraj/ui/shared_widgets/scaffold_back_ground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../config/app_font.dart';
import '../../../../../helper/responsive.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';
import '../../../../../ui/shared_widgets/custom_otp.dart';
import '../../../../../ui/shared_widgets/custom_outlined_button.dart';
import '../../../../../ui/ui.dart';
import '../../domain/repositories/verification_repo.dart';
import '../manager/verify_provider.dart';

final codeProvider = StateProvider.autoDispose<String?>((ref) {
  return null;
});

class VerifyView extends ConsumerWidget {
  const VerifyView({
    required this.repo,
    this.isLogin = false,
    super.key,
  });

  final VerificationRepo repo;
  final bool isLogin;

  @override
  Widget build(BuildContext context, ref) {
    responsiveInit(context);
    final stateProvider = ref.watch(verifyProvider(repo));
    final authProvider = ref.watch(authNotifierProvider.notifier);
    final notifier = ref.watch(verifyProvider(repo).notifier);
    ref.listen(verifyProvider(repo), (previous, next) {
      if (next is ErrorState) {
        UIHelper.showSnackBar(next.message, context);
      }
    });
    return ScaffoldBackGround(
        title: "Check phone number".tr,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Gap(28.h),
              Image.asset(
                "assets/base/security.png",
                height: 200,
                width: double.infinity,
              ),
              Row(
                children: [
                  Flexible(
                    child: RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: "we will send you otp message".tr,
                          style: AppFont.font13W400Black),
                      TextSpan(
                          text: "(${repo.sendTo})",
                          style: AppFont.font13W600Primary),
                    ])),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Verification code".tr,
                      style: AppFont.font13W400Black,
                    ),
                    Gap(6.h),
                    CustomOTP(
                        controller: notifier.textController,
                        onChanged: (val) {
                          ref.read(codeProvider.notifier).state = val;
                        }),
                  ],
                ),
              ),
              Gap(24.h),
              Consumer(
                builder: (context, ref, child) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 26.w),
                    child: CustomFilledButton(
                      text: "Verify".tr,
                      isLoading: stateProvider is LoadingState &&
                          stateProvider.key == "verify",
                      ignorePressOnNotValid: true,
                      onPressed: () {
                        if (isLogin) {
                          authProvider.login({
                            "code": ref.read(codeProvider)!,
                            "phone": repo.sendTo
                          });
                        } else {
                          authProvider.register({
                            "code": ref.read(codeProvider)!,
                            "email": repo.sendTo
                          });
                        }
                      },
                      isValid: ref.watch(codeProvider)?.length == 6,
                    ),
                  );
                },
              ),
              if (stateProvider is! LoadingState) ...[
                Gap(16.h),
                StreamBuilder(
                  stream: notifier.stopWatch.rawTime,
                  builder: (context, snapshot) {
                    final isLoading = notifier.stopWatch.isRunning;

                    return Consumer(
                      builder: (context, ref, child) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 26.w),
                          child: CustomOutlinedButton(
                            text: isLoading
                                ? "${notifier.stopWatch.secondTime.value}"
                                : "Resend".tr,
                            isLoading: stateProvider is LoadingState &&
                                stateProvider.key == "verify",
                            ignorePressOnNotValid: true,
                            onPressed: () {
                              notifier.resend();
                            },
                            isValid: !isLoading,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ));
  }
}
