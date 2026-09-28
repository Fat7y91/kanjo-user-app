class FetchVendorsParams {
  final int? vendorTypeId;
  final int? categoryId;
  final String? search;
  final bool isFeatured;
  final bool offers;
  final double? latitude;
  final double? longitude;
  final int? zoneId;
  final int page;
  final int perPage;

  const FetchVendorsParams({
    this.vendorTypeId,
    this.categoryId,
    this.search,
    this.isFeatured = false,
    this.offers = false,
    this.latitude,
    this.longitude,
    this.zoneId,
    this.page = 1,
    this.perPage = 20,
  });
}
