import '../../domain/entities/vendor_rating_summary_entity.dart';
import '../../domain/entities/vendor_type_name_entity.dart';
import 'vendor_type_model.dart';

class VendorModel {
  final int id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? coverImageUrl;
  final int listingPosition;
  final String availabilityStatus;
  final bool isAcceptingOrders;
  final bool pricesIncludeVat;
  final int busyLateOrderDelayMinutes;
  final VendorRatingSummaryEntity ratingSummary;
  final VendorTypeModel type;
  final bool isServiceProvider;
  final double? deliveryFee;
  final double? distanceKm;

  const VendorModel({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.coverImageUrl,
    required this.listingPosition,
    required this.availabilityStatus,
    required this.isAcceptingOrders,
    required this.pricesIncludeVat,
    required this.busyLateOrderDelayMinutes,
    required this.ratingSummary,
    required this.type,
    this.isServiceProvider = false,
    this.deliveryFee,
    this.distanceKm,
  });

  String get imageUrl =>
      (coverImageUrl != null && coverImageUrl!.isNotEmpty)
          ? coverImageUrl!
          : (logoUrl ?? '');

  double get rating => ratingSummary.average ?? 0;

  int get reviewsCount => ratingSummary.count;

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    final typeJson = json['type'];
    return VendorModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString(),
      coverImageUrl: json['cover_image_url']?.toString(),
      listingPosition: json['listing_position'] is int
          ? json['listing_position'] as int
          : int.tryParse(json['listing_position']?.toString() ?? '') ?? 0,
      availabilityStatus: json['availability_status']?.toString() ?? '',
      isAcceptingOrders: json['is_accepting_orders'] != false,
      pricesIncludeVat: json['prices_include_vat'] == true,
      busyLateOrderDelayMinutes: json['busy_late_order_delay_minutes'] is int
          ? json['busy_late_order_delay_minutes'] as int
          : int.tryParse(
                  json['busy_late_order_delay_minutes']?.toString() ?? '') ??
              0,
      ratingSummary: VendorRatingSummaryEntity.fromJson(
        json['rating_summary'] is Map<String, dynamic>
            ? json['rating_summary'] as Map<String, dynamic>
            : null,
      ),
      type: typeJson is Map<String, dynamic>
          ? VendorTypeModel.fromJson(typeJson)
          : const VendorTypeModel(
              id: 0,
              key: '',
              name: VendorTypeNameEntity(ar: '', en: ''),
              returnsToVendor: false,
              tracksInventory: false,
              allowsProductAdditions: false,
              isActive: true,
              sortOrder: 0,
            ),
      isServiceProvider: json['is_service_provider'] == true,
      deliveryFee: _toDouble(json['delivery_fee']),
      distanceKm: _toDouble(json['distance_km']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'logo_url': logoUrl,
        'cover_image_url': coverImageUrl,
        'listing_position': listingPosition,
        'availability_status': availabilityStatus,
        'is_accepting_orders': isAcceptingOrders,
        'prices_include_vat': pricesIncludeVat,
        'busy_late_order_delay_minutes': busyLateOrderDelayMinutes,
        'rating_summary': ratingSummary.toJson(),
        'type': type.toJson(),
        'is_service_provider': isServiceProvider,
        'delivery_fee': deliveryFee,
        'distance_km': distanceKm,
      };
}
