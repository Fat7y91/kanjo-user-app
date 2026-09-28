import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/notifications/domain/entities/notification_entity.dart';
import 'package:heraj/features/notifications/presentation/managers/notifications_screen_actions_mixin.dart';
import 'package:heraj/features/notifications/presentation/view/widgets/notification_action_chip.dart';
import 'package:heraj/features/notifications/presentation/view/widgets/notifications_container.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/fade_in_animation.dart';
import 'package:heraj/ui/shared_widgets/hide_nav_bar_widget.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/shared_widgets/not_found_widget.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

import '../managers/fetch_notificatons_provider.dart';
import '../managers/notifications_filter.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with NotificationsScreenActionsMixin {
  late final AutoDisposeStateProvider<bool> hideNavBarProvider2;
  final ScrollController _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    hideNavBarProvider2 = StateProvider.autoDispose<bool>((ref) => false);
    _listScrollController.addListener(_onNotificationsScroll);
  }

  @override
  void dispose() {
    _listScrollController
      ..removeListener(_onNotificationsScroll)
      ..dispose();
    super.dispose();
  }

  void _onNotificationsScroll() {
    if (!_listScrollController.hasClients) return;
    if (_listScrollController.position.pixels <
        _listScrollController.position.maxScrollExtent - 200) {
      return;
    }
    final notifier = ref.read(fetchNotificationsProvider.notifier);
    if (notifier.isLastPage()) return;
    notifier.fetchNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(fetchNotificationsProvider).valueOrNull;
    final unreadFromList = list?.where((e) => !e.isRead).length;
    final unreadCount = unreadFromList ??
        (ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0);
    final filterStatus =
        ref.watch(notificationsProvider.select((m) => m['status']));

    return Scaffold(
      backgroundColor: AppColor.pageBackgroundGrey,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColor.pageBackgroundGrey,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: AppColor.black),
                onPressed: () => Get.back(),
              ),
              title: Text('Notifications'.tr, style: AppFont.font20W700Black),
              actions: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        child: child,
                      ),
                    );
                  },
                  child: unreadCount > 0
                      ? TextButton(
                          key: const ValueKey('mark-all'),
                          onPressed: markAllNotificationsAsRead,
                          child: Text(
                            'Mark all as read'.tr,
                            style: AppFont.font12w400Black.copyWith(
                              color: AppColor.grey2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('mark-all-empty')),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: AnimatedSizeAndFade.showHide(
                show: !ref.watch(hideNavBarProvider2),
                child: FadeInAnimation(
                  delay: 0.7,
                  fadeOffset: 18,
                  direction: FadeInDirection.topToBottom,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: NotificationFilterType.values
                          .map((e) => NotificationsCustomActionChip(value: e))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              child: HideNavBarWidget(
                customProvider: hideNavBarProvider2,
                child: Consumer(
                  builder: (context, ref, _) {
                    final notificationsList =
                        ref.watch(filteredNotificationsProvider);
                    return notificationsList.customWhen(
                      ref: ref,
                      refreshable: fetchNotificationsProvider.future,
                      data: (notifications) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.04),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: notifications.isEmpty
                              ? KeyedSubtree(
                                  key: ValueKey('empty-$filterStatus'),
                                  child: NotFoundWidget(
                                    haveIcon: true,
                                    title: 'No Notifications right now.!'.tr,
                                  ),
                                )
                              : KeyedSubtree(
                                  key: ValueKey(
                                    'list-$filterStatus-${notifications.length}',
                                  ),
                                  child: _NotificationsList(
                                    notifications: notifications,
                                    showFooter: !ref
                                        .read(
                                          fetchNotificationsProvider.notifier,
                                        )
                                        .isLastPage(),
                                    scrollController: _listScrollController,
                                    onTapItem: onNotificationTap,
                                    onRefresh: () async {
                                      ref.invalidate(
                                        fetchNotificationsProvider,
                                      );
                                      await ref.read(
                                        fetchNotificationsProvider.future,
                                      );
                                    },
                                  ),
                                ),
                        );
                      },
                      loading: () => ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: 6,
                        separatorBuilder: (_, __) => const Gap(8),
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(
                              milliseconds: 280 + (index * 60),
                            ),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 10 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: ShimmerEffect(
                              enable: true,
                              child: Container(
                                height: 88,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({
    required this.notifications,
    required this.showFooter,
    required this.scrollController,
    required this.onTapItem,
    required this.onRefresh,
  });

  final List<NotificationEntity> notifications;
  final bool showFooter;
  final ScrollController scrollController;
  final void Function(NotificationEntity item) onTapItem;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColor.grey2,
      onRefresh: onRefresh,
      child: ListView.separated(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemBuilder: (context, index) {
          if (showFooter && index == notifications.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: LoadingWidget(size: 24),
            );
          }
          final item = notifications[index];
          return NotificationContainer(
            key: ValueKey(item.id),
            notificationEntity: item,
            index: index,
            onTap: () => onTapItem(item),
          );
        },
        separatorBuilder: (_, __) => const Gap(8),
        itemCount: notifications.length + (showFooter ? 1 : 0),
      ),
    );
  }
}
