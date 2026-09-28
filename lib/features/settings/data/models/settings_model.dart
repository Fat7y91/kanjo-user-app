class SettingsModel {
  final String appName;
  final String? appLogoUrl;
  final String? mobileSplashGifUrl;
  final double shippingPrice;
  final bool serviceProviderActive;
  final String? serviceProviderImageUrl;

  SettingsModel({
    required this.appName,
    this.appLogoUrl,
    this.mobileSplashGifUrl,
    this.shippingPrice = 0,
    this.serviceProviderActive = false,
    this.serviceProviderImageUrl,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['service_provider_image_url']?.toString().trim();
    return SettingsModel(
      appName: json['app_name']?.toString() ?? '',
      appLogoUrl: json['app_logo_url']?.toString(),
      mobileSplashGifUrl: json['mobile_splash_gif_url']?.toString(),
      shippingPrice: json['shipping_cost'] is String
          ? double.tryParse(json['shipping_cost'] ?? '0.0') ?? 0.0
          : (json['shipping_cost'] as num?)?.toDouble() ?? 0.0,
      serviceProviderActive: json['service_provider_active'] == true,
      serviceProviderImageUrl:
          (imageUrl == null || imageUrl.isEmpty) ? null : imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'app_name': appName,
        'app_logo_url': appLogoUrl,
        'mobile_splash_gif_url': mobileSplashGifUrl,
        'shipping_cost': shippingPrice,
        'service_provider_active': serviceProviderActive,
        'service_provider_image_url': serviceProviderImageUrl,
      };
}
