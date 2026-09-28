import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/services/presentation/managers/service_providers_list_provider.dart';
import 'package:heraj/features/services/presentation/view/service_provider_details_screen.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';

mixin ServiceProvidersScreenActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Timer? _searchDebounce;

  void onBack() => Get.back();

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      ref.read(serviceProvidersSearchQueryProvider.notifier).state =
          value.trim();
    });
  }

  void cancelSearchDebounce() {
    _searchDebounce?.cancel();
    _searchDebounce = null;
  }

  void openProviderDetails(VendorModel vendor) {
    Get.to(
      () => ServiceProviderDetailsScreen(serviceProviderId: vendor.id),
    );
  }
}
