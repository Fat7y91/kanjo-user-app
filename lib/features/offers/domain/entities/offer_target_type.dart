enum OfferTargetType {
  category,
  vendorType,
  vendor,
  product;

  static OfferTargetType? tryParse(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'category':
        return OfferTargetType.category;
      case 'vendor_type':
      case 'vendor-type':
        return OfferTargetType.vendorType;
      case 'vendor':
        return OfferTargetType.vendor;
      case 'product':
        return OfferTargetType.product;
      default:
        return null;
    }
  }

  String toJson() {
    switch (this) {
      case OfferTargetType.category:
        return 'category';
      case OfferTargetType.vendorType:
        return 'vendor_type';
      case OfferTargetType.vendor:
        return 'vendor';
      case OfferTargetType.product:
        return 'product';
    }
  }
}
