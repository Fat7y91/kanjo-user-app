class ProductGalleryItemEntity {
  final int id;
  final String imageUrl;
  final int sortOrder;

  const ProductGalleryItemEntity({
    required this.id,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory ProductGalleryItemEntity.fromJson(Map<String, dynamic> json) {
    return ProductGalleryItemEntity(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      imageUrl: json['image_url']?.toString() ?? '',
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse(json['sort_order']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_url': imageUrl,
        'sort_order': sortOrder,
      };
}
