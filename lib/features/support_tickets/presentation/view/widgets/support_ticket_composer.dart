import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class SupportTicketComposer extends StatelessWidget {
  const SupportTicketComposer({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Write a reply'.tr,
                hintStyle: AppFont.hintTextField,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const Gap(10),
        Material(
          color: AppColor.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: isSending ? null : onSend,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: isSending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: LoadingWidget(size: 18, color: Colors.white),
                    )
                  : SvgPicture.asset(
                      AppAssets.paperPlane,
                      width: 22,
                      height: 22,
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
