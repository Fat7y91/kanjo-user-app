import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/offers/data/models/offer_model.dart';
import 'package:heraj/features/offers/domain/entities/offer_target_type.dart';
import 'package:heraj/features/products/presentation/view/category_products_screen.dart';
import 'package:heraj/features/products/presentation/view/product_details_screen.dart';
import 'package:heraj/features/store/presentation/view/store_details_screen.dart';
import 'package:heraj/features/store/presentation/view/store_screen.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';

mixin OffersActionsMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  void openAllOffers() {
    Get.toNamed('/offers');
  }

  void onOfferTap(OfferModel offer) {
    final targetId = offer.firstTargetId;
    if (targetId == null || offer.targetType == null) return;

    final languageCode = Get.locale?.languageCode;
    final title = offer.name.localized(languageCode);

    switch (offer.targetType!) {
      case OfferTargetType.category:
        Get.to(
          () => CategoryProductsScreen(
            categoryId: targetId,
            title: title,
            offer: offer,
          ),
        );
        break;
      case OfferTargetType.vendorType:
        Get.to(
          () => StoreScreen(
            vendorTypeId: targetId,
            title: title.isNotEmpty ? title : 'Store'.tr,
            showVendorTypes: false,
            offer: offer,
          ),
        );
        break;
      case OfferTargetType.vendor:
        Get.to(
          () => StoreDetailsScreen(
            vendor: VendorModel.fromJson({'id': targetId}),
            offer: offer,
          ),
        );
        break;
      case OfferTargetType.product:
        Get.to(
          () => ProductDetailsScreen(
            productId: targetId,
            offer: offer,
          ),
        );
        break;
    }
  }
}
