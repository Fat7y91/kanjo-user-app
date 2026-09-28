import 'package:get/get.dart';
import 'package:heraj/features/offers/presentation/view/offers_screen.dart';
import 'package:heraj/features/products/presentation/view/product_details_screen.dart';
import 'package:heraj/features/services/presentation/view/service_provider_details_screen.dart';
import 'package:heraj/features/share/domain/entities/share_link_resolve_entity.dart';
import 'package:heraj/features/share/domain/entities/share_link_type.dart';
import 'package:heraj/features/store/presentation/view/store_details_screen.dart';
import 'package:heraj/features/store/presentation/view/store_screen.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';

abstract class ShareLinkNavigator {
  ShareLinkNavigator._();

  static void navigate(ShareLinkResolveEntity resolved) {
    final screen = resolved.screen.trim().toLowerCase();

    switch (screen) {
      case 'product_details':
        Get.to(() => ProductDetailsScreen(productId: resolved.id));
        return;
      case 'vendor_details':
      case 'store_details':
        Get.to(
          () => StoreDetailsScreen(
            vendor: VendorModel.fromJson({'id': resolved.id}),
          ),
        );
        return;
      case 'service_provider_details':
        Get.to(
          () => ServiceProviderDetailsScreen(serviceProviderId: resolved.id),
        );
        return;
      case 'provider_service_details':
        Get.to(() => const StoreScreen(showVendorTypes: false));
        return;
      case 'service_type_details':
        Get.to(
          () => StoreScreen(
            vendorTypeId: resolved.id,
            showVendorTypes: false,
          ),
        );
        return;
      case 'offer_details':
      case 'offers':
        Get.to(() => const OffersScreen());
        return;
    }

    switch (resolved.type) {
      case ShareLinkType.product:
        Get.to(() => ProductDetailsScreen(productId: resolved.id));
      case ShareLinkType.vendor:
        Get.to(
          () => StoreDetailsScreen(
            vendor: VendorModel.fromJson({'id': resolved.id}),
          ),
        );
      case ShareLinkType.serviceProvider:
        Get.to(
          () => ServiceProviderDetailsScreen(serviceProviderId: resolved.id),
        );
      case ShareLinkType.providerService:
        Get.to(() => const StoreScreen(showVendorTypes: false));
      case ShareLinkType.serviceType:
        Get.to(
          () => StoreScreen(
            vendorTypeId: resolved.id,
            showVendorTypes: false,
          ),
        );
      case ShareLinkType.offer:
        Get.to(() => const OffersScreen());
    }
  }
}
