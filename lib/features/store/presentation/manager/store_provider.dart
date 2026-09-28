import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/store/domain/entities/store_category_entity.dart';
import 'package:heraj/features/store/domain/entities/store_sub_category_entity.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';
import 'package:heraj/features/vendor/presentation/managers/fetch_vendors_provider.dart';
import '../../../../main.dart';
import '../../domain/use_case/fetch_store_categories_use_case.dart';
import '../../domain/use_case/fetch_store_sub_categories_use_case.dart';

enum StoreSortType { nearby, offers, topRated }

final storeSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final storeSelectedCategoryIdProvider =
    StateProvider.autoDispose<int>((ref) => 0);
final storeSelectedSubCategoryIdProvider =
    StateProvider.autoDispose<int>((ref) => 0);
final storeSortTypeProvider =
    StateProvider.autoDispose<StoreSortType>((ref) => StoreSortType.nearby);
final storeIsFeaturedFilterProvider =
    StateProvider.autoDispose<bool>((ref) => false);
final storeOffersFilterProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final fetchStoreCategoriesProvider =
    FutureProvider.autoDispose<List<StoreCategoryEntity>>((ref) async {
  final result = await getIt<FetchStoreCategoriesUseCase>().call();
  return result.fold((l) => throw l, (r) => r);
});

final fetchStoreSubCategoriesProvider =
    FutureProvider.autoDispose<List<StoreSubCategoryEntity>>((ref) async {
  final result = await getIt<FetchStoreSubCategoriesUseCase>().call();
  return result.fold((l) => throw l, (r) => r);
});

final filteredVendorsProvider =
    Provider.autoDispose.family<List<VendorModel>, VendorsQuery>((ref, query) {
  final vendorsAsync = ref.watch(fetchVendorsProvider(query));
  var result = List<VendorModel>.from(
    vendorsAsync.valueOrNull ?? const <VendorModel>[],
  );

  final sortType = ref.watch(storeSortTypeProvider);
  switch (sortType) {
    case StoreSortType.topRated:
      result.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case StoreSortType.nearby:
    case StoreSortType.offers:
      result.sort((a, b) => a.listingPosition.compareTo(b.listingPosition));
      break;
  }

  return result;
});

final filteredSubCategoriesProvider =
    Provider.autoDispose<List<StoreSubCategoryEntity>>((ref) {
  final subCategoriesAsync = ref.watch(fetchStoreSubCategoriesProvider);
  final selectedCategoryId = ref.watch(storeSelectedCategoryIdProvider);
  final subCategories =
      subCategoriesAsync.valueOrNull ?? const <StoreSubCategoryEntity>[];

  if (selectedCategoryId == 0) return subCategories;
  return subCategories.where((s) => s.categoryId == selectedCategoryId).toList();
});
