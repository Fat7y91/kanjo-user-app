import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_message_entity.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_outlined_button.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/ui.dart';

class ConversationVendorBubble extends StatelessWidget {
  const ConversationVendorBubble({
    super.key,
    required this.avatarUrl,
    required this.message,
    this.onAcceptQuote,
    this.onImageLoaded,
  });

  final String? avatarUrl;
  final ConversationMessageEntity message;
  final VoidCallback? onAcceptQuote;
  final VoidCallback? onImageLoaded;

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.75;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.checkoutBorder,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(3),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: ConversationMessageBody(
                    message: message,
                    isCustomer: false,
                    onAcceptQuote: onAcceptQuote,
                    onImageLoaded: onImageLoaded,
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(6),
        CircleAvatar(
          radius: 13,
          backgroundColor: AppColor.grey1,
          child: ClipOval(
            child: ImageOrSvg(
              avatarUrl,
              width: 26,
              height: 26,
              fit: BoxFit.cover,
              pickImageOnNull: true,
              assetImageOnNull: AppAssets.logoOnly,
            ),
          ),
        ),
      ],
    );
  }
}

class ConversationCustomerBubble extends StatelessWidget {
  const ConversationCustomerBubble({
    super.key,
    required this.message,
    required this.timeText,
    this.onImageLoaded,
  });

  final ConversationMessageEntity message;
  final String timeText;
  final VoidCallback? onImageLoaded;

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.75;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: ConversationMessageBody(
                  message: message,
                  isCustomer: true,
                  onImageLoaded: onImageLoaded,
                ),
              ),
            ),
          ),
        ),
        const Gap(2),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 6),
          child: Text(
            timeText,
            style: AppFont.font12w400Black.copyWith(
              color: AppColor.textGrey,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class ConversationMessageBody extends StatelessWidget {
  const ConversationMessageBody({
    super.key,
    required this.message,
    required this.isCustomer,
    this.onAcceptQuote,
    this.onImageLoaded,
  });

  final ConversationMessageEntity message;
  final bool isCustomer;
  final VoidCallback? onAcceptQuote;
  final VoidCallback? onImageLoaded;

  @override
  Widget build(BuildContext context) {
    final textStyle = isCustomer
        ? AppFont.font14W500White.copyWith(height: 1.3)
        : AppFont.font14W500Black.copyWith(height: 1.3);
    final imageUrl = message.imageUrl;

    if (message.isQuote) {
      return _QuoteCard(
        message: message,
        onAccept: message.isQuoteAccepted ? null : onAcceptQuote,
      );
    }

    return Column(
      crossAxisAlignment: imageUrl != null
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.4,
              ),
              child: ImageOrSvg(
                imageUrl,
                fit: BoxFit.contain,
                magnifier: true,
                isCircleLoading: false,
                pickImageOnNull: true,
                assetImageOnNull: AppAssets.logoOnly,
                onLoadCompleted: onImageLoaded,
              ),
            ),
          ),
          if (message.body.trim().isNotEmpty) const Gap(8),
        ],
        if (message.body.trim().isNotEmpty)
          Text(message.body, style: textStyle),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.message,
    this.onAccept,
  });

  final ConversationMessageEntity message;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    final amount = message.quoteAmount;
    final title = message.body.trim().isNotEmpty
        ? message.body
        : amount != null
            ? 'Add @amount EGP to the order'.trParams({
                'amount': amount % 1 == 0
                    ? amount.toStringAsFixed(0)
                    : amount.toStringAsFixed(2),
              })
            : 'Pharmacy chat order proposal'.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppFont.font14W500Black.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(8),
        if (message.isQuoteAccepted)
          Text(
            'Quote accepted'.tr,
            textAlign: TextAlign.center,
            style: AppFont.font12w400Black.copyWith(color: AppColor.green1),
          )
        else
          Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomFilledButton(
                      text: 'Pharmacy chat yes'.tr,
                      height: 36,
                      width: constraints.maxWidth,
                      padding: 0,
                      verticalPadding: 6,
                      onPressed: onAccept,
                    );
                  },
                ),
              ),
              const Gap(8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomOutlinedButton(
                      text: 'Pharmacy chat no'.tr,
                      height: 36,
                      width: constraints.maxWidth,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      onPressed: () =>
                          UIHelper.showGlobalSnackBar(text: 'Quote declined'.tr),
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}
