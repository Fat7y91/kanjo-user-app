import 'package:heraj/features/products/domain/entities/localized_name_entity.dart';
import 'package:heraj/features/vendor/domain/entities/vendor_rating_summary_entity.dart';
import 'service_rating_entity.dart';
import 'service_schedule_entity.dart';
import 'service_type_entity.dart';
import 'service_zone_entity.dart';
import 'services_json.dart';

class ServiceProviderRefEntity {
  final int id;
  final String companyName;
  final String? coverImageUrl;

  const ServiceProviderRefEntity({
    required this.id,
    required this.companyName,
    this.coverImageUrl,
  });

  factory ServiceProviderRefEntity.fromJson(Map<String, dynamic> json) {
    return ServiceProviderRefEntity(
      id: asInt(json['id']),
      companyName: json['company_name']?.toString() ??
          json['name']?.toString() ??
          '',
      coverImageUrl: json['cover_image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'cover_image_url': coverImageUrl,
    };
  }
}

class ProviderServiceEntity {
  final int id;
  final int serviceProviderId;
  final ServiceTypeEntity serviceType;
  final LocalizedNameEntity name;
  final double cost;
  final int implementationPeriodDays;
  final String description;
  final bool isActive;
  final List<ServiceZoneEntity> serviceZones;
  final List<ServiceScheduleEntity> schedule;
  final ServiceProviderRefEntity? provider;

  const ProviderServiceEntity({
    required this.id,
    required this.serviceProviderId,
    required this.serviceType,
    required this.name,
    required this.cost,
    required this.implementationPeriodDays,
    required this.description,
    required this.isActive,
    this.serviceZones = const [],
    this.schedule = const [],
    this.provider,
  });

  factory ProviderServiceEntity.fromJson(Map<String, dynamic> json) {
    final typeJson = asMap(json['service_type']);
    final providerJson = asMap(json['provider']);
    return ProviderServiceEntity(
      id: asInt(json['id']),
      serviceProviderId: asInt(json['service_provider_id']),
      serviceType: typeJson != null
          ? ServiceTypeEntity.fromJson(typeJson)
          : const ServiceTypeEntity(
              id: 0,
              name: LocalizedNameEntity(ar: '', en: ''),
            ),
      name: localizedNameFrom(json['name']),
      cost: asDouble(json['cost']),
      implementationPeriodDays: asInt(json['implementation_period_days']),
      description: json['description']?.toString() ?? '',
      isActive: json['is_active'] != false,
      serviceZones: (json['service_zones'] as List?)
              ?.whereType<Map>()
              .map((e) => ServiceZoneEntity.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList() ??
          const [],
      schedule: (json['schedule'] as List?)
              ?.whereType<Map>()
              .map((e) => ServiceScheduleEntity.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList() ??
          const [],
      provider: providerJson == null
          ? null
          : ServiceProviderRefEntity.fromJson(providerJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_provider_id': serviceProviderId,
      'service_type': serviceType.toJson(),
      'name': name.toJson(),
      'cost': cost,
      'implementation_period_days': implementationPeriodDays,
      'description': description,
      'is_active': isActive,
      'service_zones': serviceZones.map((e) => e.toJson()).toList(),
      'schedule': schedule.map((e) => e.toJson()).toList(),
      if (provider != null) 'provider': provider!.toJson(),
    };
  }
}

class ServiceProviderEntity {
  final int id;
  final String companyName;
  final String description;
  final String address;
  final String phone;
  final int daysSinceJoin;
  final int ordersCount;
  final String? coverImageUrl;
  final String? profileImageUrl;
  final ServiceTypeEntity? serviceType;
  final VendorRatingSummaryEntity ratingSummary;
  final List<ServiceRatingEntity> ratings;
  final List<ProviderServiceEntity> services;

  const ServiceProviderEntity({
    required this.id,
    required this.companyName,
    required this.description,
    required this.address,
    required this.phone,
    required this.daysSinceJoin,
    required this.ordersCount,
    this.coverImageUrl,
    this.profileImageUrl,
    this.serviceType,
    required this.ratingSummary,
    this.ratings = const [],
    this.services = const [],
  });

  factory ServiceProviderEntity.fromJson(Map<String, dynamic> json) {
    final typeJson = asMap(json['service_type']);
    final rawName = json['company_name'] ?? json['name'];
    return ServiceProviderEntity(
      id: asInt(json['id']),
      companyName: rawName is Map
          ? localizedNameFrom(rawName).localized()
          : rawName?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      daysSinceJoin: asInt(json['days_since_join']),
      ordersCount: asInt(json['orders_count']),
      coverImageUrl: json['cover_image_url']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
      serviceType:
          typeJson == null ? null : ServiceTypeEntity.fromJson(typeJson),
      ratingSummary: VendorRatingSummaryEntity.fromJson(
        asMap(json['rating_summary']),
      ),
      ratings: (json['ratings'] as List?)
              ?.whereType<Map>()
              .map((e) => ServiceRatingEntity.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList() ??
          const [],
      services: (json['services'] as List?)
              ?.whereType<Map>()
              .map((e) => ProviderServiceEntity.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'description': description,
      'address': address,
      'phone': phone,
      'days_since_join': daysSinceJoin,
      'orders_count': ordersCount,
      'cover_image_url': coverImageUrl,
      'profile_image_url': profileImageUrl,
      if (serviceType != null) 'service_type': serviceType!.toJson(),
      'rating_summary': ratingSummary.toJson(),
      'ratings': ratings.map((e) => e.toJson()).toList(),
      'services': services.map((e) => e.toJson()).toList(),
    };
  }
}
