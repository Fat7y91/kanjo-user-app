import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/store/presentation/view/store_details_screen.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';

mixin SearchScreenActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  void openStoreDetails(VendorModel vendor) {
    Get.to(() => StoreDetailsScreen(vendor: vendor));
  }
}
