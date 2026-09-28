import 'package:get/get.dart';
import '../features/address/presentation/view/address_screen.dart';
import '../features/auth/presentation/view/login_page.dart';
import '../features/auth/presentation/view/register_page.dart';
import '../features/notifications/presentation/view/notifications_screen.dart';
import '../features/orders/presentation/view/orders_screen.dart';
import '../features/orders/presentation/view/order_details_screen.dart';
import '../features/orders/presentation/view/track_order_screen.dart';
import '../features/cart/presentation/view/cart_screen.dart';
import '../features/cart/presentation/view/checkout_screen.dart';
import '../features/cart/presentation/view/order_success_screen.dart';
import '../features/conversations/presentation/view/conversations_screen.dart';
import '../features/service_chats/presentation/view/service_conversations_screen.dart';
import '../features/rewards/presentation/view/rewards_screen.dart';
import '../features/offers/presentation/view/offers_screen.dart';
import '../features/support_tickets/presentation/view/support_tickets_screen.dart';
import '../features/offline/no_wifi.dart';
import '../features/onboarding/view/get_started_screen.dart';
import '../features/onboarding/view/onboard_screen.dart';
import '../features/root/view/root_view.dart';
import '../features/splash/presentation/view/splash_view.dart';
import '../features/splash/presentation/view/gif_splash_view.dart';
import '../features/games/presentation/view/games_hub_screen.dart';
import '../features/games/presentation/view/flying_bird_game_screen.dart';
import '../features/games/presentation/view/gun_shooter_game_screen.dart';
import '../features/games/presentation/view/arena_survival_game_screen.dart';
import '../features/wallet/presentation/view/wallet_screen.dart';
import '../features/package_shipment/presentation/view/create_package_shipment_screen.dart';
import '../features/package_shipment/presentation/view/my_package_shipments_screen.dart';
import '../features/package_shipment/presentation/view/package_shipment_details_screen.dart';

final List<GetPage> appRoutes = [
  GetPage(
    name: '/',
    page: () => const SplashView(),
  ),
  GetPage(
    name: '/gif-splash',
    page: () => GifSplashView(
      gifUrl: (Get.arguments is Map
              ? (Get.arguments as Map)['gifUrl']
              : Get.arguments)
          ?.toString() ??
          '',
    ),
  ),
  GetPage(
    name: '/onboarding',
    page: () => const OnboardScreen(),
  ),
  GetPage(
    name: '/get-started',
    page: () => const GetStartedScreen(),
  ),
  GetPage(
    name: '/login',
    page: () => const LoginPage(),
  ),
  GetPage(
    name: '/register',
    page: () => const RegisterPage(),
  ),
  GetPage(
    name: '/home',
    page: () => const RootView(),
  ),
  GetPage(
    name: '/no-wifi',
    page: () => const NoWifi(),
  ),
  // Address
  GetPage(
    name: '/addresses',
    page: () => const AddressScreen(),
  ),
  GetPage(
    name: '/notifications',
    page: () => const NotificationsScreen(),
  ),
  GetPage(
    name: '/conversations',
    page: () => const ConversationsScreen(),
  ),
  GetPage(
    name: '/service-conversations',
    page: () => const ServiceConversationsScreen(),
  ),
  GetPage(
    name: '/orders',
    page: () => const OrdersScreen(),
  ),
  GetPage(
    name: '/order-details',
    page: () => OrderDetailsScreen(
      orderId: (Get.parameters['id'] ?? Get.arguments?['id'] ?? '').toString(),
    ),
  ),
  GetPage(
    name: '/track-order',
    page: () => TrackOrderScreen(
      orderId: (Get.parameters['id'] ?? Get.arguments?['id'] ?? '').toString(),
    ),
  ),
  GetPage(
    name: '/rewards',
    page: () => const RewardsScreen(),
  ),
  GetPage(
    name: '/offers',
    page: () => const OffersScreen(),
  ),
  GetPage(
    name: '/support-tickets',
    page: () => const SupportTicketsScreen(),
  ),
  GetPage(
    name: '/games',
    page: () => const GamesHubScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/games/flying-bird',
    page: () => const FlyingBirdGameScreen(),
  ),
  GetPage(
    name: '/games/gun-shooter',
    page: () => const GunShooterGameScreen(),
  ),
  GetPage(
    name: '/games/arena-survival',
    page: () => const ArenaSurvivalGameScreen(),
  ),
  GetPage(
    name: '/wallet',
    page: () => const WalletScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/package-shipment',
    page: () => const CreatePackageShipmentScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/my-package-shipments',
    page: () => const MyPackageShipmentsScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/package-shipment-details',
    page: () => PackageShipmentDetailsScreen(
      shipmentId: (Get.parameters['id'] ?? Get.arguments?.toString() ?? '')
          .toString(),
    ),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/cart',
    page: () => const CartScreen(),
  ),
  GetPage(
    name: '/checkout',
    page: () => const CheckoutScreen(),
  ),
  GetPage(
    name: '/order-success',
    page: () => OrderSuccessScreen(
      orderId: (Get.parameters['id'] ?? '548964132').toString(),
    ),
  ),
];
