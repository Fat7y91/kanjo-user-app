import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/store/presentation/manager/store_provider.dart';
import 'package:heraj/features/store/presentation/view/store_details_screen.dart';
import 'package:heraj/features/store/presentation/view/widgets/offline_store_caution_sheet.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';

mixin StoreScreenActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Timer? _searchDebounce;

  void onBack() => Get.back();

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      ref.read(storeSearchQueryProvider.notifier).state = value.trim();
    });
  }

  void cancelSearchDebounce() {
    _searchDebounce?.cancel();
    _searchDebounce = null;
  }

  void onSortSelected(StoreSortType type) {
    ref.read(storeSortTypeProvider.notifier).state = type;
  }

  void onOffersFilterToggled() {
    final current = ref.read(storeOffersFilterProvider);
    ref.read(storeOffersFilterProvider.notifier).state = !current;
  }

  void onFeaturedFilterToggled() {
    final current = ref.read(storeIsFeaturedFilterProvider);
    ref.read(storeIsFeaturedFilterProvider.notifier).state = !current;
  }

  Future<void> openStoreDetails(VendorModel vendor) async {
    if (isVendorOffline(vendor)) {
      final shouldContinue = await showOfflineStoreCautionSheet(context);
      if (!shouldContinue || !mounted) return;
    }
    Get.to(() => StoreDetailsScreen(vendor: vendor));
  }
}
