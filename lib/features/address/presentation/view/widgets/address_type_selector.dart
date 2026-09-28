import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../../../config/app_color.dart';
import '../../../../../config/app_font.dart';
import '../../managers/address_provider.dart';

class AddressTypeSelectorWidget extends StatelessWidget {
  const AddressTypeSelectorWidget({
    super.key,
    required this.type,
    required this.icon,
  });

  final AddressType type;
  final IconData icon;

  String get _label {
    switch (type) {
      case AddressType.home:
        return 'Home';
      case AddressType.work:
        return 'Work';
      case AddressType.apartment:
        return 'Apartment';
    }
  }

  String get _displayLabel {
    switch (type) {
      case AddressType.home:
        return 'Home label'.tr;
      case AddressType.work:
        return 'Work label'.tr;
      case AddressType.apartment:
        return 'Apartment'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveFormConsumer(builder: (context, form, _) {
      final current = form.control('label').value?.toString() ?? '';
      final isSelected = current.toLowerCase() == _label.toLowerCase();
      return ChoiceChip(
        backgroundColor: AppColor.primary.withAlpha(50),
        selectedColor: AppColor.primary.withAlpha(180),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? AppColor.primary : Colors.grey.shade300,
            width: 1,
          ),
        ),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const Gap(4),
            Text(
              _displayLabel,
              style: AppFont.font14W500Black.copyWith(
                color: isSelected ? Colors.white : AppColor.textDark,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => form.control('label').value = _label,
      );
    });
  }
}
