import 'package:heraj/core/service/theme_service/theme_service.dart';
import 'package:heraj/features/address/data/data_source/address_data_source.dart';
import 'package:heraj/features/address/data/repo/address_repo_imp.dart';
import 'package:heraj/features/address/domain/repo/address_repo.dart';
import 'package:heraj/features/home/domain/repositories/partner_repo.dart';
import 'package:heraj/features/home/domain/use_case/fetch_partner_use_case.dart';
import 'package:heraj/features/store/data/data_source/store_data_source.dart';
import 'package:heraj/features/store/data/repositories/store_repo_impl.dart';
import 'package:heraj/features/store/domain/repositories/store_repository.dart';
import 'package:heraj/features/store/domain/use_case/fetch_store_categories_use_case.dart';
import 'package:heraj/features/store/domain/use_case/fetch_store_sub_categories_use_case.dart';
import 'package:heraj/features/home/data/repostories/home_repo_imp.dart';
import 'package:heraj/features/home/domain/repositories/home_repo.dart';
import 'package:heraj/features/home/domain/use_case/fetch_home_sections_use_case.dart';
import 'package:heraj/features/vendor/data/data_source/vendor_data_source.dart';
import 'package:heraj/features/vendor/data/repo/vendor_repo_imp.dart';
import 'package:heraj/features/vendor/domain/repo/vendor_repo.dart';
import 'package:heraj/features/vendor/domain/use_case/fetch_vendor_types_use_case.dart';
import 'package:heraj/features/vendor/domain/use_case/fetch_vendors_use_case.dart';
import 'package:heraj/features/categories/data/data_source/categories_data_source.dart';
import 'package:heraj/features/categories/data/repo/categories_repo_imp.dart';
import 'package:heraj/features/categories/domain/repo/categories_repo.dart';
import 'package:heraj/features/categories/domain/use_case/fetch_categories_by_vendor_type_use_case.dart';
import 'package:heraj/features/products/data/data_source/products_data_source.dart';
import 'package:heraj/features/products/data/repo/products_repo_imp.dart';
import 'package:heraj/features/products/domain/repo/products_repo.dart';
import 'package:heraj/features/products/domain/use_case/search_products_use_case.dart';
import 'package:heraj/features/products/domain/use_case/get_product_details_use_case.dart';
import 'package:heraj/features/products/domain/use_case/fetch_products_use_case.dart';
import 'package:heraj/features/search/data/data_source/search_data_source.dart';
import 'package:heraj/features/search/data/data_source/search_data_source_imp.dart';
import 'package:heraj/features/search/data/repo/search_repo_imp.dart';
import 'package:heraj/features/search/domain/repo/search_repo.dart';
import 'package:heraj/features/search/domain/use_case/search_app_use_case.dart';
import 'package:heraj/features/favorites/data/data_source/favorites_data_source.dart';
import 'package:heraj/features/favorites/data/repo/favorites_repo_imp.dart';
import 'package:heraj/features/favorites/domain/repo/favorites_repo.dart';
import 'package:heraj/features/favorites/domain/use_case/fetch_wishlist_use_case.dart';
import 'package:heraj/features/favorites/domain/use_case/remove_wishlist_item_use_case.dart';
import 'package:heraj/features/favorites/domain/use_case/toggle_wishlist_use_case.dart';
import 'package:heraj/features/cart/data/data_source/cart_data_source.dart';
import 'package:heraj/features/cart/data/repo/cart_repo_imp.dart';
import 'package:heraj/features/cart/domain/repo/cart_repo.dart';
import 'package:heraj/features/cart/domain/use_case/add_to_cart_use_case.dart';
import 'package:heraj/features/cart/domain/use_case/apply_coupon_use_case.dart';
import 'package:heraj/features/cart/domain/use_case/checkout_use_case.dart';
import 'package:heraj/features/cart/domain/use_case/fetch_cart_use_case.dart';
import 'package:heraj/features/cart/domain/use_case/remove_cart_item_use_case.dart';
import 'package:heraj/features/cart/domain/use_case/update_cart_item_quantity_use_case.dart';
import 'package:heraj/features/bundle_order/data/data_source/bundle_order_data_source.dart';
import 'package:heraj/features/bundle_order/data/repo/bundle_order_repo_imp.dart';
import 'package:heraj/features/bundle_order/domain/repo/bundle_order_repo.dart';
import 'package:heraj/features/bundle_order/domain/use_case/add_my_cart_to_bundle_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/cancel_bundle_order_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/create_bundle_from_cart_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/list_my_bundle_orders_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/remove_my_bundle_item_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/show_bundle_by_code_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/submit_bundle_use_case.dart';
import 'package:heraj/features/wallet/data/data_source/wallet_data_source.dart';
import 'package:heraj/features/wallet/data/repo/wallet_repo_imp.dart';
import 'package:heraj/features/wallet/domain/repo/wallet_repo.dart';
import 'package:heraj/features/wallet/domain/use_case/fetch_wallet_use_case.dart';
import 'package:heraj/features/settings/data/data_source/policy_data_source.dart';
import 'package:heraj/features/settings/data/repo/policy_repo_imp.dart';
import 'package:heraj/features/settings/domain/repo/policy_repo.dart';
import 'package:heraj/features/settings/domain/use_case/fetch_policy_use_case.dart';
import 'package:heraj/features/settings/data/data_source/settings_data_source.dart';
import 'package:heraj/features/settings/data/repo/settings_repo_imp.dart';
import 'package:heraj/features/settings/domain/repo/settings_repo.dart';
import 'package:heraj/features/settings/domain/use_case/fetch_settings_use_case.dart';
import 'package:local_auth/local_auth.dart';
import 'core/service/socket_service/conversation_realtime_service.dart';
import 'core/service/location_service/location_service.dart';
import 'core/service/remote_config_service.dart';
import 'core/service/image_picker_cropper.dart';
import 'core/service/local_data_manager.dart';
import 'core/service/localization_service/localization_service.dart';
import 'core/service/webservice/dio_helper.dart';
import 'core/service/fcm_token_service.dart';
import 'features/address/domain/use_case/address_use_cases.dart';
import 'features/auth/data/data_sources/auth_data_source.dart';
import 'features/auth/data/repositories/auth_repo_impl.dart';
import 'features/auth/domain/repositories/auth_repo.dart';
import 'features/auth/domain/use_cases/login_user_use_case.dart';
import 'features/auth/domain/use_cases/register_user_use_case.dart';
import 'features/auth/domain/use_cases/select_role_use_case.dart';
import 'features/forget_password/data/data_sources/forget_password_data_source.dart';
import 'features/forget_password/data/repositories/forget_password_repo_impl.dart';
import 'features/forget_password/domain/repositories/forget_password_repo.dart';
import 'features/home/data/data_source/home_data_source.dart';
import 'features/notifications/data/data_source/notification_data_source.dart';
import 'features/notifications/data/repo/notification_repo_imp.dart';
import 'features/notifications/domain/repos/notification_repo.dart';
import 'features/notifications/domain/use_case/fetch_notifications_use_case.dart';
import 'features/verify/data/data_sources/verification_data_source.dart';
import 'features/verify/data/repositories/forget_verify_repo_impl.dart';
import 'features/verify/data/repositories/verify_repo_impl.dart';
import 'features/verify/domain/repositories/verification_repo.dart';
import 'features/home/data/data_source/ads_data_source.dart';
import 'features/home/data/data_source/slider_data_source.dart';
import 'features/home/data/repostories/ads_repo_imp.dart';
import 'features/home/data/repostories/slider_repo_imp.dart';
import 'features/home/domain/repositories/ads_repo.dart';
import 'features/home/domain/repositories/slider_repo.dart';
import 'features/home/domain/use_case/fetch_ads_use_case.dart';
import 'features/home/domain/use_case/fetch_sliders_use_case.dart';
import 'features/notifications/domain/use_case/fetch_seen_use_case.dart';
import 'features/notifications/domain/use_case/get_unread_count_use_case.dart';
import 'features/notifications/domain/use_case/mark_all_as_read_use_case.dart';
import 'features/profile/data/data_sources/update_profile_date_source.dart';
import 'features/profile/data/data_sources/upload_file_data_source.dart';
import 'features/profile/data/repositories/update_profile_repo_impl.dart';
import 'features/profile/data/repositories/upload_file_repo_impl.dart';
import 'features/profile/domain/repositories/update_profile_repo.dart';
import 'features/profile/domain/repositories/upload_file_repo.dart';
import 'features/profile/domain/use_cases/update_profile_use_case.dart';
import 'features/profile/domain/use_cases/upload_file_use_case.dart';
import 'features/orders/data/data_sources/orders_data_source.dart';
import 'features/orders/data/data_sources/orders_data_source_impl.dart';
import 'features/orders/data/repositories/orders_repository_impl.dart';
import 'features/orders/domain/repositories/orders_repository.dart';
import 'features/orders/domain/use_cases/get_my_orders_use_case.dart';
import 'features/orders/domain/use_cases/get_order_details_use_case.dart';
import 'features/orders/domain/use_cases/cancel_order_use_case.dart';
import 'features/orders/domain/use_cases/create_refund_request_use_case.dart';
import 'features/orders/domain/use_cases/reorder_order_use_case.dart';
import 'features/rating/data/data_source/rating_data_source.dart';
import 'features/rating/data/repo/rating_repo_imp.dart';
import 'features/rating/domain/repo/rating_repo.dart';
import 'features/rating/domain/use_case/rate_delivery_partner_use_case.dart';
import 'features/rating/domain/use_case/rate_vendor_use_case.dart';
import 'features/games/data/data_source/games_data_source.dart';
import 'features/games/data/repo/games_repo_imp.dart';
import 'features/games/domain/repo/games_repo.dart';
import 'features/games/domain/use_case/earn_rewards_use_case.dart';
import 'features/games/domain/use_case/fetch_game_config_use_case.dart';
import 'features/games/domain/use_case/fetch_rewards_balance_use_case.dart';
import 'features/games/domain/use_case/fetch_rewards_transactions_use_case.dart';
import 'features/rewards/data/data_source/rewards_data_source.dart';
import 'features/rewards/data/repo/rewards_repo_imp.dart';
import 'features/rewards/domain/repo/rewards_repo.dart';
import 'features/rewards/domain/use_case/fetch_rewards_use_case.dart';
import 'features/offers/data/data_source/offers_data_source.dart';
import 'features/offers/data/repo/offers_repo_imp.dart';
import 'features/offers/domain/repo/offers_repo.dart';
import 'features/offers/domain/use_case/fetch_offers_use_case.dart';
import 'features/support_tickets/data/data_source/support_tickets_data_source.dart';
import 'features/support_tickets/data/repo/support_tickets_repo_imp.dart';
import 'features/support_tickets/domain/repo/support_tickets_repo.dart';
import 'features/support_tickets/domain/use_case/support_tickets_use_cases.dart';
import 'features/package_shipment/data/data_source/package_shipment_data_source.dart';
import 'features/package_shipment/data/repo/package_shipment_repo_imp.dart';
import 'features/package_shipment/domain/repo/package_shipment_repo.dart';
import 'features/package_shipment/domain/use_case/package_shipment_use_cases.dart';
import 'core/service/deep_linking_service/deep_linking_service.dart';
import 'core/service/share_service.dart';
import 'features/share/data/data_source/share_links_data_source.dart';
import 'features/share/data/repo/share_links_repo_imp.dart';
import 'features/share/domain/repo/share_links_repo.dart';
import 'features/share/domain/use_case/create_share_link_use_case.dart';
import 'features/share/domain/use_case/resolve_share_link_use_case.dart';
import 'features/location/data/data_source/location_data_source.dart';
import 'features/location/data/repo/location_repo_imp.dart';
import 'features/location/domain/repo/location_repo.dart';
import 'features/location/domain/use_case/fetch_cities_use_case.dart';
import 'features/location/domain/use_case/fetch_districts_use_case.dart';
import 'features/location/domain/use_case/fetch_neighborhoods_use_case.dart';
import 'features/location/domain/use_case/fetch_delivery_zones_use_case.dart';
import 'features/conversations/data/data_source/conversations_data_source.dart';
import 'features/conversations/data/repo/conversations_repo_imp.dart';
import 'features/conversations/domain/repo/conversations_repo.dart';
import 'features/conversations/domain/use_case/accept_conversation_quote_use_case.dart';
import 'features/conversations/domain/use_case/fetch_conversation_messages_use_case.dart';
import 'features/conversations/domain/use_case/fetch_conversations_use_case.dart';
import 'features/conversations/domain/use_case/send_conversation_message_use_case.dart';
import 'features/conversations/domain/use_case/start_conversation_use_case.dart';
import 'features/service_chats/data/data_source/service_chats_data_source.dart';
import 'features/service_chats/data/repo/service_chats_repo_imp.dart';
import 'features/service_chats/domain/repo/service_chats_repo.dart';
import 'features/service_chats/domain/use_case/fetch_service_chat_messages_use_case.dart';
import 'features/service_chats/domain/use_case/fetch_service_conversations_use_case.dart';
import 'features/service_chats/domain/use_case/send_service_chat_message_use_case.dart';
import 'features/service_chats/domain/use_case/start_service_conversation_use_case.dart';
import 'features/services/data/data_source/services_data_source.dart';
import 'features/services/data/repo/services_repo_imp.dart';
import 'features/services/domain/repo/services_repo.dart';
import 'features/services/domain/use_case/create_service_order_use_case.dart';
import 'features/services/domain/use_case/fetch_provider_services_use_case.dart';
import 'features/services/domain/use_case/fetch_service_provider_use_case.dart';
import 'features/services/domain/use_case/fetch_service_providers_use_case.dart';
import 'features/services/domain/use_case/fetch_service_types_use_case.dart';
import 'features/services/domain/use_case/get_my_service_orders_use_case.dart';
import 'main.dart';

Future setupLocator() async {
  //DATABASE
  getIt.registerSingleton<LocalDataManager>(
      await GetStorageManagerImpl().init());

  //NETWORK
  getIt.registerSingleton<ApiService>(ApiService());
  //FCM TOKEN SERVICE
  getIt.registerLazySingleton<FCMTokenService>(
      () => FCMTokenService(getIt<ApiService>()));
  //LOCALIZATION
  getIt.registerSingleton<LocaleService>(
      LocaleService(getIt<LocalDataManager>()));
  //THEME
  getIt
      .registerSingleton<ThemeService>(ThemeService(getIt<LocalDataManager>()));
  //IMAGE PICKER
  getIt.registerLazySingleton<ImagePickerService>(
      () => ImagePickerServiceImpl());

  getIt.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());
  getIt.registerLazySingleton<RemoteConfigService>(() => RemoteConfigService());
  getIt.registerLazySingleton<LocationService>(() => LocationService());

  /// notifications entity
  getIt.registerLazySingleton<NotificationDataSource>(
      () => NotificationDataSourceImp(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<NotificationRepo>(() => NotificationRepoImp(
      notificationDataSource: getIt<NotificationDataSource>()));
  getIt.registerLazySingleton<FetchNotificationUseCase>(() =>
      FetchNotificationUseCase(notificationRepo: getIt<NotificationRepo>()));
  getIt.registerLazySingleton<SeenNotificationUseCase>(() =>
      SeenNotificationUseCase(notificationRepo: getIt<NotificationRepo>()));
  getIt.registerLazySingleton<GetUnreadCountUseCase>(
      () => GetUnreadCountUseCase(notificationRepo: getIt<NotificationRepo>()));
  getIt.registerLazySingleton<MarkAllAsReadUseCase>(
      () => MarkAllAsReadUseCase(notificationRepo: getIt<NotificationRepo>()));

  /// Settings entity
  getIt.registerLazySingleton<PrivacyPolicyDataSource>(
      () => PrivacyPolicyDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<PrivacyPolicyRepo>(() => PrivacyPolicyRepoImp(
      privacyPolicyDataSource: getIt<PrivacyPolicyDataSource>()));
  getIt.registerLazySingleton<FetchPolicyUseCase>(
      () => FetchPolicyUseCase(policyRepo: getIt<PrivacyPolicyRepo>()));
  getIt.registerLazySingleton<FetchWhoAreWeUseCase>(
      () => FetchWhoAreWeUseCase(policyRepo: getIt<PrivacyPolicyRepo>()));
  getIt.registerLazySingleton<SettingsDataSource>(
      () => SettingsDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<SettingsRepo>(
      () => SettingsRepoImpl(dataSource: getIt<SettingsDataSource>()));
  getIt.registerLazySingleton<FetchSettingsUseCase>(
      () => FetchSettingsUseCase(policyRepo: getIt<SettingsRepo>()));

  /// ads entity
  getIt.registerLazySingleton<AdsDataSource>(
      () => AdsDataSourceImp(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<AdsRepo>(
      () => AdsRepoImp(adsDataSource: getIt<AdsDataSource>()));
  getIt.registerLazySingleton<FetchAdsUseCase>(
      () => FetchAdsUseCase(adsRepo: getIt<AdsRepo>()));
  getIt.registerLazySingleton<SliderDataSource>(
      () => SliderDataSourceImp(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<SliderRepo>(
      () => SliderRepoImp(sliderDataSource: getIt<SliderDataSource>()));
  getIt.registerLazySingleton<FetchSlidersUseCase>(
      () => FetchSlidersUseCase(sliderRepo: getIt<SliderRepo>()));
  getIt.registerLazySingleton<FetchPartnersUseCase>(
      () => FetchPartnersUseCase(partnerRepo: getIt<PartnerRepo>()));
  getIt.registerLazySingleton<FetchTestimonialsUseCase>(
      () => FetchTestimonialsUseCase(partnerRepo: getIt<PartnerRepo>()));
  getIt.registerLazySingleton<HomeDataSource>(
      () => HomeDummyDataSourceImpl());
  getIt.registerLazySingleton<HomeRepository>(() =>
      HomeSectionsRepositoryImpl(dataSource: getIt<HomeDataSource>()));
  getIt.registerLazySingleton<GetHomeSectionsContentUseCase>(() =>
      GetHomeSectionsContentUseCase(repository: getIt<HomeRepository>()));

  /// vendor
  getIt.registerLazySingleton<VendorDataSource>(
      () => VendorDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<VendorRepo>(
      () => VendorRepoImp(dataSource: getIt<VendorDataSource>()));
  getIt.registerLazySingleton<FetchVendorTypesUseCase>(
      () => FetchVendorTypesUseCase(vendorRepo: getIt<VendorRepo>()));
  getIt.registerLazySingleton<FetchVendorsUseCase>(
      () => FetchVendorsUseCase(vendorRepo: getIt<VendorRepo>()));

  /// categories
  getIt.registerLazySingleton<CategoriesDataSource>(
      () => CategoriesDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<CategoriesRepo>(
      () => CategoriesRepoImp(dataSource: getIt<CategoriesDataSource>()));
  getIt.registerLazySingleton<FetchCategoriesByVendorTypeUseCase>(() =>
      FetchCategoriesByVendorTypeUseCase(
          categoriesRepo: getIt<CategoriesRepo>()));

  /// products
  getIt.registerLazySingleton<ProductsDataSource>(
      () => ProductsDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<ProductsRepo>(
      () => ProductsRepoImp(dataSource: getIt<ProductsDataSource>()));
  getIt.registerLazySingleton<SearchProductsUseCase>(
      () => SearchProductsUseCase(productsRepo: getIt<ProductsRepo>()));
  getIt.registerLazySingleton<FetchProductsUseCase>(
      () => FetchProductsUseCase(productsRepo: getIt<ProductsRepo>()));
  getIt.registerLazySingleton<GetProductDetailsUseCase>(
      () => GetProductDetailsUseCase(productsRepo: getIt<ProductsRepo>()));

  /// app search (products + vendors)
  getIt.registerLazySingleton<SearchDataSource>(
      () => SearchDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<SearchRepo>(
      () => SearchRepoImp(dataSource: getIt<SearchDataSource>()));
  getIt.registerLazySingleton<SearchAppUseCase>(
      () => SearchAppUseCase(searchRepo: getIt<SearchRepo>()));

  /// favorites / wishlist
  getIt.registerLazySingleton<FavoritesDataSource>(
      () => FavoritesDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<FavoritesRepo>(
      () => FavoritesRepoImp(dataSource: getIt<FavoritesDataSource>()));
  getIt.registerLazySingleton<FetchWishlistUseCase>(
      () => FetchWishlistUseCase(favoritesRepo: getIt<FavoritesRepo>()));
  getIt.registerLazySingleton<ToggleWishlistUseCase>(
      () => ToggleWishlistUseCase(favoritesRepo: getIt<FavoritesRepo>()));
  getIt.registerLazySingleton<RemoveWishlistItemUseCase>(
      () => RemoveWishlistItemUseCase(favoritesRepo: getIt<FavoritesRepo>()));

  /// cart
  getIt.registerLazySingleton<CartDataSource>(
      () => CartDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<CartRepo>(
      () => CartRepoImp(dataSource: getIt<CartDataSource>()));
  getIt.registerLazySingleton<FetchCartUseCase>(
      () => FetchCartUseCase(cartRepo: getIt<CartRepo>()));
  getIt.registerLazySingleton<AddToCartUseCase>(
      () => AddToCartUseCase(cartRepo: getIt<CartRepo>()));
  getIt.registerLazySingleton<UpdateCartItemQuantityUseCase>(
      () => UpdateCartItemQuantityUseCase(cartRepo: getIt<CartRepo>()));
  getIt.registerLazySingleton<RemoveCartItemUseCase>(
      () => RemoveCartItemUseCase(cartRepo: getIt<CartRepo>()));
  getIt.registerLazySingleton<ApplyCouponUseCase>(
      () => ApplyCouponUseCase(cartRepo: getIt<CartRepo>()));
  getIt.registerLazySingleton<CheckoutUseCase>(
      () => CheckoutUseCase(cartRepo: getIt<CartRepo>()));

  /// bundle orders
  getIt.registerLazySingleton<BundleOrderDataSource>(
      () => BundleOrderDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<BundleOrderRepo>(
      () => BundleOrderRepoImp(dataSource: getIt<BundleOrderDataSource>()));
  getIt.registerLazySingleton<ListMyBundleOrdersUseCase>(
      () => ListMyBundleOrdersUseCase(bundleOrderRepo: getIt<BundleOrderRepo>()));
  getIt.registerLazySingleton<CreateBundleFromCartUseCase>(() =>
      CreateBundleFromCartUseCase(bundleOrderRepo: getIt<BundleOrderRepo>()));
  getIt.registerLazySingleton<ShowBundleByCodeUseCase>(
      () => ShowBundleByCodeUseCase(bundleOrderRepo: getIt<BundleOrderRepo>()));
  getIt.registerLazySingleton<AddMyCartToBundleUseCase>(
      () => AddMyCartToBundleUseCase(bundleOrderRepo: getIt<BundleOrderRepo>()));
  getIt.registerLazySingleton<RemoveMyBundleItemUseCase>(
      () => RemoveMyBundleItemUseCase(bundleOrderRepo: getIt<BundleOrderRepo>()));
  getIt.registerLazySingleton<CancelBundleOrderUseCase>(
      () => CancelBundleOrderUseCase(bundleOrderRepo: getIt<BundleOrderRepo>()));
  getIt.registerLazySingleton<SubmitBundleUseCase>(
      () => SubmitBundleUseCase(bundleOrderRepo: getIt<BundleOrderRepo>()));

  /// wallet
  getIt.registerLazySingleton<WalletDataSource>(
      () => WalletDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<WalletRepo>(
      () => WalletRepoImp(dataSource: getIt<WalletDataSource>()));
  getIt.registerLazySingleton<FetchWalletUseCase>(
      () => FetchWalletUseCase(walletRepo: getIt<WalletRepo>()));

  /// store entity
  getIt.registerLazySingleton<StoreDataSource>(() => StoreDummyDataSourceImpl());
  getIt.registerLazySingleton<StoreRepository>(
      () => StoreRepoImpl(dataSource: getIt<StoreDataSource>()));
  getIt.registerLazySingleton<FetchStoreCategoriesUseCase>(
      () => FetchStoreCategoriesUseCase(repository: getIt<StoreRepository>()));
  getIt.registerLazySingleton<FetchStoreSubCategoriesUseCase>(() =>
      FetchStoreSubCategoriesUseCase(repository: getIt<StoreRepository>()));

  /// Address entity
  getIt.registerLazySingleton<AddressDataSource>(
      () => AddressDataSourceImp(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<AddressRepo>(
      () => AddressRepoImp(addressDataSource: getIt<AddressDataSource>()));
  getIt.registerLazySingleton<FetchAddressesUseCase>(
      () => FetchAddressesUseCase(getIt<AddressRepo>()));
  getIt.registerLazySingleton<AddAddressUseCase>(
      () => AddAddressUseCase(getIt<AddressRepo>()));
  getIt.registerLazySingleton<UpdateAddressUseCase>(
      () => UpdateAddressUseCase(getIt<AddressRepo>()));
  getIt.registerLazySingleton<DeleteAddressUseCase>(
      () => DeleteAddressUseCase(getIt<AddressRepo>()));
  getIt.registerLazySingleton<SetDefaultAddressUseCase>(
      () => SetDefaultAddressUseCase(getIt<AddressRepo>()));

  /// Verification
  getIt.registerLazySingleton<VerificationDataSource>(
      () => VerifiyDataSourceImpl(getIt<ApiService>()));

  getIt.registerFactoryParam<VerificationRepo, String, String?>(
      (param1, param2) => VerifyRepoImpl(
            dataSource: getIt<VerificationDataSource>(),
            sendTo: param1,
          ));

  /// auth
  getIt.registerLazySingleton<AuthDataSource>(
      () => AuthDataSourceImpl(getIt<ApiService>()));
  getIt.registerLazySingleton<AuthRepo>(
      () => AuthRepoImpl(getIt<AuthDataSource>()));
  getIt.registerLazySingleton<LoginUserUseCase>(
      () => LoginUserUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<RegisterUserUseCase>(
      () => RegisterUserUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<VendorRegisterUserUseCase>(
      () => VendorRegisterUserUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<SelectRoleUseCase>(
      () => SelectRoleUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<PreLoginUserUseCase>(
      () => PreLoginUserUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<SendOtpUseCase>(
      () => SendOtpUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<VerifyOtpUseCase>(
      () => VerifyOtpUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<SendEmailVerificationUseCase>(
      () => SendEmailVerificationUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<SendPhoneVerificationUseCase>(
      () => SendPhoneVerificationUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<VerifyEmailCodeUseCase>(
      () => VerifyEmailCodeUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<VerifyPhoneCodeUseCase>(
      () => VerifyPhoneCodeUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<SocialLoginUserUseCase>(
      () => SocialLoginUserUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<LogOutUserUseCase>(
      () => LogOutUserUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<DeleteAccountUseCase>(
      () => DeleteAccountUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<ForgotPasswordUseCase>(
      () => ForgotPasswordUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(getIt<AuthRepo>()));

  /// upload
  getIt.registerLazySingleton<UploadFileDataSource>(
      () => UploadFileDataSourceImpl(getIt<ApiService>())); // upload
  getIt.registerLazySingleton<UploadFileRepo>(
      () => UploadFileRepoImpl(getIt<UploadFileDataSource>()));
  getIt.registerLazySingleton<UploadFileUseCase>(
      () => UploadFileUseCase(getIt<UploadFileRepo>()));

  /// update_profile
  getIt.registerLazySingleton<UpdateProfileDataSource>(
      () => UpdateProfileDataSourceImpl(getIt<ApiService>()));
  getIt.registerLazySingleton<UpdateProfileRepo>(
      () => UpdateProfileRepoImpl(getIt<UpdateProfileDataSource>()));
  getIt.registerLazySingleton<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(getIt<UpdateProfileRepo>()));

  /// orders
  getIt.registerLazySingleton<OrdersDataSource>(
      () => OrdersDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(dataSource: getIt<OrdersDataSource>()));
  getIt.registerLazySingleton<GetMyOrdersUseCase>(
      () => GetMyOrdersUseCase(repository: getIt<OrdersRepository>()));
  getIt.registerLazySingleton<GetOrderDetailsUseCase>(
      () => GetOrderDetailsUseCase(repository: getIt<OrdersRepository>()));
  getIt.registerLazySingleton<ReorderOrderUseCase>(
      () => ReorderOrderUseCase(repository: getIt<OrdersRepository>()));
  getIt.registerLazySingleton<CancelOrderUseCase>(
      () => CancelOrderUseCase(repository: getIt<OrdersRepository>()));
  getIt.registerLazySingleton<CreateRefundRequestUseCase>(
      () => CreateRefundRequestUseCase(repository: getIt<OrdersRepository>()));

  /// rating
  getIt.registerLazySingleton<RatingDataSource>(
      () => RatingDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<RatingRepo>(
      () => RatingRepoImp(dataSource: getIt<RatingDataSource>()));
  getIt.registerLazySingleton<RateVendorUseCase>(
      () => RateVendorUseCase(ratingRepo: getIt<RatingRepo>()));
  getIt.registerLazySingleton<RateDeliveryPartnerUseCase>(
      () => RateDeliveryPartnerUseCase(ratingRepo: getIt<RatingRepo>()));

  getIt.registerLazySingleton<VerificationDataSource>(
      instanceName: "checkphone",
      () => CheckPhoneDataSourceImpl(getIt<ApiService>()));

  getIt.registerLazySingleton<ForgetDataSource>(
      () => ForgetDataSourceImpl(getIt<ApiService>()));

  getIt.registerFactoryParam<VerificationRepo, String, Map<String, dynamic>>(
      instanceName: "checkphone",
      (param1, param2) => CheckPhoneRepo(
            data: param2,
            dataSource: getIt<VerificationDataSource>(
              instanceName: "checkphone",
            ),
            sendTo: param1,
          ));

  getIt.registerFactoryParam<ForgetPasswordRepo, String, String?>(
      (param1, param2) => ForgetPasswordRepoImpl(
            dataSource: getIt<ForgetDataSource>(),
            code: param1,
            sendTo: param2!,
          ));

  /// Location entity
  getIt.registerLazySingleton<LocationDataSource>(
      () => LocationDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<LocationRepo>(
      () => LocationRepoImp(locationDataSource: getIt<LocationDataSource>()));
  getIt.registerLazySingleton<FetchCitiesUseCase>(
      () => FetchCitiesUseCase(getIt<LocationRepo>()));
  getIt.registerLazySingleton<FetchDistrictsUseCase>(
      () => FetchDistrictsUseCase(getIt<LocationRepo>()));
  getIt.registerLazySingleton<FetchNeighborhoodsUseCase>(
      () => FetchNeighborhoodsUseCase(getIt<LocationRepo>()));
  getIt.registerLazySingleton<FetchDeliveryZonesUseCase>(
      () => FetchDeliveryZonesUseCase(getIt<LocationRepo>()));

  /// Conversations entity
  getIt.registerLazySingleton<ConversationsDataSource>(
      () => ConversationsDataSourceImp(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<ConversationsRepo>(
      () => ConversationsRepoImp(dataSource: getIt<ConversationsDataSource>()));
  getIt.registerLazySingleton<StartConversationUseCase>(() =>
      StartConversationUseCase(conversationsRepo: getIt<ConversationsRepo>()));
  getIt.registerLazySingleton<FetchConversationsUseCase>(() =>
      FetchConversationsUseCase(conversationsRepo: getIt<ConversationsRepo>()));
  getIt.registerLazySingleton<FetchConversationMessagesUseCase>(() =>
      FetchConversationMessagesUseCase(
          conversationsRepo: getIt<ConversationsRepo>()));
  getIt.registerLazySingleton<SendConversationMessageUseCase>(() =>
      SendConversationMessageUseCase(
          conversationsRepo: getIt<ConversationsRepo>()));
  getIt.registerLazySingleton<AcceptConversationQuoteUseCase>(() =>
      AcceptConversationQuoteUseCase(
          conversationsRepo: getIt<ConversationsRepo>()));
  getIt.registerLazySingleton<ConversationRealtimeService>(
      () => ConversationRealtimeService());

  getIt.registerLazySingleton<ServiceChatsDataSource>(
      () => ServiceChatsDataSourceImp(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<ServiceChatsRepo>(
      () => ServiceChatsRepoImp(dataSource: getIt<ServiceChatsDataSource>()));
  getIt.registerLazySingleton<StartServiceConversationUseCase>(() =>
      StartServiceConversationUseCase(
          serviceChatsRepo: getIt<ServiceChatsRepo>()));
  getIt.registerLazySingleton<FetchServiceConversationsUseCase>(() =>
      FetchServiceConversationsUseCase(
          serviceChatsRepo: getIt<ServiceChatsRepo>()));
  getIt.registerLazySingleton<FetchServiceChatMessagesUseCase>(() =>
      FetchServiceChatMessagesUseCase(
          serviceChatsRepo: getIt<ServiceChatsRepo>()));
  getIt.registerLazySingleton<SendServiceChatMessageUseCase>(() =>
      SendServiceChatMessageUseCase(
          serviceChatsRepo: getIt<ServiceChatsRepo>()));

  getIt.registerLazySingleton<ServicesDataSource>(
      () => ServicesDataSourceImp(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<ServicesRepo>(
      () => ServicesRepoImp(dataSource: getIt<ServicesDataSource>()));
  getIt.registerLazySingleton<FetchServiceTypesUseCase>(
      () => FetchServiceTypesUseCase(servicesRepo: getIt<ServicesRepo>()));
  getIt.registerLazySingleton<FetchProviderServicesUseCase>(
      () => FetchProviderServicesUseCase(servicesRepo: getIt<ServicesRepo>()));
  getIt.registerLazySingleton<FetchServiceProviderUseCase>(
      () => FetchServiceProviderUseCase(servicesRepo: getIt<ServicesRepo>()));
  getIt.registerLazySingleton<FetchServiceProvidersUseCase>(
      () => FetchServiceProvidersUseCase(servicesRepo: getIt<ServicesRepo>()));
  getIt.registerLazySingleton<CreateServiceOrderUseCase>(
      () => CreateServiceOrderUseCase(servicesRepo: getIt<ServicesRepo>()));
  getIt.registerLazySingleton<GetMyServiceOrdersUseCase>(
      () => GetMyServiceOrdersUseCase(servicesRepo: getIt<ServicesRepo>()));

  getIt.registerLazySingleton<PackageShipmentDataSource>(
      () => PackageShipmentDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<PackageShipmentRepo>(
      () => PackageShipmentRepoImp(dataSource: getIt<PackageShipmentDataSource>()));
  getIt.registerLazySingleton<FetchPackageSizesUseCase>(
      () => FetchPackageSizesUseCase(repo: getIt<PackageShipmentRepo>()));
  getIt.registerLazySingleton<CalculatePackagePriceUseCase>(
      () => CalculatePackagePriceUseCase(repo: getIt<PackageShipmentRepo>()));
  getIt.registerLazySingleton<CreatePackageShipmentUseCase>(
      () => CreatePackageShipmentUseCase(repo: getIt<PackageShipmentRepo>()));
  getIt.registerLazySingleton<FetchPackageShipmentDetailsUseCase>(
      () => FetchPackageShipmentDetailsUseCase(
          repo: getIt<PackageShipmentRepo>()));
  getIt.registerLazySingleton<FetchMyPackageShipmentsUseCase>(
      () => FetchMyPackageShipmentsUseCase(repo: getIt<PackageShipmentRepo>()));
  getIt.registerLazySingleton<CancelPackageShipmentUseCase>(
      () => CancelPackageShipmentUseCase(repo: getIt<PackageShipmentRepo>()));

  /// games / rewards game center
  getIt.registerLazySingleton<GamesDataSource>(
      () => GamesDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<GamesRepo>(
      () => GamesRepoImp(dataSource: getIt<GamesDataSource>()));
  getIt.registerLazySingleton<FetchGameConfigUseCase>(
      () => FetchGameConfigUseCase(gamesRepo: getIt<GamesRepo>()));
  getIt.registerLazySingleton<FetchRewardsBalanceUseCase>(
      () => FetchRewardsBalanceUseCase(gamesRepo: getIt<GamesRepo>()));
  getIt.registerLazySingleton<EarnRewardsUseCase>(
      () => EarnRewardsUseCase(gamesRepo: getIt<GamesRepo>()));
  getIt.registerLazySingleton<FetchRewardsTransactionsUseCase>(
      () => FetchRewardsTransactionsUseCase(gamesRepo: getIt<GamesRepo>()));

  getIt.registerLazySingleton<RewardsDataSource>(
      () => RewardsDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<RewardsRepo>(
      () => RewardsRepoImp(dataSource: getIt<RewardsDataSource>()));
  getIt.registerLazySingleton<FetchRewardsUseCase>(
      () => FetchRewardsUseCase(rewardsRepo: getIt<RewardsRepo>()));

  getIt.registerLazySingleton<OffersDataSource>(
      () => OffersDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<OffersRepo>(
      () => OffersRepoImp(dataSource: getIt<OffersDataSource>()));
  getIt.registerLazySingleton<FetchOffersUseCase>(
      () => FetchOffersUseCase(offersRepo: getIt<OffersRepo>()));

  getIt.registerLazySingleton<SupportTicketsDataSource>(
      () => SupportTicketsDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<SupportTicketsRepo>(
      () => SupportTicketsRepoImp(dataSource: getIt<SupportTicketsDataSource>()));
  getIt.registerLazySingleton<FetchSupportTicketsUseCase>(
      () => FetchSupportTicketsUseCase(repo: getIt<SupportTicketsRepo>()));
  getIt.registerLazySingleton<FetchSupportTicketDetailsUseCase>(
      () =>
          FetchSupportTicketDetailsUseCase(repo: getIt<SupportTicketsRepo>()));
  getIt.registerLazySingleton<CreateSupportTicketUseCase>(
      () => CreateSupportTicketUseCase(repo: getIt<SupportTicketsRepo>()));
  getIt.registerLazySingleton<ReplySupportTicketUseCase>(
      () => ReplySupportTicketUseCase(repo: getIt<SupportTicketsRepo>()));

  /// share links
  getIt.registerLazySingleton<ShareLinksDataSource>(
      () => ShareLinksDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<ShareLinksRepo>(
      () => ShareLinksRepoImp(dataSource: getIt<ShareLinksDataSource>()));
  getIt.registerLazySingleton<CreateShareLinkUseCase>(
      () => CreateShareLinkUseCase(shareLinksRepo: getIt<ShareLinksRepo>()));
  getIt.registerLazySingleton<ResolveShareLinkUseCase>(
      () => ResolveShareLinkUseCase(shareLinksRepo: getIt<ShareLinksRepo>()));
  getIt.registerLazySingleton<ShareService>(
      () => ShareService(createShareLinkUseCase: getIt<CreateShareLinkUseCase>()));
  getIt.registerLazySingleton<DeepLinkService>(
      () => DeepLinkService(
            resolveShareLinkUseCase: getIt<ResolveShareLinkUseCase>(),
          ));
}
