import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/home/data/models/slider_model.dart';
import 'package:heraj/features/home/domain/entities/slider_target_entity.dart';
import 'package:heraj/features/home/domain/entities/slider_target_type.dart';
import 'package:heraj/features/products/presentation/view/product_details_screen.dart';
import 'package:heraj/features/services/presentation/managers/services_provider.dart';
import 'package:heraj/features/services/presentation/view/service_providers_screen.dart';
import 'package:heraj/features/store/presentation/view/store_details_screen.dart';
import 'package:heraj/features/store/presentation/view/store_screen.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';
import 'package:heraj/features/vendor/domain/entities/vendor_type_name_entity.dart';

mixin HomePromoBannerActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  void onSliderTap(SliderModel slider) {
    final target = slider.target;
    if (target == null || target.id <= 0) return;

    switch (target.type) {
      case SliderTargetType.home:
        break;
      case SliderTargetType.product:
        Get.to(() => ProductDetailsScreen(productId: target.id));
        break;
      case SliderTargetType.vendor:
        Get.to(
          () => StoreDetailsScreen(vendor: _vendorFromTarget(target)),
        );
        break;
      case SliderTargetType.vendorType:
        final title = _titleFromTarget(target);
        if (_targetLooksLikeServices(target)) {
          Get.to(() => ServiceProvidersScreen(title: title));
        } else {
          Get.to(
            () => StoreScreen(
              vendorTypeId: target.id,
              title: title,
              showVendorTypes: false,
            ),
          );
        }
        break;
      case SliderTargetType.offer:
        Get.to(
          () => StoreScreen(
            offers: true,
            title: _titleFromTarget(target, fallback: 'Offers'.tr),
          ),
        );
        break;
      case SliderTargetType.category:
        Get.to(
          () => StoreScreen(
            categoryId: target.id,
            title: _titleFromTarget(target),
          ),
        );
        break;
    }
  }

  bool _targetLooksLikeServices(SliderTargetEntity target) {
    final key = target.data['key']?.toString() ?? '';
    final name = target.data['name'];
    var en = '';
    var ar = '';
    if (name is Map) {
      final localized = VendorTypeNameEntity.fromJson(
        Map<String, dynamic>.from(name),
      );
      en = localized.en;
      ar = localized.ar;
    } else if (name != null) {
      en = name.toString();
    }
    return isServicesVendorType(key: key, en: en, ar: ar);
  }

  String _titleFromTarget(SliderTargetEntity target, {String? fallback}) {
    final languageCode = Get.locale?.languageCode;
    final name = target.localizedName(languageCode);
    if (name.isNotEmpty) return name;
    return fallback ?? 'Store'.tr;
  }

  VendorModel _vendorFromTarget(SliderTargetEntity target) {
    final raw = <String, dynamic>{
      'id': target.id,
      ...target.data,
    };
    final name = raw['name'];
    if (name is Map) {
      raw['name'] = VendorTypeNameEntity.fromJson(
        Map<String, dynamic>.from(name),
      ).localized(Get.locale?.languageCode);
    }
    return VendorModel.fromJson(raw);
  }
}
