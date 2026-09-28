import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../config/app_color.dart';

class GenderPicker extends StatelessWidget {
  const GenderPicker({
    super.key,
    required this.onChanged,
    required this.isMale,
  });

  final bool isMale;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              onChanged.call(0);
            },
            child: GenderTile(
              title: 'Male'.tr,
              isSelected: isMale,
            ),
          ),
        ),
        const Gap(10),
        Expanded(
          child: InkWell(
            onTap: () {
              onChanged.call(1);
            },
            child: GenderTile(
              title: 'Female'.tr,
              isSelected: !isMale,
            ),
          ),
        ),
      ],
    );
  }
}

class GenderTile extends StatelessWidget {
  const GenderTile({
    super.key,
    required this.title,
    required this.isSelected,
  });

  final String title;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.primary)),
      child: Center(
          child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColor.primary,
        ),
      )),
    );
  }
}
