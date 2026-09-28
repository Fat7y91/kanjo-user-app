abstract class ApiPath {
  static const baseurl = "https://kango.laravelteam.site/api/v1/";
  static const uploadPath = 'https://kango.laravelteam.site/storage/';
  static const sharePath = 'https://kango.laravelteam.site/';
  static const refresh = 'auth/v1/token?grant_type=refresh_token';
  static const userLogin = 'auth/login';
  static const forgotPassword = 'auth/password/forgot';
  static const resetPassword = 'auth/password/reset';
  static const userRegister = 'auth/register';
  static const vendorRegister = 'vendors/register';
  static const support = 'website/contacts';
  static const supportTickets = 'support/tickets';
  static String supportTicket(int ticketId) => '$supportTickets/$ticketId';
  static String supportTicketMessages(int ticketId) =>
      '$supportTickets/$ticketId/messages';
  static const checkPhone = 'verify-phone';
  static const updateProfileImage = 'students/profile/picture/';
  static const updateProfile = 'auth/me';
  static const uploadImage = 'uploads/images';

  static const getSliders = "sliders";
  static String getSlidersList({
    double? latitude,
    double? longitude,
    int? zoneId,
  }) {
    final params = <String>[];
    if (zoneId != null && zoneId > 0) {
      params.add('zone_id=$zoneId');
    } else {
      if (latitude != null) {
        params.add('latitude=$latitude');
      }
      if (longitude != null) {
        params.add('longitude=$longitude');
      }
    }
    if (params.isEmpty) return getSliders;
    return '$getSliders?${params.join('&')}';
  }

  static const getHomeSliders = "home-sliders";
  static const getProducts = "products";
  static String getProductDetails(int productId) => 'products/$productId';
  static String getProductsList({
    int? vendorId,
    int? categoryId,
    int page = 1,
    int perPage = 20,
  }) {
    final params = <String>[
      'page=$page',
      'per_page=$perPage',
    ];
    if (vendorId != null && vendorId > 0) {
      params.add('vendor_id=$vendorId');
    }
    if (categoryId != null && categoryId > 0) {
      params.add('category_id=$categoryId');
    }
    return '$getProducts?${params.join('&')}';
  }
  static String searchProducts(
    String query, {
    int? vendorId,
    int page = 1,
    int perPage = 20,
  }) {
    final encoded = Uri.encodeQueryComponent(query);
    final params = <String>[
      'q=$encoded',
      'page=$page',
      'per_page=$perPage',
    ];
    if (vendorId != null) {
      params.add('vendor_id=$vendorId');
    }
    return 'products?${params.join('&')}';
  }

  /// Global app search (products + vendors groups).
  static String search(String query) {
    final encoded = Uri.encodeQueryComponent(query.trim());
    return 'search?q=$encoded';
  }

  static String searchProductByName(String query) =>
      "products/search?q=$query&limit=10";
  static const getCategories = "categories";
  static String getCategoriesByVendorType(
    int vendorTypeId, {
    int page = 1,
    int perPage = 50,
  }) =>
      'categories?vendor_type_id=$vendorTypeId&page=$page&per_page=$perPage';
  static const getCategoriesTree = "categories/tree";
  static const getAdminCategories = "admin-categories/tree";
  static String getCategoryDetails(String catId) => 'categories/$catId';
  static const getUser = 'auth/me';
  static const googleLogin = 'auth/google/mobile';
  static const selectRole = 'auth/select-role';
  static const sendOTP = 'auth/otp/send';
  static const verifyOTP = 'auth/otp/verify';
  static const sendEmailVerification = 'auth/email/send-verification';
  static const verifyEmail = 'auth/email/verify';
  static const sendPhoneVerification = 'auth/phone/send-verification';
  static const verifyPhone = 'auth/phone/verify';
  static const logOut = 'auth/logout';
  static const deleteAccount = 'auth/delete-account';
  static const registerFCMToken = 'auth/fcm-token';
  static const removeFCMToken = 'auth/fcm-token';
  static const settings = 'app/settings';
  static const getOrders = 'orders';
  static String getOrdersList({int page = 1, int perPage = 20}) =>
      '$getOrders?page=$page&per_page=$perPage';

  /// Bundle Orders
  static const bundleOrders = 'bundle-orders';
  static const myBundleOrders = 'bundle-orders/my';
  static String showBundleByCode(String code) => 'bundle-orders/$code';
  static String addMyCartToBundle(String code) =>
      'bundle-orders/$code/items';
  static String removeBundleItem(String bundleCode, int bundleItemId) =>
      'bundle-orders/$bundleCode/items/$bundleItemId';
  static String submitBundle(String code) => 'bundle-orders/$code/submit';
  static String cancelBundleOrder(String code) => 'bundle-orders/$code/cancel';
  static const getPlans = 'customer-subscriptions/plans';
  static const getMySubscription = 'customer-subscriptions/my-subscription';
  static const getVendorPlans = 'vendors/plans';
  static const getWallet = 'wallet';
  static const getCartItems = 'cart';
  static const applyCoupon = 'cart/coupon';
  static const getFavorites = 'wishlist';
  static String getFavoritesList({int page = 1, int perPage = 50}) =>
      '$getFavorites?page=$page&per_page=$perPage';
  static const addFavorite = 'wishlist';
  static const toggleFavorite = 'wishlist/toggle';
  static String deleteFavorite(int id) => 'wishlist/$id';
  static const getAddresses = 'addresses';
  static String getAddressesList({int page = 1, int perPage = 50}) =>
      '$getAddresses?page=$page&per_page=$perPage';
  static const addAddress = 'addresses';
  static const updateAddress = 'addresses';
  static const deleteAddress = 'addresses';
  static String setDefaultAddress(String addressId) =>
      'addresses/$addressId/default';

  static const addToCart = 'cart';
  static const updateCartItem = 'cart/update';
  static const cartActions = 'cart';
  static String deleteFromCart(String id) => 'cart/$id';

  static String getProductReviews(String productId) =>
      'reviews/product/$productId';

  static String addReview(String productId) => 'reviews/product/$productId';

  static String reviewHelpful(String reviewId) => 'reviews/$reviewId/helpful';

  static String getVendorProducts(String vendorId,
          {int page = 1, int limit = 20}) =>
      'products/vendor/$vendorId?page=$page&limit=$limit';
  static const createProduct = 'products';
  static String updateProduct(String productId) => 'products/$productId';

  static const changePassword = 'forget/password/change/password';
  static const forgetPassword = 'forget/password';
  static const notifications = 'notifications';
  static String getNotificationsList({int page = 1, int perPage = 20}) =>
      '$notifications?page=$page&per_page=$perPage';
  static const notificationsUnreadCount = 'notifications/unread-count';
  static const notificationsReadAll = 'notifications/read-all';
  static String notificationRead(String notificationId) =>
      '$notifications/$notificationId/read';
  static const seen = 'seen/';
  static const upload = 'upload/file';
  static const validateOTPForgetPassword = 'api/login-otp';
  static const countries = 'getCountryWithCity';
  static const filter = 'filter';
  static const loyaltyPoints = 'loyalty-points';
  static const rewardsGameConfig = 'rewards/game-config';
  static const rewardsBalance = 'rewards/balance';
  static const rewardsEarn = 'rewards/earn';
  static const rewardsTransactions = 'rewards/transactions';
  static const rewardsList = 'rewards';
  static const offers = 'offers';
  static String getOffersList({
    double? latitude,
    double? longitude,
    int? zoneId,
  }) {
    final params = <String>[];
    if (zoneId != null && zoneId > 0) {
      params.add('zone_id=$zoneId');
    } else {
      if (latitude != null) {
        params.add('latitude=$latitude');
      }
      if (longitude != null) {
        params.add('longitude=$longitude');
      }
    }
    if (params.isEmpty) return offers;
    return '$offers?${params.join('&')}';
  }

  static String rateVendor(int vendorId) => 'vendors/$vendorId/rating';
  static String rateDeliveryPartner(int deliveryPartnerId) =>
      'delivery-partners/$deliveryPartnerId/rating';
  static const getVendors = 'vendors';
  static String getVendorsList({
    int? vendorTypeId,
    int? categoryId,
    String? search,
    bool isFeatured = false,
    bool offers = false,
    double? latitude,
    double? longitude,
    int? zoneId,
    int page = 1,
    int perPage = 20,
  }) {
    final params = <String>[
      'page=$page',
      'per_page=$perPage',
    ];
    if (vendorTypeId != null && vendorTypeId > 0) {
      params.add('vendor_type_id=$vendorTypeId');
    }
    if (categoryId != null && categoryId > 0) {
      params.add('category_id=$categoryId');
    }
    final query = search?.trim();
    if (query != null && query.isNotEmpty) {
      params.add('search=${Uri.encodeQueryComponent(query)}');
    }
    if (isFeatured) {
      params.add('is_featured=1');
    }
    if (offers) {
      params.add('offers=1');
    }
    if (zoneId != null && zoneId > 0) {
      params.add('zone_id=$zoneId');
    } else {
      if (latitude != null) {
        params.add('latitude=$latitude');
      }
      if (longitude != null) {
        params.add('longitude=$longitude');
      }
    }
    return '$getVendors?${params.join('&')}';
  }
  static const getVendorTypes = 'vendor/types';
  static const getVendorProfile = 'vendors/me/profile';
  static const getMyProducts = 'products/my-products';
  static const getCities = 'locations/cities';
  static const getDeliveryZones = 'delivery-zones';
  static String getDistricts(String cityCode) =>
      'locations/districts/$cityCode';
  static String getNeighborhoods(String cityCode, String districtName) =>
      'locations/neighborhoods/$cityCode/${Uri.encodeComponent(districtName)}';
  static const checkoutOrder = 'checkout';
  static String cancelOrder(String orderId) => 'orders/$orderId/cancel';
  static String reorderOrder(String orderId) => 'orders/$orderId/reorder';
  static String orderRefundRequests(String orderId) =>
      'orders/$orderId/refund-requests';
  static const getStorePage = 'store-page';
  static String getStoreCategoryProducts(String catId) =>
      'store-page/category/$catId';
  static String getStoreCategoryDetails(String catId) =>
      'admin-categories/$catId';
  static const getHomeData = 'home';
  static String getProductBundles(String productId) =>
      'bundles/product/$productId';
  static const getCartSuggestions = 'bundles/cart-suggestions';
  static const getMyPayments = 'payments/my-payments';
  static String viewStory(String storyId) => 'stories/$storyId/view';
  static const createStory = 'stories';
  static const getChats = 'chat';
  static String getChatMessages(String chatId) => 'chat/$chatId/messages';
  static String sendMessage(String chatId) => 'chat/$chatId/messages';
  static String markChatAsRead(String chatId) => 'chat/$chatId/read';
  static const createChat = 'chat/create';

  static String startVendorConversation(int vendorId) =>
      'vendors/$vendorId/conversations';
  static const getConversations = 'conversations';
  static const broadcastingAuth = 'broadcasting/auth';
  static String getConversationsList({
    int page = 1,
    int perPage = 50,
  }) =>
      '$getConversations?page=$page&per_page=$perPage';
  static String getConversationMessages(
    int conversationId, {
    int page = 1,
    int perPage = 50,
  }) =>
      'conversations/$conversationId/messages?page=$page&per_page=$perPage';
  static String sendConversationMessage(int conversationId) =>
      'conversations/$conversationId/messages';
  static String acceptConversationQuote({
    required int conversationId,
    required int quoteMessageId,
  }) =>
      'conversations/$conversationId/messages/$quoteMessageId/accept-quote';

  static String startServiceConversation(int serviceProviderId) =>
      'service-providers/$serviceProviderId/conversations';
  static const getServiceConversations = 'service-conversations';
  static String getServiceConversationsList({
    int page = 1,
    int perPage = 20,
  }) =>
      '$getServiceConversations?page=$page&per_page=$perPage';
  static String getServiceConversationMessages(
    int conversationId, {
    int page = 1,
    int perPage = 50,
  }) =>
      '$getServiceConversations/$conversationId/messages?page=$page&per_page=$perPage';
  static String sendServiceConversationMessage(int conversationId) =>
      '$getServiceConversations/$conversationId/messages';
  static const shippingCompanies = 'shipping/companies';
  static const shippingCalculate = 'shipping/calculate';
  static const packageSizes = 'package-sizes';
  static const packageShipments = 'package-shipments';
  static const calculatePackageShipmentPrice =
      'package-shipments/calculate-price';
  static String cancelPackageShipment(String id) =>
      'package-shipments/$id/cancel';
  static String packageShipment(String id) => 'package-shipments/$id';

  static const getServiceTypes = 'service-types';
  static const getServiceProviders = 'service-providers';
  static String getServiceProvidersList({
    int? serviceTypeId,
    String? search,
  }) {
    final params = <String>[];
    if (serviceTypeId != null && serviceTypeId > 0) {
      params.add('service_type_id=$serviceTypeId');
    }
    final query = search?.trim();
    if (query != null && query.isNotEmpty) {
      params.add('search=${Uri.encodeQueryComponent(query)}');
    }
    if (params.isEmpty) return getServiceProviders;
    return '$getServiceProviders?${params.join('&')}';
  }
  static const getProviderServices = 'provider-services';
  static String getProviderServicesList({
    int? serviceTypeId,
    int? serviceProviderId,
  }) {
    final params = <String>[];
    if (serviceTypeId != null && serviceTypeId > 0) {
      params.add('service_type_id=$serviceTypeId');
    }
    if (serviceProviderId != null && serviceProviderId > 0) {
      params.add('service_provider_id=$serviceProviderId');
    }
    if (params.isEmpty) return getProviderServices;
    return '$getProviderServices?${params.join('&')}';
  }
  static String getServiceProvider(int serviceProviderId) =>
      'service-providers/$serviceProviderId';
  static const shareLinks = 'share-links';
  static String resolveShareLink(String reference) =>
      'share-links/$reference/resolve';
  static const createServiceOrder = 'service-orders';
  static String getServiceOrdersList({int page = 1, int perPage = 20}) =>
      '$createServiceOrder?page=$page&per_page=$perPage';

  // Get this from: Firebase Console -> Authentication -> Sign-in method -> Google -> Web Client ID
  static const googleSignInServerClientId =
      '520930212972-gipoqiaj6tbt0suhbi0bc9gtoclfl8t3.apps.googleusercontent.com';

  /// Catalog endpoints that succeed without an auth token.
  static bool isPublic(String url) {
    final path = url.split('?').first.replaceFirst(RegExp(r'^/'), '');
    const exact = {
      'categories',
      'categories/tree',
      'products',
      'offers',
      'coupons',
      'sliders',
      'search',
      'vendors',
      'vendor/types',
      'vendor/plans',
      'vendors/plans',
      'vendor/apply',
      'vendors/register',
    };
    if (exact.contains(path)) return true;
    if (path == 'products/search') return true;
    if (RegExp(r'^products/\d+$').hasMatch(path)) return true;
    if (RegExp(r'^categories/\d+$').hasMatch(path)) return true;
    return false;
  }
}
