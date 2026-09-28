import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/conversations/presentation/managers/conversations_list_actions_mixin.dart';
import 'package:heraj/features/conversations/presentation/managers/conversations_provider.dart';
import 'package:heraj/features/conversations/presentation/view/widgets/conversation_list_tile.dart';
import 'package:heraj/features/service_chats/presentation/managers/service_chats_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/error_widget.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/shared_widgets/not_authorized_widget.dart';
import 'package:heraj/ui/shared_widgets/not_found_widget.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import 'package:heraj/core/service/local_data_manager.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen>
    with ConversationsListActionsMixin {
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
    final notifier = ref.read(fetchConversationsProvider.notifier);
    if (notifier.isLastPage()) return;
    notifier.fetchNextPage();
  }

  @override
  Widget build(BuildContext context) {
    if ((dataManager.getToken() ?? '').isEmpty) {
      return Scaffold(
        backgroundColor: AppColor.white,
        body: const SafeArea(
          child: Center(child: NotAuthorizedWidget()),
        ),
      );
    }

    final conversationsAsync = ref.watch(fetchConversationsProvider);
    final serviceUnread = ref.watch(serviceConversationsUnreadCountProvider);
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (widget.showBackButton) ...[
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
                        'Conversations'.tr,
                        textAlign: TextAlign.center,
                        style: AppFont.font18W700Black,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ] else
                    Text(
                      'Conversations'.tr,
                      textAlign: TextAlign.center,
                      style: AppFont.font18W700Black,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Material(
                color: AppColor.white,
                child: InkWell(
                  onTap: () => Get.toNamed('/service-conversations'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.handyman_outlined,
                          color: AppColor.primary,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            'Service chats'.tr,
                            style: AppFont.font14W600Black,
                          ),
                        ),
                        if (serviceUnread > 0)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColor.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColor.textGrey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: conversationsAsync.customWhen(
                ref: ref,
                refreshable: fetchConversationsProvider.future,
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
                    ref.invalidate(fetchConversationsProvider);
                  },
                ),
                data: (conversations) {
                  final showFooter = conversations.isNotEmpty &&
                      !ref.read(fetchConversationsProvider.notifier).isLastPage();
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(fetchConversationsProvider);
                      try {
                        await ref.read(fetchConversationsProvider.future);
                      } catch (_) {}
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        if (conversations.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: NotFoundWidget(title: 'No conversations'.tr),
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
                              return ConversationListTile(
                                conversation: conversation,
                                onTap: () => openConversation(conversation),
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
      ),
    );
  }
}
