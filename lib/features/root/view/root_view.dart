import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/features/orders/presentation/view/orders_screen.dart';
import '../../../../config/app_assets.dart';
import '../../../core/service/socket_service/conversation_realtime_service.dart';
import '../../../core/service/socket_service/realtime_logger.dart';
import '../../../core/service/socket_service/user_app_realtime_binder.dart';
import '../../../../helper/responsive.dart';
import '../../../../main.dart';
import '../../conversations/presentation/managers/conversations_provider.dart';
import '../../conversations/presentation/view/conversations_screen.dart';
import '../../service_chats/presentation/managers/service_chats_provider.dart';
import '../../../../packages/flutter_close_app.dart';
import '../../home/presentation/view/home_screen.dart';
import '../../settings/presentation/View/settings_view.dart';
import '../../store/presentation/view/store_screen.dart';
import '../controller/root_controller.dart';

class RootView extends ConsumerStatefulWidget {
  const RootView({super.key});

  @override
  ConsumerState<RootView> createState() => _RootViewState();
}

class _RootViewState extends ConsumerState<RootView> {
  final Widget _homeScreen = const HomeScreen();
  final Widget _shipmentsScreen = const StoreScreen();
  final Widget _chatsScreen = const ConversationsScreen(showBackButton: false);
  final Widget _reportsScreen = const OrdersScreen();
  final Widget _settingsView = const SettingsView();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if ((dataManager.getToken() ?? '').isEmpty) return;
      RealtimeLogger.i('RootView starting conversation + user-app sockets');
      unawaited(getIt<ConversationRealtimeService>().connectIfPossible());
      unawaited(ref.read(fetchConversationsProvider.future));
      unawaited(ref.read(fetchServiceConversationsProvider.future));
    });
  }

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    ref.watch(userAppRealtimeProvider);
    final selectedIndex = ref.watch(rootIndex);
    final int safeIndex = selectedIndex < 0 ? 0 : selectedIndex;
    final controller = ref.read(rootIndex.notifier);
    final int unreadChats = ref.watch(conversationsUnreadCountProvider) +
        ref.watch(serviceConversationsUnreadCountProvider);

    return FlutterCloseAppPage(
      condition: selectedIndex == 0,
      onCloseFailed: () {
        if (selectedIndex != 0) {
          final controller = ref.read(rootIndex.notifier);
          controller.reset();
        } else {
          Fluttertoast.showToast(
            msg: 'Press again to exit'.tr,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: safeIndex,
          children: _buildScreens(),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(
            8,
            0,
            8,
            MediaQuery.paddingOf(context).bottom > 0
                ? MediaQuery.paddingOf(context).bottom
                : 8,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColor.defaultPrimaryGradient2,
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              children: [
                for (var i = 0; i < _navItems.length; i++)
                  Expanded(
                    child: _FloatingNavItem(
                      label: _navItems[i].label.tr,
                      selectedAsset: _navItems[i].selectedAsset,
                      unselectedAsset: _navItems[i].unselectedAsset,
                      selected: safeIndex == i,
                      badgeCount: i == 2 ? unreadChats : 0,
                      onTap: () {
                        if (i == safeIndex) return;
                        controller.setSelectedIndex(i);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      _homeScreen,
      _shipmentsScreen,
      _chatsScreen,
      _reportsScreen,
      _settingsView,
    ];
  }

  static const _navItems = <_RootNavItem>[
    _RootNavItem(
      label: 'Home',
      selectedAsset: AppAssets.navHome,
      unselectedAsset: AppAssets.navHomeOutline,
    ),
    _RootNavItem(
      label: 'Store',
      selectedAsset: AppAssets.navStore,
      unselectedAsset: AppAssets.navStoreOutline,
    ),
    _RootNavItem(
      label: 'Chat',
      selectedAsset: AppAssets.homeChat,
      unselectedAsset: AppAssets.homeChat,
    ),
    _RootNavItem(
      label: 'Orders',
      selectedAsset: AppAssets.navOrders,
      unselectedAsset: AppAssets.navReportsOutline,
    ),
    _RootNavItem(
      label: 'More',
      selectedAsset: AppAssets.navMore,
      unselectedAsset: AppAssets.navMoreOutline,
    ),
  ];
}

class _RootNavItem {
  const _RootNavItem({
    required this.label,
    required this.selectedAsset,
    required this.unselectedAsset,
  });

  final String label;
  final String selectedAsset;
  final String unselectedAsset;
}

class _FloatingNavItem extends StatelessWidget {
  const _FloatingNavItem({
    required this.label,
    required this.selectedAsset,
    required this.unselectedAsset,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final String selectedAsset;
  final String unselectedAsset;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final icon = SvgPicture.asset(
      selected ? selectedAsset : unselectedAsset,
      height: 20,
      width: 20,
      colorFilter: ColorFilter.mode(
        Colors.white.withAlpha(selected ? 255 : 200),
        BlendMode.srcIn,
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashFactory: InkRipple.splashFactory,
        splashColor: Colors.white.withAlpha(40),
        highlightColor: Colors.white.withAlpha(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? Colors.white.withAlpha(36) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: selected
                ? Border.all(color: Colors.white.withAlpha(90), width: 1)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  icon,
                  if (badgeCount > 0)
                    Positioned(
                      top: -6,
                      right: -10,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.guestOrange,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          textAlign: TextAlign.center,
                          style: AppFont.font10W600White.copyWith(
                            fontSize: 9,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppFont.font10W600White.copyWith(
                  color: Colors.white.withAlpha(selected ? 255 : 200),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
