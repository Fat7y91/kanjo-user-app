import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/notification_entity.dart';

class NotificationContainer extends StatelessWidget {
  const NotificationContainer({
    super.key,
    required this.notificationEntity,
    required this.index,
    required this.onTap,
  });

  final NotificationEntity notificationEntity;
  final int index;
  final VoidCallback onTap;

  static IconData _iconForType(String type) {
    final t = type.toLowerCase();
    if (t.startsWith('service_order')) {
      return Icons.handyman_rounded;
    }
    if (t.startsWith('order')) {
      return Icons.receipt_long_rounded;
    }
    if (t.contains('chat')) {
      return Icons.chat_bubble_outline_rounded;
    }
    if (t.contains('cart')) {
      return Icons.shopping_cart_outlined;
    }
    return Icons.notifications_none_rounded;
  }

  String _relativeTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now'.tr;
    if (diff.inMinutes < 60) {
      return '@count min ago'.trParams({'count': '${diff.inMinutes}'});
    }
    if (diff.inHours < 24) {
      return '@count h ago'.trParams({'count': '${diff.inHours}'});
    }
    if (diff.inDays < 7) {
      return '@count d ago'.trParams({'count': '${diff.inDays}'});
    }
    return DateFormat.MMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notificationEntity.isRead;
    final staggerMs = 40 + (index.clamp(0, 10) * 45);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + staggerMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: Transform.scale(
              scale: 0.97 + (0.03 * value),
              child: child,
            ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashFactory: InkRipple.splashFactory,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: unread
                    ? AppColor.black.withAlpha(40)
                    : AppColor.grey1.withAlpha(140),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _iconForType(notificationEntity.type),
                      size: 20,
                      color: AppColor.grey2,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notificationEntity.title,
                                style: AppFont.font14W700Black.copyWith(
                                  fontWeight: unread
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (unread)
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.6, end: 1),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeInOut,
                                builder: (context, pulse, child) {
                                  return Opacity(
                                    opacity: 0.55 + (0.45 * pulse),
                                    child: Transform.scale(
                                      scale: 0.85 + (0.15 * pulse),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: AppColor.black.withAlpha(180),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          notificationEntity.message,
                          style: AppFont.font12w400Black.copyWith(
                            color: AppColor.grey2,
                            height: 1.35,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          _relativeTime(notificationEntity.createdAt),
                          style: AppFont.font10w400Black.copyWith(
                            color: AppColor.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
