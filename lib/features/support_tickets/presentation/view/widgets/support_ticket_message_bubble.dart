import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/support_tickets/domain/entities/support_ticket_message_entity.dart';
import 'package:heraj/helper/format_date.dart';

class SupportTicketMessageBubble extends StatelessWidget {
  const SupportTicketMessageBubble({
    super.key,
    required this.message,
  });

  final SupportTicketMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final isCustomer = message.isCustomer;
    final timeText = message.createdAt == null
        ? ''
        : FormatDate.call(message.createdAt, addJm: true);

    return Align(
      alignment: isCustomer
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: isCustomer
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isCustomer ? AppColor.primary : AppColor.checkoutBorder,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isCustomer ? 4 : 16),
                  bottomRight: Radius.circular(isCustomer ? 16 : 4),
                ),
              ),
              child: Text(
                message.message,
                style: AppFont.font14W500Black.copyWith(
                  color: isCustomer ? AppColor.onAccentSurface : AppColor.textDark,
                ),
              ),
            ),
            if (timeText.isNotEmpty) ...[
              const Gap(4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  timeText,
                  style: AppFont.font12w400Black.copyWith(
                    color: AppColor.textGrey,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
