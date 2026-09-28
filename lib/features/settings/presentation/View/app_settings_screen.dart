import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/enum/language.dart';
import 'package:heraj/core/service/localization_service/localization_service.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/features/settings/presentation/manager/app_settings_actions_mixin.dart';
import 'package:heraj/features/settings/presentation/manager/app_settings_provider.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen>
    with AppSettingsActionsMixin {
  @override
  Widget build(BuildContext context) {
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final currentLanguage = localeService.getLocale();
    final hasToken = dataManager.getToken() != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColor.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Settings'.tr,
          style: AppFont.font18W700Black,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Preferences'.tr,
            style: AppFont.font20W700Black,
          ),
          const Gap(14),
          _SettingsCard(
            children: [
              _SettingsRow(
                icon: Icons.notifications_outlined,
                title: 'Enable notifications'.tr,
                trailing: CupertinoSwitch(
                  value: notificationsEnabled,
                  onChanged: toggleNotifications,
                  activeTrackColor: AppColor.primary,
                ),
              ),
              const _SettingsDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                child: Row(
                  children: [
                    _SettingsIcon(icon: Icons.language),
                    const Gap(12),
                    Text(
                      'Language'.tr,
                      style: AppFont.font14W700Black,
                    ),
                  ],
                ),
              ),
              _LanguageOption(
                label: 'English'.tr,
                selected: currentLanguage == Language.english,
                onTap: () => changeLanguage(Language.english),
              ),
              _LanguageOption(
                label: 'Arabic'.tr,
                selected: currentLanguage == Language.arabic,
                onTap: () => changeLanguage(Language.arabic),
              ),
              const Gap(8),
            ],
          ),
          if (hasToken) ...[
            const Gap(24),
            Text(
              'Support'.tr,
              style: AppFont.font20W700Black,
            ),
            const Gap(14),
            _SettingsCard(
              children: [
                _SettingsRow(
                  icon: Icons.support_agent_outlined,
                  title: 'Support tickets'.tr,
                  showArrow: true,
                  onTap: openSupportTickets,
                ),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: Icons.chat_outlined,
                  title: 'Service chats'.tr,
                  showArrow: true,
                  onTap: openServiceChats,
                ),
              ],
            ),
          ],
          if (hasToken) ...[
            const Gap(24),
            Text(
              'Danger zone'.tr,
              style: AppFont.font20W700Black.copyWith(color: AppColor.danger),
            ),
            const Gap(14),
            _SettingsCard(
              borderColor: AppColor.danger.withAlpha(40),
              children: [
                _SettingsRow(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete account'.tr,
                  iconColor: AppColor.danger,
                  titleColor: AppColor.danger,
                  showArrow: true,
                  onTap: showDeleteAccountConfirmation,
                ),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: Icons.logout_rounded,
                  title: 'Log Out'.tr,
                  iconColor: AppColor.danger,
                  titleColor: AppColor.danger,
                  showArrow: true,
                  onTap: showLogoutConfirmation,
                ),
              ],
            ),
          ],
          Gap(MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.children,
    this.borderColor,
  });

  final List<Widget> children;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({
    required this.icon,
    this.color,
  });

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: AppColor.primaryDark,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 22,
        color: color ?? const Color(0xFF7A3EFF),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.showArrow = false,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showArrow;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              _SettingsIcon(icon: icon, color: iconColor),
              const Gap(12),
              Expanded(
                child: Text(
                  title,
                  style: AppFont.font14W700Black.copyWith(color: titleColor),
                ),
              ),
              if (trailing != null) trailing!,
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: titleColor ?? AppColor.grey2,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const SizedBox(width: 56),
              Expanded(
                child: Text(
                  label,
                  style: selected
                      ? AppFont.font14W700Black.copyWith(
                          color: AppColor.primary,
                        )
                      : AppFont.font14W500Black,
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off_outlined,
                color: selected ? AppColor.primary : AppColor.grey2,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Divider(
        height: 1,
        color: AppColor.grey1.withAlpha(160),
      ),
    );
  }
}
