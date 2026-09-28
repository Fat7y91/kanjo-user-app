import 'package:heraj/helper/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:heraj/ui/shared_widgets/scaffold_back_ground.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import '../../../../config/app_color.dart';
import '../../../../config/app_font.dart';
import '../../../../ui/shared_widgets/custom_filled_button.dart';
import '../../../root/view/root_view.dart';
import '../manager/fetch_policy_provider.dart';

class WhoAreWeScreen extends StatelessWidget {
  const WhoAreWeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldBackGround(
      title: "Who are we".tr,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom,
          left: 20,
          right: 20,
        ),
        child: CustomFilledButton(
          text: "Ok".tr,
          fontColor: Colors.white,
          color: AppColor.primary,
          onPressed: () => Get.back(),
        ),
      ),
      child: Consumer(
        builder: (context, ref, _) {
          final terms = ref.watch(fetchWhoAreWeProvider);
          return terms.customWhen(
            refreshable: fetchWhoAreWeProvider.future,
            ref: ref,
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: ShimmerEffect(
                enable: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < 6; i++) ...[
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECECEC),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECECEC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (termsData) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: MediaQuery.of(context).padding.bottom + 20),
                  child: HtmlWidget(
                    termsData.terms ?? "",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}