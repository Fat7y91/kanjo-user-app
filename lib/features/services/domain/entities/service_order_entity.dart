import 'package:heraj/features/products/domain/entities/localized_name_entity.dart';
import 'provider_service_entity.dart';
import 'services_json.dart';

enum ServiceOrderStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

class ServiceOrderEntity {
  const ServiceOrderEntity({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.paymentMethod,
    required this.totalPrice,
    required this.serviceName,
    required this.providerName,
    this.addressText = '',
    this.customerNotes,
    this.providerImageUrl,
    this.serviceTypeName = const LocalizedNameEntity(ar: '', en: ''),
  });

  final String id;
  final ServiceOrderStatus status;
  final DateTime createdAt;
  final String scheduledDate;
  final String scheduledTime;
  final String paymentMethod;
  final double totalPrice;
  final LocalizedNameEntity serviceName;
  final String providerName;
  final String addressText;
  final String? customerNotes;
  final String? providerImageUrl;
  final LocalizedNameEntity serviceTypeName;

  factory ServiceOrderEntity.fromJson(Map<String, dynamic> json) {
    final serviceJson =
        asMap(json['provider_service']) ?? asMap(json['service']);
    final providerJson = asMap(json['provider']) ??
        asMap(json['service_provider']) ??
        asMap(serviceJson?['provider']);
    final service =
        serviceJson == null ? null : ProviderServiceEntity.fromJson(serviceJson);
    final provider = providerJson == null
        ? null
        : ServiceProviderRefEntity.fromJson(providerJson);

    final name = service?.name ??
        localizedNameFrom(json['service_name'] ?? json['name']);

    return ServiceOrderEntity(
      id: json['id']?.toString() ?? '',
      status: serviceOrderStatusFromApi(json['status']?.toString()),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      scheduledDate: json['scheduled_date']?.toString() ?? '',
      scheduledTime: json['scheduled_time']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      totalPrice: asDouble(
        json['total'] ??
            json['amount'] ??
            json['cost'] ??
            json['total_price'] ??
            service?.cost,
      ),
      serviceName: name,
      providerName: provider?.companyName ??
          json['provider_name']?.toString() ??
          json['company_name']?.toString() ??
          '',
      addressText: json['address_text']?.toString() ??
          json['address']?.toString() ??
          '',
      customerNotes: json['customer_notes']?.toString() ??
          json['notes']?.toString(),
      providerImageUrl: provider?.coverImageUrl ??
          json['provider_image']?.toString() ??
          json['cover_image_url']?.toString(),
      serviceTypeName: service?.serviceType.name ??
          localizedNameFrom(json['service_type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'scheduled_date': scheduledDate,
      'scheduled_time': scheduledTime,
      'payment_method': paymentMethod,
      'total': totalPrice,
      'service_name': serviceName.toJson(),
      'provider_name': providerName,
      'address_text': addressText,
      'customer_notes': customerNotes,
      'cover_image_url': providerImageUrl,
      'service_type': serviceTypeName.toJson(),
    };
  }
}

ServiceOrderStatus serviceOrderStatusFromApi(String? status) {
  switch (status?.toLowerCase().trim()) {
    case 'confirmed':
    case 'accepted':
    case 'scheduled':
      return ServiceOrderStatus.confirmed;
    case 'in_progress':
    case 'in-progress':
    case 'ongoing':
      return ServiceOrderStatus.inProgress;
    case 'completed':
    case 'done':
    case 'delivered':
      return ServiceOrderStatus.completed;
    case 'cancelled':
    case 'canceled':
    case 'rejected':
      return ServiceOrderStatus.cancelled;
    default:
      return ServiceOrderStatus.pending;
  }
}
