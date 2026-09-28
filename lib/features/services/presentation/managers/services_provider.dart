import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/services/domain/entities/provider_service_entity.dart';
import 'package:heraj/features/services/domain/entities/service_type_entity.dart';
import 'package:heraj/features/services/domain/use_case/fetch_provider_services_use_case.dart';
import 'package:heraj/features/services/domain/use_case/fetch_service_provider_use_case.dart';
import 'package:heraj/features/services/domain/use_case/fetch_service_providers_use_case.dart';
import 'package:heraj/features/services/domain/use_case/fetch_service_types_use_case.dart';
import 'package:heraj/features/vendor/data/models/vendor_type_model.dart';
import 'package:heraj/main.dart';

enum ServicePaymentMethod {
  cod;

  String get apiValue => 'cod';

  String get label => 'Cash';
}

final fetchServiceTypesProvider =
    FutureProvider.autoDispose<List<ServiceTypeEntity>>((ref) async {
  final res = await getIt<FetchServiceTypesUseCase>().call();
  return res.fold(
    (l) => throw l,
    (r) => r.where((type) => type.isActive).toList(),
  );
});

final storeDetailsSelectedServiceTypeIdProvider =
    StateProvider.autoDispose<int>((ref) => 0);

final fetchProviderServicesProvider = FutureProvider.autoDispose
    .family<List<ProviderServiceEntity>, FetchProviderServicesParams>(
  (ref, params) async {
    final useCase = getIt<FetchProviderServicesUseCase>();
    final res = await useCase.call(params);
    final list = res.fold((l) => throw l, (r) => r);
    if (list.isNotEmpty || params.serviceProviderId == null) {
      return list;
    }
    final fallback = await useCase.call(
      FetchProviderServicesParams(serviceTypeId: params.serviceTypeId),
    );
    return fallback.fold((l) => throw l, (all) {
      return all
          .where(
            (service) =>
                service.serviceProviderId == params.serviceProviderId ||
                service.provider?.id == params.serviceProviderId,
          )
          .toList();
    });
  },
);

final fetchServiceProviderProvider =
    FutureProvider.autoDispose.family<ServiceProviderEntity, int>(
  (ref, id) async {
    final res = await getIt<FetchServiceProviderUseCase>().call(id);
    return res.fold((l) => throw l, (r) => r);
  },
);

final fetchServiceProvidersProvider = FutureProvider.autoDispose
    .family<List<ServiceProviderEntity>, FetchServiceProvidersParams>(
  (ref, params) async {
    final res = await getIt<FetchServiceProvidersUseCase>().call(params);
    return res.fold((l) => throw l, (r) => r);
  },
);

bool isServicesVendorType({
  required String key,
  required String en,
  required String ar,
}) {
  final normalizedKey = key.toLowerCase();
  final normalizedEn = en.toLowerCase();
  return normalizedKey.contains('service') ||
      normalizedEn.contains('service') ||
      ar.contains('خدم');
}

bool vendorTypeIsServices(VendorTypeModel type) {
  return isServicesVendorType(
    key: type.key,
    en: type.name.en,
    ar: type.name.ar,
  );
}
