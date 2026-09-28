import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/services/domain/entities/provider_service_entity.dart';
import 'package:heraj/features/services/domain/use_case/fetch_service_providers_use_case.dart';
import 'package:heraj/features/services/presentation/managers/services_provider.dart';
import 'package:heraj/features/store/presentation/manager/service_provider_vendor_mapper.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';

final serviceProvidersSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

final serviceProvidersSelectedTypeIdProvider =
    StateProvider.autoDispose<int>((ref) => 0);

final serviceProvidersQueryProvider =
    Provider.autoDispose<FetchServiceProvidersParams>((ref) {
  final search = ref.watch(serviceProvidersSearchQueryProvider).trim();
  final typeId = ref.watch(serviceProvidersSelectedTypeIdProvider);
  return FetchServiceProvidersParams(
    serviceTypeId: typeId > 0 ? typeId : null,
    search: search.isEmpty ? null : search,
  );
});

final filteredServiceProviderVendorsProvider =
    Provider.autoDispose<List<VendorModel>>((ref) {
  final params = ref.watch(serviceProvidersQueryProvider);
  final providers =
      ref.watch(fetchServiceProvidersProvider(params)).valueOrNull ??
          const <ServiceProviderEntity>[];
  return providers
      .map((provider) => vendorFromServiceProvider(provider))
      .toList();
});
