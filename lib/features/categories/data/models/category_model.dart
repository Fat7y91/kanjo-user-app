import '../../domain/entities/category_name_entity.dart';

class CategoryModel {
  final int id;
  final int? parentId;
  final int? vendorId;
  final int? vendorTypeId;
  final String scope;
  final String slug;
  final CategoryNameEntity name;
  final String? image;
  final String? imageUrl;
  final int productsCount;
  final bool isActive;
  final int sortOrder;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    this.parentId,
    this.vendorId,
    this.vendorTypeId,
    required this.scope,
    required this.slug,
    required this.name,
    this.image,
    this.imageUrl,
    required this.productsCount,
    required this.isActive,
    required this.sortOrder,
    this.children = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final childrenRaw = json['children'];
    return CategoryModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      parentId: json['parent_id'] is int
          ? json['parent_id'] as int
          : int.tryParse(json['parent_id']?.toString() ?? ''),
      vendorId: json['vendor_id'] is int
          ? json['vendor_id'] as int
          : int.tryParse(json['vendor_id']?.toString() ?? ''),
      vendorTypeId: json['vendor_type_id'] is int
          ? json['vendor_type_id'] as int
          : int.tryParse(json['vendor_type_id']?.toString() ?? ''),
      scope: json['scope']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      name: json['name'] is Map<String, dynamic>
          ? CategoryNameEntity.fromJson(json['name'] as Map<String, dynamic>)
          : const CategoryNameEntity(ar: '', en: ''),
      image: json['image']?.toString(),
      imageUrl: json['image_url']?.toString(),
      productsCount: json['products_count'] is int
          ? json['products_count'] as int
          : int.tryParse(json['products_count']?.toString() ?? '') ?? 0,
      isActive: json['is_active'] != false,
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse(json['sort_order']?.toString() ?? '') ?? 0,
      children: childrenRaw is List
          ? childrenRaw
              .whereType<Map>()
              .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'vendor_id': vendorId,
      'vendor_type_id': vendorTypeId,
      'scope': scope,
      'slug': slug,
      'name': name.toJson(),
      'image': image,
      'image_url': imageUrl,
      'products_count': productsCount,
      'is_active': isActive,
      'sort_order': sortOrder,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}
