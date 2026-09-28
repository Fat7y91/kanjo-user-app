import '../../domain/entities/vendor_type_name_entity.dart';

class VendorTypeModel {
  final int id;
  final String key;
  final VendorTypeNameEntity name;
  final String? image;
  final String? imageUrl;
  final bool returnsToVendor;
  final bool tracksInventory;
  final bool allowsProductAdditions;
  final bool isActive;
  final int sortOrder;

  const VendorTypeModel({
    required this.id,
    required this.key,
    required this.name,
    this.image,
    this.imageUrl,
    required this.returnsToVendor,
    required this.tracksInventory,
    required this.allowsProductAdditions,
    required this.isActive,
    required this.sortOrder,
  });

  factory VendorTypeModel.fromJson(Map<String, dynamic> json) {
    return VendorTypeModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      key: json['key']?.toString() ?? '',
      name: json['name'] is Map<String, dynamic>
          ? VendorTypeNameEntity.fromJson(json['name'] as Map<String, dynamic>)
          : const VendorTypeNameEntity(ar: '', en: ''),
      image: json['image']?.toString(),
      imageUrl: json['image_url']?.toString(),
      returnsToVendor: json['returns_to_vendor'] == true,
      tracksInventory: json['tracks_inventory'] == true,
      allowsProductAdditions: json['allows_product_additions'] == true,
      isActive: json['is_active'] != false,
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse(json['sort_order']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name.toJson(),
      'image': image,
      'image_url': imageUrl,
      'returns_to_vendor': returnsToVendor,
      'tracks_inventory': tracksInventory,
      'allows_product_additions': allowsProductAdditions,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}
