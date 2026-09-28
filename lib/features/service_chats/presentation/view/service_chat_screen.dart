import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/socket_service/conversation_realtime_service.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/conversations/data/models/conversation_realtime_event_model.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_message_entity.dart';
import 'package:heraj/features/conversations/presentation/view/widgets/conversation_composer.dart';
import 'package:heraj/features/conversations/presentation/view/widgets/conversation_message_bubbles.dart';
import 'package:heraj/features/service_chats/domain/entities/service_conversation_entity.dart';
import 'package:heraj/features/conversations/presentation/managers/chat_scroll_to_end_mixin.dart';
import 'package:heraj/features/service_chats/presentation/managers/service_chat_actions_mixin.dart';
import 'package:heraj/features/service_chats/presentation/managers/service_chats_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/shared_widgets/error_widget.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class ServiceChatScreen extends ConsumerStatefulWidget {
  const ServiceChatScreen({
    super.key,
    required this.conversation,
  });

  final ServiceConversationEntity conversation;

  @override
  ConsumerState<ServiceChatScreen> createState() => _ServiceChatScreenState();
}

class _ServiceChatScreenState extends ConsumerState<ServiceChatScreen>
    with
        WidgetsBindingObserver,
        ChatScrollToEndMixin,
        ServiceChatActionsMixin {
  static const _subscriptionPrefix = 'service-conversation';

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<void>? _reconnectSub;
  bool _loadingOlder = false;
  /// Page 1 loads newest; older pages only after initial jump-to-bottom settles.
  bool _readyForOlderLoad = false;

  @override
  ScrollController get chatScrollController => _scrollController;

  int get _conversationId => widget.conversation.id;
  String get _subscriptionKey => '$_subscriptionPrefix:$_conversationId';
  String get _userSubscriptionKey => '$_subscriptionPrefix-user:$_conversationId';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(fetchServiceConversationsProvider.notifier).markConversationRead(
            _conversationId,
          );
      _bindRealtime();
    });
  }

  @override
  void dispose() {
    _reconnectSub?.cancel();
    final realtime = getIt<ConversationRealtimeService>();
    unawaited(realtime.unsubscribeByKey(_subscriptionKey));
    unawaited(realtime.unsubscribeByKey(_userSubscriptionKey));
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _onScroll() async {
    if (!_readyForOlderLoad || !_scrollController.hasClients || _loadingOlder) {
      return;
    }
    final position = _scrollController.position;
    // Near the top = user scrolled up for older pages (page 2+).
    if (position.pixels > 80) return;

    final notifier =
        ref.read(serviceChatMessagesProvider(_conversationId).notifier);
    if (!notifier.hasOlderPages || notifier.isLoadingMore) return;

    setState(() => _loadingOlder = true);
    final previousMax = position.maxScrollExtent;
    final previousPixels = position.pixels;
    try {
      await notifier.fetchOlderPage();
      if (!mounted || !_scrollController.hasClients) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        final newMax = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(
          previousPixels + (newMax - previousMax),
        );
      });
    } finally {
      if (mounted) setState(() => _loadingOlder = false);
    }
  }

  void _enableOlderLoadAfterInitialScroll() {
    if (_readyForOlderLoad) return;
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _readyForOlderLoad = true);
    });
  }

  Future<void> _onSend() async {
    final text = _messageController.text;
    final sent = await sendServiceChatMessage(
      conversationId: _conversationId,
      body: text,
    );
    if (sent) {
      _messageController.clear();
      scrollChatToEnd();
    }
  }

  String _timeText(ConversationMessageEntity message) {
    final raw = message.createdAt;
    if (raw == null || raw.isEmpty) return '';
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return '';
    return DateFormat.jm().format(date);
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final other = DateTime(date.year, date.month, date.day);
    if (other == today) return 'Service chat today'.tr;
    return DateFormat.yMMMd().format(date);
  }

  void _onRealtimePayload(ChatRealtimePayload payload) {
    if (!payload.isServiceConversation) return;
    final conversation = ServiceConversationEntity.fromJson(
      payload.conversationJson,
    );
    if (!mounted || conversation.id != _conversationId) {
      return;
    }
    ref
        .read(serviceChatMessagesProvider(_conversationId).notifier)
        .appendMessage(payload.message);
    ref.read(fetchServiceConversationsProvider.notifier)
      ..upsertConversation(
        conversation.copyWith(userHasUnread: false, userUnreadCount: 0),
      )
      ..markConversationRead(_conversationId);
  }

  Future<void> _bindRealtime() async {
    if (!mounted) return;

    final messagesNotifier =
        ref.read(serviceChatMessagesProvider(_conversationId).notifier);
    final conversationSub = messagesNotifier.subscriptions.conversation;
    final userSub = messagesNotifier.subscriptions.user;
    final websocket = widget.conversation.websocket;

    final conversationChannel = conversationSub.channel.trim().isNotEmpty
        ? conversationSub.channel
        : websocket.channel;
    final conversationEvent = conversationSub.event.trim().isNotEmpty
        ? conversationSub.event
        : websocket.event;

    final service = getIt<ConversationRealtimeService>();
    if (conversationChannel.trim().isNotEmpty &&
        conversationEvent.trim().isNotEmpty) {
      await service.subscribeToChannel(
        subscriptionKey: _subscriptionKey,
        channelName: conversationChannel,
        eventName: conversationEvent,
        isPrivate: false,
        onEvent: _onRealtimePayload,
      );
    }

    final userChannel = userSub.channel.trim();
    final userEvent = userSub.event.trim();
    if (userChannel.isNotEmpty && userEvent.isNotEmpty) {
      await service.subscribeToChannel(
        subscriptionKey: _userSubscriptionKey,
        channelName: userChannel,
        eventName: userEvent,
        isPrivate: true,
        onEvent: _onRealtimePayload,
      );
    }

    _reconnectSub ??= service.onReconnected.listen((_) {
      if (!mounted) return;
      // Re-bind only — do not invalidate messages (would wipe merged older pages).
      unawaited(_bindRealtime());
      ref.invalidate(fetchServiceConversationsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(serviceChatMessagesProvider(_conversationId));
    final isSending = ref.watch(isLoadingProvider('sendServiceChatMessage'));
    final title = widget.conversation.providerName;

    ref.listen(serviceChatMessagesProvider(_conversationId), (previous, next) {
      next.whenData((messages) {
        final previousCount = previous?.valueOrNull?.length ?? 0;
        final grewAtEnd = messages.length > previousCount &&
            previousCount > 0 &&
            !_loadingOlder;
        final isInitial = previousCount == 0 && messages.isNotEmpty;
        if (isInitial || grewAtEnd) {
          scrollChatToEnd(force: isInitial);
        }
        if (isInitial) {
          _enableOlderLoadAfterInitialScroll();
        }
        if (previous?.hasValue != true) {
          unawaited(_bindRealtime());
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColor.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _ChatAppBar(title: title),
          Expanded(
            child: messagesAsync.customWhen(
              ref: ref,
              refreshable: serviceChatMessagesProvider(_conversationId).future,
              skipLoadingOnRefresh: true,
              skipLoadingOnReload: true,
              loading: () => const PageLoadingWidget(),
              error: (err, trace) => CustomErrorWidget(
                object: err,
                stackTrace: trace,
                onRetry: () async {
                  ref.invalidate(serviceChatMessagesProvider(_conversationId));
                },
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet'.tr,
                      style: AppFont.font14W500Black.copyWith(
                        color: AppColor.textGrey,
                      ),
                    ),
                  );
                }
                final messagesNotifier = ref.read(
                  serviceChatMessagesProvider(_conversationId).notifier,
                );
                final showOlderLoader =
                    _loadingOlder || messagesNotifier.isLoadingMore;
                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: messages.length + (showOlderLoader ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (showOlderLoader && index == 0) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: LoadingWidget(size: 22),
                      );
                    }
                    final messageIndex = showOlderLoader ? index - 1 : index;
                    final message = messages[messageIndex];
                    final previous =
                        messageIndex > 0 ? messages[messageIndex - 1] : null;
                    final currentDate =
                        DateTime.tryParse(message.createdAt ?? '')?.toLocal();
                    final previousDate =
                        DateTime.tryParse(previous?.createdAt ?? '')?.toLocal();
                    final showDay = currentDate != null &&
                        (previousDate == null ||
                            currentDate.year != previousDate.year ||
                            currentDate.month != previousDate.month ||
                            currentDate.day != previousDate.day);

                    return Column(
                      children: [
                        if (showDay) ...[
                          Text(
                            _dayLabel(currentDate),
                            style: AppFont.font12w400Black.copyWith(
                              color: AppColor.textGrey,
                              fontSize: 11,
                            ),
                          ),
                          const Gap(10),
                        ],
                        if (message.isFromCustomer)
                          ConversationCustomerBubble(
                            message: message,
                            timeText: _timeText(message),
                            onImageLoaded: messageIndex == messages.length - 1
                                ? () => scrollChatToEnd()
                                : null,
                          )
                        else
                          ConversationVendorBubble(
                            avatarUrl: null,
                            message: message,
                            onImageLoaded: messageIndex == messages.length - 1
                                ? () => scrollChatToEnd()
                                : null,
                          ),
                        const Gap(8),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              10,
              6,
              10,
              context.mediaQueryPadding.bottom,
            ),
            child: ConversationComposer(
              controller: _messageController,
              isSending: isSending,
              onSend: _onSend,
              onAttach: () async {
                final sent = await attachAndSendImage(
                  conversationId: _conversationId,
                  body: _messageController.text,
                );
                if (sent) {
                  _messageController.clear();
                  scrollChatToEnd();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Material(
      color: AppColor.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, top + 4, 0, 8),
        child: Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: () => Get.back(closeOverlays: true),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: AppColor.black,
                  ),
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColor.grey1,
                  child: ClipOval(
                    child: ImageOrSvg(
                      null,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      pickImageOnNull: true,
                      assetImageOnNull: AppAssets.logoOnly,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.font14W600Black.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Service chat active'.tr,
                        style: AppFont.font12w400Black.copyWith(
                          color: AppColor.textBodySecondary,
                          fontSize: 11,
                        ),
                      ),
                      const Gap(4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColor.green1,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
