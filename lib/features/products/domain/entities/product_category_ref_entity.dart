import 'localized_name_entity.dart';

class ProductCategoryRefEntity {
  final int id;
  final String slug;
  final LocalizedNameEntity name;

  const ProductCategoryRefEntity({
    required this.id,
    required this.slug,
    required this.name,
  });

  factory ProductCategoryRefEntity.fromJson(Map<String, dynamic> json) {
    return ProductCategoryRefEntity(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      slug: json['slug']?.toString() ?? '',
      name: LocalizedNameEntity.fromJson(
        json['name'] is Map<String, dynamic>
            ? json['name'] as Map<String, dynamic>
            : null,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name.toJson(),
      };
}
