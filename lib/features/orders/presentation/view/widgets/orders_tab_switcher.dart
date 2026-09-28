import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';

class OrdersTabSwitcher extends StatelessWidget {
  const OrdersTabSwitcher({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _TabItem(
              label: 'Orders'.tr,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
            _TabItem(
              label: 'Scheduled orders'.tr,
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
            _TabItem(
              label: 'Service bookings'.tr,
              selected: selectedIndex == 2,
              onTap: () => onChanged(2),
            ),
            _TabItem(
              label: 'Package shipments'.tr,
              selected: selectedIndex == 3,
              onTap: () => onChanged(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: selected ? AppColor.defaultPrimaryGradient : null,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: selected
              ? AppFont.font12W600White
              : AppFont.font12W600Black.copyWith(
                  color: const Color(0xFF808080),
                  fontWeight: FontWeight.w500,
                ),
        ),
      ),
    );
  }
}
