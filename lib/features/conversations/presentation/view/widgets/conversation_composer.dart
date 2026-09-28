import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class ConversationComposer extends StatelessWidget {
  const ConversationComposer({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.onAttach,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColor.cartCardBorder,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    style: AppFont.font14W500Black,
                    decoration: InputDecoration(
                      hintText: 'Pharmacy chat input hint'.tr,
                      hintStyle: AppFont.hintTextField.copyWith(fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: isSending ? null : onAttach,
                  visualDensity: VisualDensity.compact,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: Icon(
                    Icons.attach_file,
                    color: AppColor.textGrey,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(8),
        Material(
          color: AppColor.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: isSending ? null : onSend,
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: LoadingWidget(size: 16, color: Colors.white),
                    )
                  : SvgPicture.asset(
                      AppAssets.paperPlane,
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        AppColor.onAccentSurface,
                        BlendMode.srcIn,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
