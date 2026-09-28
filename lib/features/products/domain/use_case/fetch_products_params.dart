class FetchProductsParams {
  final int vendorId;
  final int? categoryId;
  final int page;
  final int perPage;

  const FetchProductsParams({
    required this.vendorId,
    this.categoryId,
    this.page = 1,
    this.perPage = 20,
  });

  FetchProductsParams copyWith({
    int? vendorId,
    int? categoryId,
    int? page,
    int? perPage,
  }) {
    return FetchProductsParams(
      vendorId: vendorId ?? this.vendorId,
      categoryId: categoryId ?? this.categoryId,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FetchProductsParams &&
        other.vendorId == vendorId &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode => Object.hash(vendorId, categoryId);
}
