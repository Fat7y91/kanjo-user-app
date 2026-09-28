import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/service_chats/domain/entities/service_conversation_entity.dart';
import 'package:heraj/helper/format_date.dart';

class ServiceConversationListTile extends StatelessWidget {
  const ServiceConversationListTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final ServiceConversationEntity conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = conversation.providerName.trim().isNotEmpty
        ? conversation.providerName.trim()[0].toUpperCase()
        : '?';
    final timeText = conversation.lastMessageAt == null ||
            conversation.lastMessageAt!.isEmpty
        ? ''
        : FormatDate.call(conversation.lastMessageAt, addJm: true);

    return Material(
      color: AppColor.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColor.primary.withAlpha(26),
                child: Text(
                  initial,
                  style: AppFont.font16W600Black.copyWith(
                    color: AppColor.primary,
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.font16W600Black,
                    ),
                    const Gap(4),
                    Text(
                      conversation.isOpen
                          ? 'Service chat active'.tr
                          : conversation.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.font12w400Black.copyWith(
                        color: AppColor.textBodySecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (timeText.isNotEmpty)
                    Text(
                      timeText,
                      style: AppFont.font12w400Black.copyWith(
                        color: AppColor.textGrey,
                      ),
                    ),
                  if (conversation.userHasUnread) ...[
                    const Gap(6),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColor.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
