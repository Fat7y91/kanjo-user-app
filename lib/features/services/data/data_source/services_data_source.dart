import 'package:dio/dio.dart';
import 'package:heraj/features/vendor/domain/entities/vendor_rating_summary_entity.dart';

import '../../../../../config/api_path.dart';
import '../../../../../core/models/paginated_response.dart';
import '../../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/create_service_order_params.dart';
import '../../domain/entities/provider_service_entity.dart';
import '../../domain/entities/service_order_entity.dart';
import '../../domain/entities/service_type_entity.dart';

abstract class ServicesDataSource {
  Future<List<ServiceTypeEntity>> getServiceTypes();

  Future<List<ProviderServiceEntity>> getProviderServices({
    int? serviceTypeId,
    int? serviceProviderId,
  });

  Future<List<ServiceProviderEntity>> getServiceProviders({
    int? serviceTypeId,
    String? search,
  });

  Future<ServiceProviderEntity> getServiceProvider(int serviceProviderId);

  Future<bool> createServiceOrder(CreateServiceOrderParams params);

  Future<PaginatedResponse<ServiceOrderEntity>> getMyServiceOrders({
    int page = 1,
    int perPage = 20,
  });
}

class ServicesDataSourceImp extends ServicesDataSource {
  ServicesDataSourceImp({required this.apiService});

  final ApiService apiService;

  List<Map<String, dynamic>> _asItemMaps(dynamic res) {
    if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (res is Map) {
      final root = Map<String, dynamic>.from(res);
      final data = root['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (data is Map) {
        final nested = Map<String, dynamic>.from(data);
        for (final key in [
          'items',
          'data',
          'service_types',
          'services',
          'service_providers',
          'providers',
        ]) {
          final list = nested[key];
          if (list is List) {
            return list
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          }
        }
      }
    }
    return const [];
  }

  @override
  Future<List<ServiceTypeEntity>> getServiceTypes() async {
    final res = await apiService.get(
      url: ApiPath.getServiceTypes,
      returnDataOnly: false,
    );
    return _asItemMaps(res).map(ServiceTypeEntity.fromJson).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<List<ProviderServiceEntity>> getProviderServices({
    int? serviceTypeId,
    int? serviceProviderId,
  }) async {
    final res = await apiService.get(
      url: ApiPath.getProviderServicesList(
        serviceTypeId: serviceTypeId,
        serviceProviderId: serviceProviderId,
      ),
      returnDataOnly: false,
    );
    return _asItemMaps(res)
        .map(ProviderServiceEntity.fromJson)
        .where((item) => item.isActive)
        .toList();
  }

  @override
  Future<List<ServiceProviderEntity>> getServiceProviders({
    int? serviceTypeId,
    String? search,
  }) async {
    List<ServiceProviderEntity> providers = const [];
    try {
      final res = await apiService.get(
        url: ApiPath.getServiceProvidersList(
          serviceTypeId: serviceTypeId,
          search: search,
        ),
        returnDataOnly: false,
      );
      providers = _asItemMaps(res).map(ServiceProviderEntity.fromJson).toList();
    } catch (_) {}

    if (providers.isEmpty) {
      providers = await _providersFromServices(serviceTypeId: serviceTypeId);
    }

    final query = search?.trim().toLowerCase();
    if (query == null || query.isEmpty) return providers;
    return providers
        .where(
          (provider) =>
              provider.companyName.toLowerCase().contains(query) ||
              provider.description.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<List<ServiceProviderEntity>> _providersFromServices({
    int? serviceTypeId,
  }) async {
    final services = await getProviderServices(serviceTypeId: serviceTypeId);
    final byId = <int, ServiceProviderEntity>{};
    for (final service in services) {
      final id = service.serviceProviderId > 0
          ? service.serviceProviderId
          : (service.provider?.id ?? 0);
      if (id <= 0) continue;
      final existing = byId[id];
      if (existing == null) {
        byId[id] = ServiceProviderEntity(
          id: id,
          companyName:
              service.provider?.companyName ?? service.name.localized(),
          description: service.description,
          address: '',
          phone: '',
          daysSinceJoin: 0,
          ordersCount: 0,
          coverImageUrl: service.provider?.coverImageUrl,
          serviceType: service.serviceType,
          ratingSummary: const VendorRatingSummaryEntity(count: 0),
          services: [service],
        );
      } else {
        byId[id] = ServiceProviderEntity(
          id: existing.id,
          companyName: existing.companyName,
          description: existing.description,
          address: existing.address,
          phone: existing.phone,
          daysSinceJoin: existing.daysSinceJoin,
          ordersCount: existing.ordersCount,
          coverImageUrl: existing.coverImageUrl,
          profileImageUrl: existing.profileImageUrl,
          serviceType: existing.serviceType,
          ratingSummary: existing.ratingSummary,
          ratings: existing.ratings,
          services: [...existing.services, service],
        );
      }
    }
    return byId.values.toList();
  }

  @override
  Future<ServiceProviderEntity> getServiceProvider(int serviceProviderId) async {
    final res = await apiService.get(
      url: ApiPath.getServiceProvider(serviceProviderId),
      returnDataOnly: true,
    );
    if (res is! Map) {
      throw Exception('Invalid service provider response');
    }
    return ServiceProviderEntity.fromJson(Map<String, dynamic>.from(res));
  }

  @override
  Future<bool> createServiceOrder(CreateServiceOrderParams params) async {
    await apiService.post(
      url: ApiPath.createServiceOrder,
      requestBody: FormData.fromMap({
        'provider_service_id': params.providerServiceId.toString(),
        'scheduled_date': params.scheduledDate,
        'scheduled_time': params.scheduledTime,
        'latitude': params.latitude.toString(),
        'longitude': params.longitude.toString(),
        'payment_method': params.paymentMethod,
        if (params.addressText != null && params.addressText!.trim().isNotEmpty)
          'address_text': params.addressText,
        if (params.customerNotes != null &&
            params.customerNotes!.trim().isNotEmpty)
          'customer_notes': params.customerNotes,
      }),
      returnDataOnly: false,
    );
    return true;
  }

  @override
  Future<PaginatedResponse<ServiceOrderEntity>> getMyServiceOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await apiService.get(
      url: ApiPath.getServiceOrdersList(page: page, perPage: perPage),
      returnDataOnly: false,
    );
    return parsePaginatedResponse(
      res,
      ServiceOrderEntity.fromJson,
    );
  }
}
