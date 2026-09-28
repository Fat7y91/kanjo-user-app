import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/services/presentation/view/service_providers_screen.dart';
import 'package:heraj/features/settings/presentation/manager/fetch_settings_manager.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';

class HomeKServiceBannerComponent extends ConsumerWidget {
  const HomeKServiceBannerComponent({super.key});

  static const _height = 148.0;
  static const _radius = 20.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    if (settings == null || !settings.serviceProviderActive) {
      return const SizedBox.shrink();
    }

    final imageUrl = settings.serviceProviderImageUrl;
    final hasNetworkImage = imageUrl != null && imageUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => const ServiceProvidersScreen()),
          borderRadius: BorderRadius.circular(_radius),
          child: Ink(
            height: _height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_radius),
              child: hasNetworkImage
                  ? ImageOrSvg(
                      imageUrl,
                      width: double.infinity,
                      height: _height,
                      fit: BoxFit.cover,
                      isCircleLoading: false,
                      pickImageOnNull: true,
                      assetImageOnNull: AppAssets.kServiceBanner,
                    )
                  : Image.asset(
                      AppAssets.kServiceBanner,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: _height,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColor.primary2,
                        alignment: Alignment.center,
                        child: Text(
                          'K- Service'.tr,
                          style: AppFont.font18W700Black.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
