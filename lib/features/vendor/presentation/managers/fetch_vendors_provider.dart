import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/models/paginated_response.dart';
import 'package:heraj/features/location/presentation/managers/location_provider.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';
import 'package:heraj/features/vendor/domain/use_case/fetch_vendors_params.dart';
import 'package:heraj/features/vendor/domain/use_case/fetch_vendors_use_case.dart';
import 'package:heraj/main.dart';

class VendorsQuery {
  final int vendorTypeId;
  final int categoryId;
  final String search;
  final bool isFeatured;
  final bool offers;
  final double? latitude;
  final double? longitude;
  final int? zoneId;

  const VendorsQuery({
    this.vendorTypeId = 0,
    this.categoryId = 0,
    this.search = '',
    this.isFeatured = false,
    this.offers = false,
    this.latitude,
    this.longitude,
    this.zoneId,
  });

  VendorsQuery withGeo(VendorsGeoParams geo) {
    return VendorsQuery(
      vendorTypeId: vendorTypeId,
      categoryId: categoryId,
      search: search,
      isFeatured: isFeatured,
      offers: offers,
      latitude: geo.latitude,
      longitude: geo.longitude,
      zoneId: geo.zoneId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VendorsQuery &&
        other.vendorTypeId == vendorTypeId &&
        other.categoryId == categoryId &&
        other.search == search &&
        other.isFeatured == isFeatured &&
        other.offers == offers &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.zoneId == zoneId;
  }

  @override
  int get hashCode => Object.hash(
        vendorTypeId,
        categoryId,
        search,
        isFeatured,
        offers,
        latitude,
        longitude,
        zoneId,
      );
}

class VendorsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<VendorModel>, VendorsQuery> {
  int _nextPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  bool get isLoadingMore => _loadingMore;

  bool isLastPage() => _nextPage > _lastPage;

  FetchVendorsParams _params({required int page}) {
    return FetchVendorsParams(
      vendorTypeId: arg.vendorTypeId > 0 ? arg.vendorTypeId : null,
      categoryId: arg.categoryId > 0 ? arg.categoryId : null,
      search: arg.search.trim().isEmpty ? null : arg.search.trim(),
      isFeatured: arg.isFeatured,
      offers: arg.offers,
      latitude: arg.latitude,
      longitude: arg.longitude,
      zoneId: arg.zoneId,
      page: page,
      perPage: PaginationConfig.perPage,
    );
  }

  @override
  Future<List<VendorModel>> build(VendorsQuery query) async {
    _nextPage = 1;
    _lastPage = 1;
    _loadingMore = false;

    final result = await getIt<FetchVendorsUseCase>().call(_params(page: 1));

    return result.fold((l) => throw l, (r) {
      _lastPage = r.meta.lastPage;
      _nextPage = 2;
      return r.data;
    });
  }

  Future<void> fetchNextPage() async {
    if (_loadingMore || isLastPage()) return;
    _loadingMore = true;
    try {
      final result =
          await getIt<FetchVendorsUseCase>().call(_params(page: _nextPage));
      result.fold((l) {}, (r) {
        _lastPage = r.meta.lastPage;
        if (r.data.isEmpty) {
          _lastPage = _nextPage - 1;
          return;
        }
        _nextPage++;
        state = AsyncData([...?state.value, ...r.data]);
      });
    } finally {
      _loadingMore = false;
    }
  }
}

final fetchVendorsProvider = AsyncNotifierProvider.autoDispose
    .family<VendorsNotifier, List<VendorModel>, VendorsQuery>(
        VendorsNotifier.new);
