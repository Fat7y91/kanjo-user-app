enum ShareLinkType {
  product('product'),
  offer('offer'),
  vendor('vendor'),
  serviceProvider('service_provider'),
  serviceType('service_type'),
  providerService('provider_service');

  const ShareLinkType(this.apiValue);

  final String apiValue;

  static ShareLinkType fromApi(String value) {
    return ShareLinkType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => ShareLinkType.product,
    );
  }
}
