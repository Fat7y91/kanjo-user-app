import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/service_chats/presentation/managers/service_chats_provider.dart';
import 'package:heraj/features/service_chats/presentation/managers/service_conversations_list_actions_mixin.dart';
import 'package:heraj/features/service_chats/presentation/view/widgets/service_conversation_list_tile.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/error_widget.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/shared_widgets/not_found_widget.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

class ServiceConversationsScreen extends ConsumerStatefulWidget {
  const ServiceConversationsScreen({super.key});

  @override
  ConsumerState<ServiceConversationsScreen> createState() =>
      _ServiceConversationsScreenState();
}

class _ServiceConversationsScreenState
    extends ConsumerState<ServiceConversationsScreen>
    with ServiceConversationsListActionsMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    final notifier = ref.read(fetchServiceConversationsProvider.notifier);
    if (notifier.isLastPage()) return;
    notifier.fetchNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(fetchServiceConversationsProvider);
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4, top + 6, 16, 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(closeOverlays: true),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: AppColor.black,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Service chats'.tr,
                    textAlign: TextAlign.center,
                    style: AppFont.font16W400Black.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: conversationsAsync.customWhen(
              ref: ref,
              refreshable: fetchServiceConversationsProvider.future,
              skipLoadingOnRefresh: true,
              loading: () => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                separatorBuilder: (_, __) => const Gap(8),
                itemBuilder: (_, __) => const ShimmerEffect(
                  enable: true,
                  child: ColoredBox(
                    color: Colors.white,
                    child: SizedBox(height: 72, width: double.infinity),
                  ),
                ),
              ),
              error: (err, trace) => CustomErrorWidget(
                object: err,
                stackTrace: trace,
                onRetry: () async {
                  ref.invalidate(fetchServiceConversationsProvider);
                },
              ),
              data: (conversations) {
                final showFooter = conversations.isNotEmpty &&
                    !ref
                        .read(fetchServiceConversationsProvider.notifier)
                        .isLastPage();
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(fetchServiceConversationsProvider);
                    try {
                      await ref.read(fetchServiceConversationsProvider.future);
                    } catch (_) {}
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (conversations.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: NotFoundWidget(title: 'No service chats'.tr),
                        )
                      else
                        SliverList.separated(
                          itemCount:
                              conversations.length + (showFooter ? 1 : 0),
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: AppColor.lightBorder,
                          ),
                          itemBuilder: (context, index) {
                            if (index >= conversations.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: LoadingWidget(size: 24),
                              );
                            }
                            final conversation = conversations[index];
                            return ServiceConversationListTile(
                              conversation: conversation,
                              onTap: () =>
                                  openServiceConversation(conversation),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
