import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Male / female selector bound to a reactive form `gender` control.
/// Values stored as `male` / `female`.
class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    this.formControlName = 'gender',
  });

  final String formControlName;

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<String>(
      formControlName: formControlName,
      builder: (context, control, _) {
        final selected = normalizeGender(control.value);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gender'.tr, style: AppFont.font16W600Black),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: _GenderOption(
                    label: 'Male'.tr,
                    icon: Icons.male_rounded,
                    selected: selected == 'male',
                    onTap: () => control.updateValue('male'),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _GenderOption(
                    label: 'Female'.tr,
                    icon: Icons.female_rounded,
                    selected: selected == 'female',
                    onTap: () => control.updateValue('female'),
                  ),
                ),
              ],
            ),
            if (control.invalid && control.touched) ...[
              const Gap(6),
              Text(
                'Gender is required'.tr,
                style: AppFont.font12w400Black.copyWith(
                  color: AppColor.danger,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? AppColor.defaultPrimaryGradient : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected ? Colors.transparent : AppColor.lightBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : AppColor.textGrey,
              ),
              const Gap(6),
              Text(
                label,
                style: selected
                    ? AppFont.font14W600White
                    : AppFont.font14W500Black.copyWith(
                        color: AppColor.textGrey,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? normalizeGender(String? value) {
  if (value == null) return null;
  final normalized = value.trim().toLowerCase();
  if (normalized == 'male' || normalized == 'm') return 'male';
  if (normalized == 'female' || normalized == 'f') return 'female';
  return null;
}
