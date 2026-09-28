import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/support_tickets/data/models/support_ticket_model.dart';
import 'package:heraj/helper/format_date.dart';

class SupportTicketCard extends StatelessWidget {
  const SupportTicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  final SupportTicketModel ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(ticket.status);
    final dateText =
        ticket.createdAt == null ? '' : FormatDate.call(ticket.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.font14W700Black,
                    ),
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(28),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ticket.statusLabel.tr,
                      style: AppFont.font12W600White.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (ticket.description.trim().isNotEmpty) ...[
                const Gap(8),
                Text(
                  ticket.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.font12w500Grey2,
                ),
              ],
              const Gap(10),
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16,
                    color: AppColor.grey2,
                  ),
                  const Gap(4),
                  Text(
                    '@count messages'.trParams({
                      'count': '${ticket.messagesCount}',
                    }),
                    style: AppFont.font12w500Grey2,
                  ),
                  if (ticket.attachment != null &&
                      ticket.attachment!.trim().isNotEmpty) ...[
                    const Gap(12),
                    Icon(
                      Icons.attach_file_rounded,
                      size: 16,
                      color: AppColor.grey2,
                    ),
                  ],
                  const Spacer(),
                  if (dateText.isNotEmpty)
                    Text(
                      dateText,
                      style: AppFont.font12w500Grey2,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'answered':
      case 'open':
      case 'in_progress':
        return AppColor.primary;
      case 'closed':
      case 'resolved':
        return AppColor.grey2;
      default:
        return AppColor.guestOrange;
    }
  }
}
