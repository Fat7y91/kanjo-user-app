import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';

import '../../managers/notifications_filter.dart';

class NotificationsCustomActionChip extends ConsumerWidget {
  const NotificationsCustomActionChip({
    super.key,
    required this.value,
    this.alwaysActive = false,
  });

  final NotificationFilterType value;
  final bool alwaysActive;

  String get _label {
    switch (value) {
      case NotificationFilterType.all:
        return 'All'.tr;
      case NotificationFilterType.seen:
        return 'Read'.tr;
      case NotificationFilterType.unseen:
        return 'Unread'.tr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected =
        alwaysActive || ref.watch(notificationsProvider)['status'] == value.key;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: ActionChip(
        onPressed: () {
          ref.read(notificationsProvider.notifier).updateStatus(value);
        },
        side: BorderSide(
          color: isSelected
              ? AppColor.black.withAlpha(200)
              : AppColor.grey1.withAlpha(160),
        ),
        label: Text(
          _label,
          style: AppFont.labelTextField.copyWith(
            color: isSelected ? AppColor.black : AppColor.grey2,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        backgroundColor:
            isSelected ? AppColor.white : const Color(0xFFF2F2F2),
      ),
    );
  }
}
