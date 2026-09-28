import 'package:heraj/config/app_font.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/ui/shared_widgets/scaffold_back_ground.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';
import '../manager/fetch_policy_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldBackGround(
      title: "Privacy and Policy".tr,
      isRoot: false,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom,
          left: 20,
          right: 20,
        ),
        child: CustomFilledButton(
          text: "Ok".tr,
          fontColor: Colors.white,
          color: AppColor.primary,
          onPressed: () => Get.back(),
        ),
      ),
      child: Consumer(
        builder: (context, ref, _) {
          final terms = ref.watch(fetchPolicyProvider);
          return terms.customWhen(
            refreshable: fetchPolicyProvider.future,
            ref: ref,
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: ShimmerEffect(
                enable: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < 6; i++) ...[
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECECEC),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECECEC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (termsData) {
              return const _PolicyContent();
            },
          );
        },
      ),
    );
  }
}

class _PolicyContent extends StatelessWidget {
  const _PolicyContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Text(
                    'Privacy Policy'.tr,
                    style: AppFont.font18W700Black.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  Text(
                    'Last Updated: August 2026'.tr,
                    style: AppFont.font14W500Grey2,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(24),
                  Text(
                    'Your privacy is important to Kango. This policy explains how we collect, use, and protect your personal information when you use our delivery and marketplace app.'
                        .tr,
                    style: AppFont.font14W500Black,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Gap(32),

            // Key Features Cards
            _buildFeatureCards(),
            const Gap(32),

            // Expandable Sections
            _PolicySection(
              title: 'Information We Collect',
              icon: Icons.info_outline,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubSection(
                    'Personal Information'.tr,
                    'When you create a Kango account, we collect your name, email address, phone number, birthday (if provided), and delivery addresses. This information is necessary to process your orders and provide customer support.'
                        .tr,
                  ),
                  _buildSubSection(
                    'Payment Information'.tr,
                    'Payment details are processed securely through our payment partners. We do not store your complete card information on our servers.'
                        .tr,
                  ),
                  _buildSubSection(
                    'Usage Data'.tr,
                    'We collect information about how you use Kango, including pages visited, products viewed, and search queries to improve our services.'
                        .tr,
                  ),
                  _buildSubSection(
                    'Device Information'.tr,
                    'We may collect device type, app version, IP address, and operating system to ensure compatibility and security.'
                        .tr,
                  ),
                ],
              ),
            ),

            _PolicySection(
              title: 'How We Use Your Information',
              icon: Icons.settings_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint('Process and fulfill your orders'),
                  _buildBulletPoint('Communicate about order status'),
                  _buildBulletPoint('Maintain your account and provide support'),
                  _buildBulletPoint('Personalize your shopping experience'),
                  _buildBulletPoint('Send order confirmations and updates'),
                  _buildBulletPoint('Improve platform functionality and security'),
                  _buildBulletPoint('Analyze usage patterns'),
                  _buildBulletPoint('Prevent fraud and abuse'),
                ],
              ),
            ),

            _PolicySection(
              title: 'Data Sharing and Disclosure',
              icon: Icons.share_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We do not sell your personal information to third parties. We may share your information only in the following circumstances:',
                    style: AppFont.font14W500Black,
                  ),
                  const Gap(12),
                  _buildBulletPoint('With vendors to fulfill your orders'),
                  _buildBulletPoint('With payment processors to complete transactions'),
                  _buildBulletPoint('With shipping partners to deliver your purchases'),
                  _buildBulletPoint('With service providers who assist in operating our platform'),
                  _buildBulletPoint('When required by law or to protect our legal rights'),
                  _buildBulletPoint('With your explicit consent'),
                ],
              ),
            ),

            _PolicySection(
              title: 'Your Rights and Choices',
              icon: Icons.security_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You have the following rights regarding your personal data:',
                    style: AppFont.font14W500Black,
                  ),
                  const Gap(12),
                  _buildRightItem(
                    'Access',
                    'Request a copy of the personal information we hold about you',
                  ),
                  _buildRightItem(
                    'Correction',
                    'Update or correct inaccurate information',
                  ),
                  _buildRightItem(
                    'Deletion',
                    'Request deletion of your personal data (subject to legal obligations)',
                  ),
                  _buildRightItem(
                    'Opt-Out',
                    'Unsubscribe from marketing communications at any time',
                  ),
                  _buildRightItem(
                    'Data Portability',
                    'Request your data in a portable format',
                  ),
                  _buildRightItem(
                    'Objection',
                    'Object to certain types of data processing',
                  ),
                  const Gap(12),
                  Text(
                    'To exercise these rights, please contact us at support@kango.app or open a support ticket in the app.'
                        .tr,
                    style: AppFont.font12w500Grey2,
                  ),
                ],
              ),
            ),

            _PolicySection(
              title: 'Cookies and Tracking',
              icon: Icons.cookie_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We use cookies and similar tracking technologies to improve your experience on our platform. Cookies help us:',
                    style: AppFont.font14W500Black,
                  ),
                  const Gap(12),
                  _buildBulletPoint('Remember your preferences and settings'),
                  _buildBulletPoint('Keep you signed in to your account'),
                  _buildBulletPoint('Analyze how you use our platform'),
                  _buildBulletPoint('Show you relevant advertisements'),
                  const Gap(12),
                  Text(
                    'You can control cookies through your browser settings. However, disabling cookies may limit your ability to use certain features of our platform.',
                    style: AppFont.font12w500Grey2,
                  ),
                ],
              ),
            ),

            _PolicySection(
              title: 'Data Retention',
              icon: Icons.storage_outlined,
              content: Text(
                'We retain your personal information for as long as necessary to provide our services and comply with legal obligations. When you delete your account, we will delete or anonymize your personal data within 30 days, except where we are required to retain it for legal, tax, or regulatory purposes.',
                style: AppFont.font14W500Black,
              ),
            ),

            _PolicySection(
              title: 'Children\'s Privacy',
              icon: Icons.child_care_outlined,
              content: Text(
                'Our platform is not intended for users under the age of 18. We do not knowingly collect personal information from children. If you believe we have inadvertently collected information from a child, please contact us immediately.',
                style: AppFont.font14W500Black,
              ),
            ),

            _PolicySection(
              title: 'Changes to This Policy',
              icon: Icons.update_outlined,
              content: Text(
                'We may update this Privacy Policy from time to time. We will notify you of any significant changes by posting the new policy on this page and updating the "Last Updated" date. We encourage you to review this policy periodically.',
                style: AppFont.font14W500Black,
              ),
            ),

            const Gap(24),

            // Contact Section
            _buildContactSection(),
            const Gap(100),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                Icons.security,
                'Data Protection',
                'Industry-standard security measures',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                Icons.lock_outline,
                'Secure Storage',
                'Encrypted and protected',
              ),
            ),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                Icons.visibility_outlined,
                'Transparency',
                'Clear data practices',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                Icons.admin_panel_settings_outlined,
                'Your Control',
                'Full data control',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.primary.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColor.primary, size: 32),
          const Gap(8),
          Text(
            title,
            style: AppFont.font14W600Black,
            textAlign: TextAlign.center,
          ),
          const Gap(4),
          Text(
            description,
            style: AppFont.font12w500Grey2,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFont.font14W600Black,
          ),
          const Gap(4),
          Text(
            content,
            style: AppFont.font14W500Black,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppFont.font14W500Black),
          Expanded(
            child: Text(text, style: AppFont.font14W500Black),
          ),
        ],
      ),
    );
  }

  Widget _buildRightItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title,
              style: AppFont.font12W600Black.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(description, style: AppFont.font14W500Black),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary.withAlpha(20), AppColor.primary.withAlpha(40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.primary.withAlpha(100)),
      ),
      child: Column(
        children: [
          Icon(Icons.contact_support_outlined, color: AppColor.primary, size: 40),
          const Gap(12),
          Text(
            'Questions About Privacy?'.tr,
            style: AppFont.font16W600Black,
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Text(
            'If you have questions or concerns about Kango privacy practices, please contact us.'
                .tr,
            style: AppFont.font14W500Black,
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          _buildContactItem(Icons.email_outlined, 'support@kango.app'),
          const Gap(8),
          _buildContactItem(
            Icons.language_outlined,
            'kango.laravelteam.site',
          ),
          const Gap(8),
          _buildContactItem(
            Icons.confirmation_number_outlined,
            'Support tickets'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColor.primary, size: 18),
        const SizedBox(width: 8),
        Text(text, style: AppFont.font14W500Black),
      ],
    );
  }
}

class _PolicySection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget content;

  const _PolicySection({
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  State<_PolicySection> createState() => _PolicySectionState();
}

class _PolicySectionState extends State<_PolicySection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.grey1.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icon,
                      color: AppColor.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppFont.font16W600Black,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColor.grey2,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: AppColor.grey1.withAlpha(50)),
                  const Gap(12),
                  widget.content,
                ],
              ),
            ),
        ],
      ),
    );
  }
}
