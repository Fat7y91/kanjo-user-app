enum SliderTargetType {
  home,
  product,
  vendor,
  vendorType,
  offer,
  category;

  static SliderTargetType? tryParse(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'home':
        return SliderTargetType.home;
      case 'product':
        return SliderTargetType.product;
      case 'vendor':
        return SliderTargetType.vendor;
      case 'vendor-type':
      case 'vendor_type':
        return SliderTargetType.vendorType;
      case 'offer':
        return SliderTargetType.offer;
      case 'category':
        return SliderTargetType.category;
      default:
        return null;
    }
  }

  String toJson() {
    switch (this) {
      case SliderTargetType.home:
        return 'home';
      case SliderTargetType.product:
        return 'product';
      case SliderTargetType.vendor:
        return 'vendor';
      case SliderTargetType.vendorType:
        return 'vendor-type';
      case SliderTargetType.offer:
        return 'offer';
      case SliderTargetType.category:
        return 'category';
    }
  }
}
