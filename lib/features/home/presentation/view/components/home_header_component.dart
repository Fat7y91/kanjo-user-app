import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/auth_service.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/core/service/location_service/location_provider.dart';
import 'package:heraj/core/service/location_service/location_service.dart';
import 'package:heraj/features/cart/presentation/managers/fetch_cart_provider.dart';
import 'package:heraj/features/notifications/presentation/managers/fetch_notificatons_provider.dart';
import 'package:heraj/features/home/presentation/view/widgets/delivery_zone_selection_sheet.dart';
import 'package:heraj/features/home/presentation/view/widgets/location_bottom_sheet.dart';
import 'package:heraj/features/location/presentation/managers/location_provider.dart';
import 'package:heraj/features/profile/presentation/view/update_profile_view.dart';
import 'package:heraj/features/search/presentation/view/search_screen.dart';
import 'package:heraj/ui/shared_widgets/grediant_box.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'home_offers_component.dart';

class HomeHeaderComponent extends ConsumerWidget {
  const HomeHeaderComponent({super.key});

  String? _formatLocation(LocationDetails? details) {
    if (details == null) return null;
    final address = details.fullAddress.trim();
    if (address.isNotEmpty) return address;
    final name = details.name.trim();
    if (name.isNotEmpty) return name;
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider) ?? dataManager.getUser();
    final imageUrl = user?.image?.trim() ?? '';
    final selectedLocation = ref.watch(currentDisplayLocationProvider);
    final gpsLocationAsync = ref.watch(fetchLocationDetailsProvider);
    final hasLocationAccess =
        ref.watch(locationAccessGrantedProvider).valueOrNull ?? false;
    final selectedZone = ref.watch(selectedDeliveryZoneProvider);
    final cartCount = ref.watch(fetchCartProvider).maybeWhen(
          data: (cart) =>
              cart.items.fold<int>(0, (sum, item) => sum + item.quantity),
          orElse: () => 0,
        );
    final unreadNotifications =
        ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    ref.listen(fetchLocationDetailsProvider, (previous, next) {
      next.whenData((details) {
        if (details == null) return;
        if (ref.read(currentDisplayLocationProvider) != null) return;
        ref.read(currentDisplayLocationProvider.notifier).state = details;
        ref.read(selectedDeliveryZoneProvider.notifier).clear();
      });
    });

    final String locationText;
    if (hasLocationAccess) {
      locationText = _formatLocation(selectedLocation) ??
          _formatLocation(gpsLocationAsync.valueOrNull) ??
          (gpsLocationAsync.isLoading
              ? 'Current location'.tr
              : 'Choose your location'.tr);
    } else {
      locationText = selectedZone?.name.trim().isNotEmpty == true
          ? selectedZone!.name
          : 'Select your zone'.tr;
    }

    return Stack(
      children: [
        Image.asset(
          AppAssets.homeBackground,
          width: double.infinity,
          fit: BoxFit.fill,
          height: 350,
        ),
        Column(
          children: [
            Container(
              padding: EdgeInsetsDirectional.only(
                top: MediaQuery.of(context).padding.top,
                start: 16,
                end: 16,
                bottom: 6,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Get.to(() => const UpdateProfileView()),
                        borderRadius: BorderRadius.circular(22),
                        child: ClipOval(
                          child: ImageOrSvg(
                            imageUrl.isEmpty ? null : imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            pickImageOnNull: true,
                            assetImageOnNull: AppAssets.profile,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome'.tr,
                              style: AppFont.font16W600Black.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            InkWell(
                              onTap: () async {
                                if (hasLocationAccess) {
                                  await showLocationBottomSheet(
                                    context: context,
                                  );
                                } else {
                                  await showDeliveryZoneBottomSheet(
                                    context: context,
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 15,
                                    color: Color(0xFFFFD54F),
                                  ),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      locationText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFont.font13W400Black.copyWith(
                                        color: Colors.white.withAlpha(220),
                                      ),
                                    ),
                                  ),
                                  if (!hasLocationAccess) ...[
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: Colors.white.withAlpha(220),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.toNamed('/notifications'),
                        icon: Badge(
                          isLabelVisible: unreadNotifications > 0,
                          backgroundColor: AppColor.guestOrange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          label: Text(
                            unreadNotifications > 99
                                ? '99+'
                                : '$unreadNotifications',
                            style: AppFont.font10W600White,
                          ),
                          child: SvgPicture.asset(
                            AppAssets.notificationBing,
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.toNamed('/cart'),
                        icon: Badge(
                          isLabelVisible: cartCount > 0,
                          backgroundColor: AppColor.guestOrange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          label: Text(
                            cartCount > 99 ? '99+' : '$cartCount',
                            style: AppFont.font10W600White,
                          ),
                          child: SvgPicture.asset(
                            AppAssets.bag,
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Get.to(() => const SearchScreen()),
                      borderRadius: BorderRadius.circular(26),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withAlpha(34),
                              Colors.white.withAlpha(14),
                              Colors.white.withAlpha(8),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          border: GradientBoxBorder(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withAlpha(245),
                                Colors.white.withAlpha(70),
                                Colors.white.withAlpha(38),
                                Colors.white.withAlpha(240),
                              ],
                              stops: const [0.0, 0.30, 0.72, 1.0],
                            ),
                            width: 1.25,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withAlpha(35),
                              blurRadius: 14,
                              spreadRadius: 0.5,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.searchNormal,
                              width: 22,
                              height: 22,
                              colorFilter: ColorFilter.mode(
                                Colors.white.withAlpha(230),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Search'.tr,
                                style: AppFont.font14W500Black.copyWith(
                                  color: Colors.white.withAlpha(220),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const HomeOffersComponent(),
          ],
        ),
      ],
    );
  }
}
